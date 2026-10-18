package com.sstinterview.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AuthRequestDto
{
    @NotNull
    @NotBlank(message = "idToken is required")
    private String idToken;
}
