package com.sstinterview.service;

import com.sstinterview.dto.request.CommentRequestDto;
import com.sstinterview.dto.response.CommentResponseDto;
import com.sstinterview.exception.ForbiddenException;
import com.sstinterview.models.Role;
import com.sstinterview.util.RoleUtils;
import com.sstinterview.exception.ResourceNotFoundException;
import com.sstinterview.models.Comment;
import com.sstinterview.models.Experience;
import com.sstinterview.models.Flag;
import com.sstinterview.models.FlagStatus;
import com.sstinterview.repository.CommentRepository;
import com.sstinterview.repository.ExperienceRepository;
import com.sstinterview.repository.FlagRepository;
import com.sstinterview.repository.ReplyRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class CommentServiceImpl implements CommentService
{
    private static final Logger log = LoggerFactory.getLogger(CommentServiceImpl.class);
    private final CommentRepository commentRepository;
    private final ExperienceRepository experienceRepository;
    private final FlagRepository flagRepository;
    private final ReplyRepository replyRepository;
    private final UserService userService;
    private final NotificationService notificationService;

    public CommentServiceImpl(CommentRepository commentRepository, ExperienceRepository experienceRepository,
                               FlagRepository flagRepository, ReplyRepository replyRepository,
                               UserService userService, NotificationService notificationService)
    {
        this.commentRepository = commentRepository;
        this.experienceRepository = experienceRepository;
        this.flagRepository = flagRepository;
        this.replyRepository = replyRepository;
        this.userService = userService;
        this.notificationService = notificationService;
    }

    @Override
    public List<CommentResponseDto> getCommentsByExperienceId(UUID experienceId)
    {
        List<Comment> list = commentRepository.findByExperienceId(experienceId);

        List<CommentResponseDto> responseList = new ArrayList<>();

        for (Comment comment : list)
            responseList.add(CommentResponseDto.from(comment, userService.getAuthorName(comment.getUserId()), replyRepository.countByCommentId(comment.getId())));

        return responseList;
    }

    @Override
    public CommentResponseDto getCommentById(UUID id)
    {
        Comment comment = commentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Comment not found with id: " + id));
        return CommentResponseDto.from(comment, userService.getAuthorName(comment.getUserId()), replyRepository.countByCommentId(id));
    }

    @Override
    public CommentResponseDto createComment(UUID userId, CommentRequestDto dto)
    {
        Experience experience = experienceRepository.findById(dto.getExperienceId())
                .orElseThrow(() -> new ResourceNotFoundException("Experience not found with id: " + dto.getExperienceId()));

        Comment comment = new Comment();
        comment.setUserId(userId);
        comment.setMessage(dto.getMessage());
        comment.setExperience(experience);

        Comment saved = commentRepository.save(comment);

        if (!userId.equals(experience.getUserId())) {
            notificationService.notifyCommentCreated(saved.getId(), experience.getUserId(), saved.getMessage());
        }

        return CommentResponseDto.from(saved, userService.getAuthorName(userId));
    }

    @Override
    @Transactional
    public CommentResponseDto deleteComment(UUID userId, String userRole, UUID id)
    {
        Comment comment = commentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Comment not found with id: " + id));

        if (!RoleUtils.hasAtLeast(userRole, Role.ADMIN) && !comment.getUserId().equals(userId))
        {
            throw new ForbiddenException("You are not allowed to delete this comment");
        }

        CommentResponseDto response = CommentResponseDto.from(comment, userService.getAuthorName(comment.getUserId()));

        resolveFlags(flagRepository.findByCommentId(id));
        replyRepository.deleteByCommentId(id);
        commentRepository.deleteById(id);

        return response;
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
}
