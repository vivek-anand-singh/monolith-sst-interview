package com.sstinterview.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
public class ReplyRequestDto {

    @NotBlank(message = "Message is required")
    private String message;

    @NotNull(message = "Comment id is required")
    private UUID commentId;
}
