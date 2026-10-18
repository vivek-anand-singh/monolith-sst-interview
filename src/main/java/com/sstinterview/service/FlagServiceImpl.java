package com.sstinterview.service;

import com.sstinterview.dto.request.FlagRequestDto;
import com.sstinterview.dto.response.FlagResponseDto;
import com.sstinterview.exception.ForbiddenException;
import com.sstinterview.models.Role;
import com.sstinterview.util.RoleUtils;
import com.sstinterview.exception.ResourceNotFoundException;
import com.sstinterview.models.Comment;
import com.sstinterview.models.Experience;
import com.sstinterview.models.Flag;
import com.sstinterview.models.FlagStatus;
import com.sstinterview.models.Reply;
import com.sstinterview.repository.CommentRepository;
import com.sstinterview.repository.ExperienceRepository;
import com.sstinterview.repository.FlagRepository;
import com.sstinterview.repository.ReplyRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class FlagServiceImpl implements FlagService
{
    private static final Logger log = LoggerFactory.getLogger(FlagServiceImpl.class);
    private final FlagRepository flagRepository;
    private final ExperienceRepository experienceRepository;
    private final CommentRepository commentRepository;
    private final ReplyRepository replyRepository;
    private final UserService userService;
    private final NotificationService notificationService;

    public FlagServiceImpl(FlagRepository flagRepository, ExperienceRepository experienceRepository,
                           CommentRepository commentRepository, ReplyRepository replyRepository,
                           UserService userService, NotificationService notificationService)
    {
        this.flagRepository = flagRepository;
        this.experienceRepository = experienceRepository;
        this.commentRepository = commentRepository;
        this.replyRepository = replyRepository;
        this.userService = userService;
        this.notificationService = notificationService;
    }

    @Override
    public FlagResponseDto createFlag(UUID userId, FlagRequestDto dto)
    {
        if (dto.getExperienceId() == null && dto.getCommentId() == null && dto.getReplyId() == null)
        {
            throw new IllegalArgumentException("Either experienceId, commentId, or replyId must be provided");
        }

        Flag flag = new Flag();
        flag.setUserId(userId);
        flag.setReason(dto.getReason());

        if (dto.getExperienceId() != null)
        {
            Experience experience = experienceRepository.findById(dto.getExperienceId())
                    .orElseThrow(() -> new ResourceNotFoundException("Experience not found with id: " + dto.getExperienceId()));
            flag.setExperience(experience);
        }

        if (dto.getCommentId() != null)
        {
            Comment comment = commentRepository.findById(dto.getCommentId())
                    .orElseThrow(() -> new ResourceNotFoundException("Comment not found with id: " + dto.getCommentId()));
            flag.setComment(comment);
            if (comment.getExperience() != null) flag.setTargetExperienceId(comment.getExperience().getId());
        }

        if (dto.getReplyId() != null)
        {
            Reply reply = replyRepository.findById(dto.getReplyId())
                    .orElseThrow(() -> new ResourceNotFoundException("Reply not found with id: " + dto.getReplyId()));
            flag.setReply(reply);
            if (reply.getComment() != null && reply.getComment().getExperience() != null)
                flag.setTargetExperienceId(reply.getComment().getExperience().getId());
        }

        Flag saved = flagRepository.save(flag);

        UUID experienceId = saved.getExperience() != null ? saved.getExperience().getId() : null;
        UUID commentId = saved.getComment() != null ? saved.getComment().getId() : null;
        notificationService.notifyExperienceFlagged(experienceId, commentId, saved.getReason());

        return FlagResponseDto.from(saved, userService.getAuthorName(userId));
    }

    @Override
    public List<FlagResponseDto> getAllFlags(String userRole, String status)
    {
        if (!RoleUtils.hasAtLeast(userRole, Role.ADMIN))
        {
            throw new ForbiddenException("Only admins can view flags");
        }

        List<Flag> list = flagRepository.findAll();

        if (status != null && !status.isBlank())
        {
            FlagStatus filterStatus = FlagStatus.valueOf(status.toUpperCase());
            list = list.stream().filter(f -> f.getStatus() == filterStatus).collect(Collectors.toList());
        }

        List<FlagResponseDto> responseList = new ArrayList<>();
        for (Flag flag : list)
            responseList.add(FlagResponseDto.from(flag, userService.getAuthorName(flag.getUserId())));

        return responseList;
    }

    @Override
    public FlagResponseDto deleteFlag(String userRole, UUID id)
    {
        if (!RoleUtils.hasAtLeast(userRole, Role.ADMIN))
        {
            throw new ForbiddenException("Only admins can delete flags");
        }

        Flag flag = flagRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Flag not found with id: " + id));

        flagRepository.deleteById(id);
        return FlagResponseDto.from(flag, userService.getAuthorName(flag.getUserId()));
    }

    @Override
    public FlagResponseDto updateFlagStatus(String userRole, UUID adminUserId, UUID id, FlagStatus status)
    {
        if (!RoleUtils.hasAtLeast(userRole, Role.ADMIN))
        {
            throw new ForbiddenException("Only admins can update flags");
        }

        Flag flag = flagRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Flag not found with id: " + id));

        flag.setStatus(status);
        flag.setResolvedByUserId(adminUserId);
        flag.setResolvedAt(java.time.Instant.now());
        Flag saved = flagRepository.save(flag);
        return FlagResponseDto.from(saved, userService.getAuthorName(saved.getUserId()));
    }
}
