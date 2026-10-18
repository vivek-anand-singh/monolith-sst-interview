package com.sstinterview.service;

import com.sstinterview.dto.request.ReplyRequestDto;
import com.sstinterview.dto.response.ReplyResponseDto;
import com.sstinterview.exception.ForbiddenException;
import com.sstinterview.models.Role;
import com.sstinterview.util.RoleUtils;
import com.sstinterview.exception.ResourceNotFoundException;
import com.sstinterview.models.Comment;
import com.sstinterview.models.Flag;
import com.sstinterview.models.FlagStatus;
import com.sstinterview.models.Reply;
import com.sstinterview.repository.CommentRepository;
import com.sstinterview.repository.FlagRepository;
import com.sstinterview.repository.ReplyRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class ReplyServiceImpl implements ReplyService
{
    private static final Logger log = LoggerFactory.getLogger(ReplyServiceImpl.class);
    private final ReplyRepository replyRepository;
    private final CommentRepository commentRepository;
    private final FlagRepository flagRepository;
    private final UserService userService;
    private final NotificationService notificationService;

    public ReplyServiceImpl(ReplyRepository replyRepository, CommentRepository commentRepository,
                             FlagRepository flagRepository, UserService userService,
                             NotificationService notificationService)
    {
        this.replyRepository = replyRepository;
        this.commentRepository = commentRepository;
        this.flagRepository = flagRepository;
        this.userService = userService;
        this.notificationService = notificationService;
    }

    @Override
    public List<ReplyResponseDto> getRepliesByCommentId(UUID commentId)
    {
        List<Reply> list = replyRepository.findByCommentId(commentId);

        List<ReplyResponseDto> responseList = new ArrayList<>();

        for (Reply reply : list)
            responseList.add(ReplyResponseDto.from(reply, userService.getAuthorName(reply.getUserId())));

        return responseList;
    }

    @Override
    public ReplyResponseDto getReplyById(UUID id)
    {
        Reply reply = replyRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Reply not found with id: " + id));
        return ReplyResponseDto.from(reply, userService.getAuthorName(reply.getUserId()));
    }

    @Override
    public ReplyResponseDto createReply(UUID userId, ReplyRequestDto dto)
    {
        Comment comment = commentRepository.findById(dto.getCommentId())
                .orElseThrow(() -> new ResourceNotFoundException("Comment not found with id: " + dto.getCommentId()));

        Reply reply = new Reply();
        reply.setUserId(userId);
        reply.setMessage(dto.getMessage());
        reply.setComment(comment);

        Reply saved = replyRepository.save(reply);

        notificationService.notifyReplyCreated(saved.getId(), comment.getUserId(), saved.getMessage());

        return ReplyResponseDto.from(saved, userService.getAuthorName(userId));
    }

    @Override
    public ReplyResponseDto deleteReply(UUID userId, String userRole, UUID id)
    {
        Reply reply = replyRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Reply not found with id: " + id));

        if (!RoleUtils.hasAtLeast(userRole, Role.ADMIN) && !reply.getUserId().equals(userId))
        {
            throw new ForbiddenException("You are not allowed to delete this reply");
        }

        ReplyResponseDto response = ReplyResponseDto.from(reply, userService.getAuthorName(reply.getUserId()));
        resolveFlags(flagRepository.findByReplyId(id));
        replyRepository.deleteById(id);
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
