package com.sstinterview.dto.response;

import com.sstinterview.models.Comment;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.util.UUID;

@Getter
@Setter
public class CommentResponseDto {

    private UUID id;
    private String message;
    private UUID experienceId;
    private UUID userId;
    private String authorName;
    private Instant createdAt;
    private long repliesCount;

    public static CommentResponseDto from(Comment comment, String authorName) {
        return from(comment, authorName, 0L);
    }

    public static CommentResponseDto from(Comment comment, String authorName, long repliesCount) {
        CommentResponseDto dto = new CommentResponseDto();
        dto.setId(comment.getId());
        dto.setMessage(comment.getMessage());
        dto.setExperienceId(comment.getExperience().getId());
        dto.setUserId(comment.getUserId());
        dto.setAuthorName(authorName);
        dto.setCreatedAt(comment.getCreatedAt());
        dto.setRepliesCount(repliesCount);
        return dto;
    }
}
