package com.sstinterview.service;

import com.sstinterview.dto.request.ExperienceRequestDto;
import com.sstinterview.dto.request.ExperienceReviewRequestDto;
import com.sstinterview.exception.ForbiddenException;
import com.sstinterview.exception.ResourceNotFoundException;
import com.sstinterview.models.Company;
import com.sstinterview.models.Experience;
import com.sstinterview.models.ExperienceStatus;
import com.sstinterview.models.RoundType;
import com.sstinterview.repository.CommentRepository;
import com.sstinterview.repository.CompanyRepository;
import com.sstinterview.repository.ExperienceQuestionRepository;
import com.sstinterview.repository.ExperienceRepository;
import com.sstinterview.repository.ExperienceReviewRepository;
import com.sstinterview.repository.FlagRepository;
import com.sstinterview.repository.ReplyRepository;
import com.sstinterview.repository.RoundTypeRepository;
import com.sstinterview.repository.TagRepository;
import io.micrometer.core.instrument.simple.SimpleMeterRegistry;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ExperienceServiceImplTest
{
    @Mock private ExperienceRepository experienceRepository;
    @Mock private ExperienceReviewRepository reviewRepository;
    @Mock private ExperienceQuestionRepository questionRepository;
    @Mock private CompanyRepository companyRepository;
    @Mock private RoundTypeRepository roundTypeRepository;
    @Mock private TagRepository tagRepository;
    @Mock private CommentRepository commentRepository;
    @Mock private FlagRepository flagRepository;
    @Mock private ReplyRepository replyRepository;
    @Mock private UserService userService;
    @Mock private NotificationService notificationService;

    private final SimpleMeterRegistry meterRegistry = new SimpleMeterRegistry();
    private ExperienceServiceImpl service;

    private final UUID ownerId = UUID.randomUUID();
    private final UUID experienceId = UUID.randomUUID();

    @BeforeEach
    void setUp()
    {
        service = new ExperienceServiceImpl(experienceRepository, reviewRepository, questionRepository,
                companyRepository, roundTypeRepository, tagRepository, commentRepository, flagRepository,
                replyRepository, userService, notificationService, meterRegistry);
    }

    private Experience experienceWithStatus(ExperienceStatus status)
    {
        Company company = new Company();
        company.setName("Acme");
        Experience experience = new Experience();
        experience.setId(experienceId);
        experience.setUserId(ownerId);
        experience.setCompany(company);
        experience.setStatus(status);
        return experience;
    }

    private ExperienceRequestDto requestWith(String content, List<String> questions)
    {
        ExperienceRequestDto dto = new ExperienceRequestDto();
        dto.setCompanyId(UUID.randomUUID());
        dto.setRoundTypeId(UUID.randomUUID());
        dto.setRoundNumber(1);
        dto.setContent(content);
        dto.setQuestions(questions);
        return dto;
    }

    private ExperienceReviewRequestDto review(ExperienceStatus status, String feedback)
    {
        ExperienceReviewRequestDto dto = new ExperienceReviewRequestDto();
        dto.setStatus(status);
        dto.setFeedback(feedback);
        return dto;
    }

    @Test
    void submissionWithNeitherContentNorQuestionsIsRejected()
    {
        ExperienceRequestDto dto = requestWith("  ", List.of(" ", ""));
        when(companyRepository.findById(dto.getCompanyId())).thenReturn(Optional.of(new Company()));
        when(roundTypeRepository.findById(dto.getRoundTypeId())).thenReturn(Optional.of(new RoundType()));

        assertThrows(IllegalArgumentException.class, () -> service.createExperience(ownerId, dto));
        verify(experienceRepository, never()).save(any());
    }

    @Test
    void newSubmissionStartsPendingAndNotifiesAdmins()
    {
        ExperienceRequestDto dto = requestWith("It went well", List.of("Reverse a linked list"));
        Company company = new Company();
        company.setName("Acme");
        when(companyRepository.findById(dto.getCompanyId())).thenReturn(Optional.of(company));
        when(roundTypeRepository.findById(dto.getRoundTypeId())).thenReturn(Optional.of(new RoundType()));
        when(experienceRepository.save(any(Experience.class))).thenAnswer(call -> {
            Experience saved = call.getArgument(0);
            saved.setId(experienceId);
            return saved;
        });
        when(userService.getAuthorName(ownerId)).thenReturn("Vivek");

        var response = service.createExperience(ownerId, dto);

        assertEquals(ExperienceStatus.PENDING, response.getStatus());
        verify(notificationService).notifyExperienceSubmitted(experienceId, "Acme");
        assertEquals(1.0, meterRegistry.counter("interview.experiences.submitted").count());
    }

    @Test
    void rejectingWithoutFeedbackIsRefused()
    {
        when(experienceRepository.findById(experienceId)).thenReturn(Optional.of(experienceWithStatus(ExperienceStatus.PENDING)));

        assertThrows(IllegalArgumentException.class,
                () -> service.reviewExperience(UUID.randomUUID(), "Admin", experienceId, review(ExperienceStatus.REJECTED, " ")));
        verify(reviewRepository, never()).save(any());
    }

    @Test
    void approvingChangesStatusAndNotifiesTheAuthor()
    {
        Experience experience = experienceWithStatus(ExperienceStatus.PENDING);
        when(experienceRepository.findById(experienceId)).thenReturn(Optional.of(experience));
        when(reviewRepository.save(any())).thenAnswer(call -> call.getArgument(0));

        service.reviewExperience(UUID.randomUUID(), "Admin", experienceId, review(ExperienceStatus.APPROVED, null));

        assertEquals(ExperienceStatus.APPROVED, experience.getStatus());
        assertEquals(1.0, meterRegistry.counter("interview.experiences.reviewed", "status", "APPROVED").count());
        verify(notificationService).notifyExperienceReviewed(eq(experienceId), eq(ownerId),
                eq(ExperienceStatus.APPROVED), any(), eq("Acme"));
    }

    @Test
    void pendingExperienceIsHiddenFromOtherUsers()
    {
        when(experienceRepository.findById(experienceId)).thenReturn(Optional.of(experienceWithStatus(ExperienceStatus.PENDING)));

        assertThrows(ResourceNotFoundException.class,
                () -> service.getExperienceById(experienceId, UUID.randomUUID(), "USER"));
    }

    @Test
    void pendingExperienceIsVisibleToItsOwner()
    {
        when(experienceRepository.findById(experienceId)).thenReturn(Optional.of(experienceWithStatus(ExperienceStatus.PENDING)));

        var response = service.getExperienceById(experienceId, ownerId, "USER");

        assertEquals(experienceId, response.getId());
    }

    @Test
    void pendingExperienceIsVisibleToAdmins()
    {
        when(experienceRepository.findById(experienceId)).thenReturn(Optional.of(experienceWithStatus(ExperienceStatus.PENDING)));

        var response = service.getExperienceById(experienceId, UUID.randomUUID(), "ADMIN");

        assertEquals(experienceId, response.getId());
    }

    @Test
    void userCannotDeleteSomeoneElsesExperience()
    {
        when(experienceRepository.findById(experienceId)).thenReturn(Optional.of(experienceWithStatus(ExperienceStatus.APPROVED)));

        assertThrows(ForbiddenException.class, () -> service.deleteExperience(UUID.randomUUID(), "USER", experienceId));
        verify(experienceRepository, never()).deleteById(any());
    }

    @Test
    void adminCanDeleteAnyExperience()
    {
        when(experienceRepository.findById(experienceId)).thenReturn(Optional.of(experienceWithStatus(ExperienceStatus.APPROVED)));
        when(commentRepository.findByExperienceId(experienceId)).thenReturn(List.of());
        when(flagRepository.findByExperienceId(experienceId)).thenReturn(List.of());
        when(reviewRepository.findByExperienceIdOrderByCreatedAtAsc(experienceId)).thenReturn(List.of());

        service.deleteExperience(UUID.randomUUID(), "ADMIN", experienceId);

        verify(experienceRepository).deleteById(experienceId);
    }
}
