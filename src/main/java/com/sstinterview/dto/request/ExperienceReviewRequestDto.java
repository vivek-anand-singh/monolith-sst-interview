package com.sstinterview.dto.request;

import com.sstinterview.models.ExperienceStatus;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ExperienceReviewRequestDto {
    @NotNull
    private ExperienceStatus status;
    private String feedback;
}
