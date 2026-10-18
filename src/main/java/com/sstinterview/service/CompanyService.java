package com.sstinterview.service;

import com.sstinterview.dto.request.CompanyRequestDto;
import com.sstinterview.dto.response.CompanyResponseDto;
import com.sstinterview.dto.response.PagedResponseDto;

import java.util.List;
import java.util.UUID;

public interface CompanyService
{
    PagedResponseDto<CompanyResponseDto> getCompanies(String q, int page, int size);
    /** Lightweight list for home panel (no search, no pagination) */
    List<CompanyResponseDto> getInitialCompanies(int size);
    CompanyResponseDto getCompanyById(UUID id);
    CompanyResponseDto createCompany(String userRole, CompanyRequestDto dto);
    CompanyResponseDto updateCompany(String userRole, UUID id, CompanyRequestDto dto);
    CompanyResponseDto deleteCompany(String userRole, UUID id);
}
