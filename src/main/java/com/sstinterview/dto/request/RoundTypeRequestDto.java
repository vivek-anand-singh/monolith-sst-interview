package com.sstinterview.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RoundTypeRequestDto {

    @NotBlank(message = "Round type name is required")
    private String name;
}
