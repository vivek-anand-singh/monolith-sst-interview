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
public class ExperienceRequestDto {

    /**
     * The "how it went" narrative. Optional: a post carrying only the questions
     * asked is still useful. The service rejects a submission that has neither
     * content nor questions.
     */
    private String content;

    private String advice;

    @NotNull(message = "Company is required")
    private UUID companyId;

    @NotNull(message = "Round type is required")
    private UUID roundTypeId;

    @Min(value = 1, message = "Round number must be at least 1")
    private int roundNumber;

    private List<UUID> tagIds;

    /** Optional quick facts — one tap each, left null when the author skips them. */
    private Difficulty difficulty;

    private DurationBucket durationBucket;

    /**
     * Questions asked, in order. Optional at the API level so existing clients keep
     * working; blank entries are dropped rather than rejected.
     */
    @Size(max = 50, message = "At most 50 questions can be recorded for one round")
    private List<String> questions;
}
