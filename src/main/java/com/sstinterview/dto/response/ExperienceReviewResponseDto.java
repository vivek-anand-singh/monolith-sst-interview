package com.sstinterview.dto.response;

import com.sstinterview.models.ExperienceReview;
import com.sstinterview.models.ExperienceStatus;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.util.UUID;

@Getter
@Setter
public class ExperienceReviewResponseDto {
    private UUID id;
    private UUID experienceId;
    private String adminName;
    private ExperienceStatus status;
    private String feedback;
    private Instant createdAt;

    public static ExperienceReviewResponseDto from(ExperienceReview review) {
        ExperienceReviewResponseDto dto = new ExperienceReviewResponseDto();
        dto.setId(review.getId());
        dto.setExperienceId(review.getExperience().getId());
        dto.setAdminName(review.getAdminName());
        dto.setStatus(review.getStatus());
        dto.setFeedback(review.getFeedback());
        dto.setCreatedAt(review.getCreatedAt());
        return dto;
    }
}
