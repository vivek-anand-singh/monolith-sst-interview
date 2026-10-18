package com.sstinterview.dto.request;

import com.sstinterview.models.Difficulty;
import com.sstinterview.models.DurationBucket;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.UUID;

@Getter
@Setter
public class ExperienceUpdateRequestDto {
    /** Optional — see {@link ExperienceRequestDto#getContent()}. */
    private String content;
    private String advice;
    @NotNull
    private UUID companyId;
    @NotNull
    private UUID roundTypeId;
    @Min(1)
    private int roundNumber;
    private List<UUID> tagIds;

    private Difficulty difficulty;

    private DurationBucket durationBucket;

    @Size(max = 50, message = "At most 50 questions can be recorded for one round")
    private List<String> questions;
}
