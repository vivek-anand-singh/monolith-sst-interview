package com.sstinterview.dto.response;

import com.sstinterview.models.Flag;
import com.sstinterview.models.FlagStatus;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.util.UUID;

@Getter
@Setter
public class FlagResponseDto {

    private UUID id;
    private UUID userId;
    private String reporterName;
    private UUID experienceId;
    private UUID commentId;
    private UUID replyId;
    private UUID targetExperienceId;
    private String reason;
    private FlagStatus status;
    private Instant createdAt;
    private UUID resolvedByUserId;
    private Instant resolvedAt;

    public static FlagResponseDto from(Flag flag, String reporterName) {
        FlagResponseDto dto = new FlagResponseDto();
        dto.setId(flag.getId());
        dto.setUserId(flag.getUserId());
        dto.setReporterName(reporterName);
        dto.setReason(flag.getReason());
        dto.setStatus(flag.getStatus());
        dto.setCreatedAt(flag.getCreatedAt());
        if (flag.getExperience() != null) dto.setExperienceId(flag.getExperience().getId());
        if (flag.getComment() != null) dto.setCommentId(flag.getComment().getId());
        if (flag.getReply() != null) dto.setReplyId(flag.getReply().getId());
        dto.setTargetExperienceId(flag.getTargetExperienceId());
        dto.setResolvedByUserId(flag.getResolvedByUserId());
        dto.setResolvedAt(flag.getResolvedAt());
        return dto;
    }
}
