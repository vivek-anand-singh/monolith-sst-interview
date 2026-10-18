package com.sstinterview.dto.response;

import com.sstinterview.models.Tag;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
public class TagResponseDto {

    private UUID id;
    private String name;

    public static TagResponseDto from(Tag tag) {
        TagResponseDto dto = new TagResponseDto();
        dto.setId(tag.getId());
        dto.setName(tag.getName());
        return dto;
    }
}
