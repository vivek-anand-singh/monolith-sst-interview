package com.sstinterview.dto.response;

import com.sstinterview.models.RoundType;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
public class RoundTypeResponseDto {

    private UUID id;
    private String name;

    public static RoundTypeResponseDto from(RoundType roundType) {
        RoundTypeResponseDto dto = new RoundTypeResponseDto();
        dto.setId(roundType.getId());
        dto.setName(roundType.getName());
        return dto;
    }
}
