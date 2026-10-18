package com.sstinterview.dto.request;

import com.sstinterview.models.FlagStatus;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class FlagUpdateRequestDto {

    @NotNull(message = "Status is required")
    private FlagStatus status;
}
