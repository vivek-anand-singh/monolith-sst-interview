package com.sstinterview.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
public class FlagRequestDto {

    private UUID experienceId;

    private UUID commentId;

    private UUID replyId;

    @NotBlank(message = "Reason is required")
    private String reason;
}
