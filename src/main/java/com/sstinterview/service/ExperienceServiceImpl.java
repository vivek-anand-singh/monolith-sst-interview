package com.sstinterview.service;

import com.sstinterview.dto.request.ExperienceRequestDto;
import com.sstinterview.dto.request.ExperienceReviewRequestDto;
import com.sstinterview.dto.request.ExperienceUpdateRequestDto;
import com.sstinterview.dto.response.CompanyBriefDto;
import com.sstinterview.dto.response.ExperienceResponseDto;
import com.sstinterview.dto.response.ExperienceReviewResponseDto;
import com.sstinterview.dto.response.PagedResponseDto;
import com.sstinterview.dto.response.UserStatsResponseDto;
import com.sstinterview.exception.ForbiddenException;
import com.sstinterview.models.Role;
import com.sstinterview.util.RoleUtils;
import com.sstinterview.exception.ResourceNotFoundException;
import com.sstinterview.models.Comment;
import com.sstinterview.models.Company;
import com.sstinterview.models.Experience;
import com.sstinterview.models.ExperienceQuestion;
import com.sstinterview.models.ExperienceReview;
import com.sstinterview.models.ExperienceStatus;
import com.sstinterview.models.Flag;
import com.sstinterview.models.FlagStatus;
import com.sstinterview.models.RoundType;
import com.sstinterview.models.Tag;
import com.sstinterview.repository.CommentRepository;
import com.sstinterview.repository.CompanyRepository;
import com.sstinterview.repository.ExperienceQuestionRepository;
import com.sstinterview.repository.ExperienceRepository;
import com.sstinterview.repository.ExperienceReviewRepository;
import com.sstinterview.repository.FlagRepository;
import com.sstinterview.repository.ReplyRepository;
import com.sstinterview.repository.RoundTypeRepository;
import com.sstinterview.repository.TagRepository;
import io.micrometer.core.instrument.MeterRegistry;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class ExperienceServiceImpl implements ExperienceService
{
    private static final Logger log = LoggerFactory.getLogger(ExperienceServiceImpl.class);

    private final ExperienceRepository experienceRepository;
    private final ExperienceReviewRepository reviewRepository;
    private final ExperienceQuestionRepository questionRepository;
    private final CompanyRepository companyRepository;
    private final RoundTypeRepository roundTypeRepository;
    private final TagRepository tagRepository;
    private final CommentRepository commentRepository;
    private final FlagRepository flagRepository;
    private final ReplyRepository replyRepository;
    private final UserService userService;
    private final NotificationService notificationService;
    private final MeterRegistry meterRegistry;

    public ExperienceServiceImpl(ExperienceRepository experienceRepository,
                                  ExperienceReviewRepository reviewRepository,
                                  ExperienceQuestionRepository questionRepository,
                                  CompanyRepository companyRepository,
                                  RoundTypeRepository roundTypeRepository,
                                  TagRepository tagRepository,
                                  CommentRepository commentRepository,
                                  FlagRepository flagRepository,
                                  ReplyRepository replyRepository,
                                  UserService userService,
                                  NotificationService notificationService,
                                  MeterRegistry meterRegistry)
    {
        this.experienceRepository = experienceRepository;
        this.reviewRepository = reviewRepository;
        this.questionRepository = questionRepository;
        this.companyRepository = companyRepository;
        this.roundTypeRepository = roundTypeRepository;
        this.tagRepository = tagRepository;
        this.commentRepository = commentRepository;
        this.flagRepository = flagRepository;
        this.replyRepository = replyRepository;
        this.userService = userService;
        this.notificationService = notificationService;
        this.meterRegistry = meterRegistry;
    }

    /**
     * Both the narrative and the questions are individually optional, so guard against
     * a submission that carries neither. A post that is only a list of questions is
     * valid and useful; a post that is nothing at all is not.
     */
    private void requireSomeSubstance(String content, List<String> questions)
    {
        boolean hasContent = content != null && !content.isBlank();
        boolean hasQuestions = !cleanQuestions(questions).isEmpty();
        if (!hasContent && !hasQuestions)
        {
            throw new IllegalArgumentException("Add at least one question, or describe how the round went");
        }
    }

    private String blankToNull(String value)
    {
        return (value == null || value.isBlank()) ? null : value.trim();
    }

    /** Drops null/blank entries and trims the rest, preserving author order. */
    private List<String> cleanQuestions(List<String> texts)
    {
        List<String> cleaned = new ArrayList<>();
        if (texts == null) return cleaned;
        for (String text : texts)
        {
            if (text == null || text.isBlank()) continue;
            cleaned.add(text.trim());
        }
        return cleaned;
    }

    /** Insert-only; safe to call outside a transaction because it never deletes. */
    private List<String> insertQuestions(Experience experience, List<String> texts)
    {
        List<String> cleaned = cleanQuestions(texts);
        List<ExperienceQuestion> rows = new ArrayList<>();
        for (int i = 0; i < cleaned.size(); i++)
        {
            ExperienceQuestion question = new ExperienceQuestion();
            question.setExperience(experience);
            question.setPosition(i);
            question.setText(cleaned.get(i));
            rows.add(question);
        }
        if (!rows.isEmpty()) questionRepository.saveAll(rows);
        return cleaned;
    }

    @Override
    public PagedResponseDto<ExperienceResponseDto> getAllExperiences(UUID companyId, UUID tagId, UUID roundTypeId, UUID userId, int page, int size)
    {
        PageRequest pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        Page<Experience> pageResult = experienceRepository.findWithFilters(companyId, tagId, roundTypeId, userId, ExperienceStatus.APPROVED, pageable);
        return toPagedResponse(pageResult);
    }

    @Override
    public PagedResponseDto<ExperienceResponseDto> getMyExperiences(UUID userId, UUID companyId, String search, int page, int size)
    {
        PageRequest pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        String normalizedSearch = (search != null && search.isBlank()) ? null : search;
        Page<Experience> pageResult = experienceRepository.findByUserIdWithFilters(userId, companyId, normalizedSearch, pageable);
        return toPagedResponse(pageResult);
    }

    private PagedResponseDto<ExperienceResponseDto> toPagedResponse(Page<Experience> pageResult)
    {
        List<Experience> experiences = pageResult.getContent();
        if (experiences.isEmpty()) return PagedResponseDto.from(pageResult, e -> ExperienceResponseDto.from(e, ""));

        List<UUID> ids = experiences.stream().map(Experience::getId).toList();
        Map<UUID, Long> commentCounts = commentRepository.countByExperienceIds(ids);
        Map<UUID, List<String>> questions = questionRepository.questionsByExperienceIds(ids);

        return PagedResponseDto.from(pageResult, e -> ExperienceResponseDto.from(
                e,
                userService.getAuthorName(e.getUserId()),
                commentCounts.getOrDefault(e.getId(), 0L),
                questions.getOrDefault(e.getId(), List.of())));
    }

    @Override
    public UserStatsResponseDto getMyStats(UUID userId)
    {
        long totalExperiences = experienceRepository.countByUserId(userId);
        long totalCompanies = experienceRepository.countDistinctCompaniesByUserId(userId);
        long totalComments = commentRepository.countByExperienceUserId(userId);
        return new UserStatsResponseDto(totalExperiences, totalCompanies, totalComments);
    }

    @Override
    public List<CompanyBriefDto> getMyCompanies(UUID userId)
    {
        return experienceRepository.findDistinctCompaniesByUserId(userId).stream()
                .map(CompanyBriefDto::from)
                .toList();
    }

    @Override
    public ExperienceResponseDto getExperienceById(UUID id, UUID requestingUserId, String requestingUserRole)
    {
        Experience experience = experienceRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Experience not found with id: " + id));

        if (experience.getStatus() != ExperienceStatus.APPROVED)
        {
            boolean isOwner = experience.getUserId().equals(requestingUserId);
            boolean isAdmin = RoleUtils.hasAtLeast(requestingUserRole, Role.ADMIN);
            if (!isOwner && !isAdmin)
            {
                throw new ResourceNotFoundException("Experience not found with id: " + id);
            }
        }

        return ExperienceResponseDto.from(
                experience,
                userService.getAuthorName(experience.getUserId()),
                commentRepository.countByExperienceId(id),
                questionTextsFor(id));
    }

    private List<String> questionTextsFor(UUID experienceId)
    {
        return questionRepository.findByExperienceIdOrderByPositionAsc(experienceId).stream()
                .map(ExperienceQuestion::getText)
                .toList();
    }

    @Override
    public ExperienceResponseDto createExperience(UUID userId, ExperienceRequestDto dto)
    {
        Company company = companyRepository.findById(dto.getCompanyId())
                .orElseThrow(() -> new ResourceNotFoundException("Company not found with id: " + dto.getCompanyId()));

        RoundType roundType = roundTypeRepository.findById(dto.getRoundTypeId())
                .orElseThrow(() -> new ResourceNotFoundException("Round type not found with id: " + dto.getRoundTypeId()));

        List<Tag> tags = dto.getTagIds() != null
                ? new ArrayList<>(tagRepository.findAllById(dto.getTagIds()))
                : new ArrayList<>();

        requireSomeSubstance(dto.getContent(), dto.getQuestions());

        Experience experience = new Experience();
        experience.setUserId(userId);
        experience.setContent(dto.getContent() != null ? dto.getContent() : "");
        experience.setAdvice(blankToNull(dto.getAdvice()));
        experience.setCompany(company);
        experience.setRoundType(roundType);
        experience.setRoundNumber(dto.getRoundNumber());
        experience.setTags(tags);
        experience.setStatus(ExperienceStatus.PENDING);
        experience.setDifficulty(dto.getDifficulty());
        experience.setDurationBucket(dto.getDurationBucket());

        Experience saved = experienceRepository.save(experience);
        List<String> questions = insertQuestions(saved, dto.getQuestions());

        meterRegistry.counter("interview.experiences.submitted").increment();
        notificationService.notifyExperienceSubmitted(saved.getId(), company.getName());

        return ExperienceResponseDto.from(saved, userService.getAuthorName(userId), 0L, questions);
    }

    @Override
    @Transactional
    public ExperienceResponseDto updateExperience(UUID userId, UUID id, ExperienceUpdateRequestDto dto)
    {
        Experience experience = experienceRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Experience not found with id: " + id));

        if (!experience.getUserId().equals(userId))
        {
            throw new ForbiddenException("You are not allowed to edit this experience");
        }

        Company company = companyRepository.findById(dto.getCompanyId())
                .orElseThrow(() -> new ResourceNotFoundException("Company not found with id: " + dto.getCompanyId()));

        RoundType roundType = roundTypeRepository.findById(dto.getRoundTypeId())
                .orElseThrow(() -> new ResourceNotFoundException("Round type not found with id: " + dto.getRoundTypeId()));

        List<Tag> tags = dto.getTagIds() != null
                ? new ArrayList<>(tagRepository.findAllById(dto.getTagIds()))
                : new ArrayList<>();

        requireSomeSubstance(dto.getContent(), dto.getQuestions());

        experience.setContent(dto.getContent() != null ? dto.getContent() : "");
        experience.setAdvice(blankToNull(dto.getAdvice()));
        experience.setCompany(company);
        experience.setRoundType(roundType);
        experience.setRoundNumber(dto.getRoundNumber());
        experience.setTags(tags);
        experience.setStatus(ExperienceStatus.PENDING);
        experience.setDifficulty(dto.getDifficulty());
        experience.setDurationBucket(dto.getDurationBucket());

        Experience saved = experienceRepository.save(experience);

        // Replace rather than merge: the client always sends the full ordered list.
        questionRepository.deleteByExperienceId(id);
        List<String> questions = insertQuestions(saved, dto.getQuestions());

        notificationService.notifyExperienceSubmitted(saved.getId(), company.getName());

        return ExperienceResponseDto.from(saved, userService.getAuthorName(userId), commentRepository.countByExperienceId(id), questions);
    }

    @Override
    @Transactional
    public ExperienceReviewResponseDto reviewExperience(UUID adminId, String adminName, UUID id, ExperienceReviewRequestDto dto)
    {
        Experience experience = experienceRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Experience not found with id: " + id));

        if (dto.getStatus() == ExperienceStatus.REJECTED &&
                (dto.getFeedback() == null || dto.getFeedback().isBlank()))
        {
            throw new IllegalArgumentException("Feedback is required when rejecting an experience");
        }

        ExperienceReview review = new ExperienceReview();
        review.setExperience(experience);
        review.setAdminId(adminId);
        review.setAdminName(adminName);
        review.setStatus(dto.getStatus());
        review.setFeedback(dto.getFeedback());
        ExperienceReview saved = reviewRepository.save(review);

        experience.setStatus(dto.getStatus());
        experienceRepository.save(experience);

        meterRegistry.counter("interview.experiences.reviewed", "status", dto.getStatus().name()).increment();

        notificationService.notifyExperienceReviewed(experience.getId(), experience.getUserId(), dto.getStatus(), dto.getFeedback(), experience.getCompany().getName());

        return ExperienceReviewResponseDto.from(saved);
    }

    @Override
    public List<ExperienceReviewResponseDto> getExperienceReviews(UUID id)
    {
        experienceRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Experience not found with id: " + id));
        return reviewRepository.findByExperienceIdOrderByCreatedAtAsc(id).stream()
                .map(ExperienceReviewResponseDto::from)
                .toList();
    }

    @Override
    public PagedResponseDto<ExperienceResponseDto> getAdminExperiences(ExperienceStatus status, int page, int size)
    {
        PageRequest pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        Page<Experience> pageResult = experienceRepository.findByStatus(status, pageable);
        return toPagedResponse(pageResult);
    }

    private void resolveFlags(List<Flag> flags)
    {
        java.time.Instant now = java.time.Instant.now();
        for (Flag flag : flags)
        {
            flag.setStatus(FlagStatus.RESOLVED);
            flag.setResolvedAt(now);
            flag.setExperience(null);
            flag.setComment(null);
            flag.setReply(null);
        }
        flagRepository.saveAll(flags);
    }

    @Override
    @Transactional
    public ExperienceResponseDto deleteExperience(UUID userId, String userRole, UUID id)
    {
        Experience experience = experienceRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Experience not found with id: " + id));

        if (!RoleUtils.hasAtLeast(userRole, Role.ADMIN) && !experience.getUserId().equals(userId))
        {
            throw new ForbiddenException("You are not allowed to delete this experience");
        }

        ExperienceResponseDto response = ExperienceResponseDto.from(
                experience,
                userService.getAuthorName(experience.getUserId()),
                0L,
                questionTextsFor(id));

        List<Comment> comments = commentRepository.findByExperienceId(id);
        for (Comment comment : comments)
        {
            resolveFlags(flagRepository.findByCommentId(comment.getId()));
            replyRepository.deleteByCommentId(comment.getId());
        }
        commentRepository.deleteByExperienceId(id);
        resolveFlags(flagRepository.findByExperienceId(id));
        reviewRepository.deleteAll(reviewRepository.findByExperienceIdOrderByCreatedAtAsc(id));
        questionRepository.deleteByExperienceId(id);
        experienceRepository.deleteById(id);

        return response;
    }
}
