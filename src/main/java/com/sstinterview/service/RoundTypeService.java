package com.sstinterview.service;

import com.sstinterview.dto.request.RoundTypeRequestDto;
import com.sstinterview.dto.response.RoundTypeResponseDto;

import java.util.List;
import java.util.UUID;

public interface RoundTypeService
{
    List<RoundTypeResponseDto> getAllRoundTypes(UUID companyId);
    RoundTypeResponseDto createRoundType(RoundTypeRequestDto dto);
    RoundTypeResponseDto deleteRoundType(String userRole, UUID id);
}
