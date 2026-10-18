package com.sstinterview.dto.response;

import com.sstinterview.models.Reply;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.util.UUID;

@Getter
@Setter
public class ReplyResponseDto {

    private UUID id;
    private String message;
    private UUID commentId;
    private UUID experienceId;
    private UUID userId;
    private String authorName;
    private Instant createdAt;

    public static ReplyResponseDto from(Reply reply, String authorName) {
        ReplyResponseDto dto = new ReplyResponseDto();
        dto.setId(reply.getId());
        dto.setMessage(reply.getMessage());
        dto.setCommentId(reply.getComment().getId());
        dto.setExperienceId(reply.getComment().getExperience().getId());
        dto.setUserId(reply.getUserId());
        dto.setAuthorName(authorName);
        dto.setCreatedAt(reply.getCreatedAt());
        return dto;
    }
}
