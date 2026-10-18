package com.sstinterview.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
public class CommentRequestDto {

    @NotBlank(message = "Message is required")
    private String message;

    @NotNull(message = "Experience id is required")
    private UUID experienceId;
}
