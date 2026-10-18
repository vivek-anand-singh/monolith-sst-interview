package com.sstinterview.service;

import com.sstinterview.dto.request.FlagRequestDto;
import com.sstinterview.dto.response.FlagResponseDto;
import com.sstinterview.models.FlagStatus;

import java.util.List;
import java.util.UUID;

public interface FlagService
{
    FlagResponseDto createFlag(UUID userId, FlagRequestDto dto);
    List<FlagResponseDto> getAllFlags(String userRole, String status);
    FlagResponseDto deleteFlag(String userRole, UUID id);
    FlagResponseDto updateFlagStatus(String userRole, UUID adminUserId, UUID id, FlagStatus status);
}
