package com.sstinterview.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.UUID;

@Getter
@Setter
public class CompanyRequestDto
{
    @NotBlank(message = "Company name is required")
    private String name;

    private List<UUID> tagIds;
}
