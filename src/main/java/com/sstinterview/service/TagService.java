package com.sstinterview.service;

import com.sstinterview.dto.request.TagRequestDto;
import com.sstinterview.dto.response.TagResponseDto;

import java.util.List;
import java.util.UUID;

public interface TagService
{
    List<TagResponseDto> getAllTags();
    TagResponseDto createTag(TagRequestDto dto);
    TagResponseDto deleteTag(String userRole, UUID id);
}
