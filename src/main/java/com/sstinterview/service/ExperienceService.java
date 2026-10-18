package com.sstinterview.service;

import com.sstinterview.dto.request.ExperienceRequestDto;
import com.sstinterview.dto.request.ExperienceReviewRequestDto;
import com.sstinterview.dto.request.ExperienceUpdateRequestDto;
import com.sstinterview.dto.response.CompanyBriefDto;
import com.sstinterview.dto.response.ExperienceResponseDto;
import com.sstinterview.dto.response.ExperienceReviewResponseDto;
import com.sstinterview.dto.response.PagedResponseDto;
import com.sstinterview.dto.response.UserStatsResponseDto;
import com.sstinterview.models.ExperienceStatus;

import java.util.List;
import java.util.UUID;

public interface ExperienceService
{
    PagedResponseDto<ExperienceResponseDto> getAllExperiences(UUID companyId, UUID tagId, UUID roundTypeId, UUID userId, int page, int size);
    PagedResponseDto<ExperienceResponseDto> getMyExperiences(UUID userId, UUID companyId, String search, int page, int size);
    UserStatsResponseDto getMyStats(UUID userId);
    List<CompanyBriefDto> getMyCompanies(UUID userId);
    ExperienceResponseDto getExperienceById(UUID id, UUID requestingUserId, String requestingUserRole);
    ExperienceResponseDto createExperience(UUID userId, ExperienceRequestDto dto);
    ExperienceResponseDto updateExperience(UUID userId, UUID id, ExperienceUpdateRequestDto dto);
    ExperienceResponseDto deleteExperience(UUID userId, String userRole, UUID id);
    ExperienceReviewResponseDto reviewExperience(UUID adminId, String adminName, UUID id, ExperienceReviewRequestDto dto);
    List<ExperienceReviewResponseDto> getExperienceReviews(UUID id);
    PagedResponseDto<ExperienceResponseDto> getAdminExperiences(ExperienceStatus status, int page, int size);
}
