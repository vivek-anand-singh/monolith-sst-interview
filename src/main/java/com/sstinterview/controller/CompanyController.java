package com.sstinterview.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.sstinterview.dto.request.CompanyRequestDto;
import com.sstinterview.dto.response.CompanyResponseDto;
import com.sstinterview.dto.response.PagedResponseDto;
import com.sstinterview.service.CompanyService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/companies")
@Tag(name = "Companies", description = "Browse and manage companies")
public class CompanyController
{
    private final CompanyService companyService;

    public CompanyController(CompanyService companyService) {
        this.companyService = companyService;
    }

    @Operation(summary = "Get companies with optional search and pagination")
    @GetMapping
    public ResponseEntity<PagedResponseDto<CompanyResponseDto>> getCompanies(
            @RequestParam(required = false) String q,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size)
    {
        return ResponseEntity.ok(companyService.getCompanies(q, page, size));
    }

    @Operation(summary = "Get initial companies for home panel (no search)")
    @GetMapping("/initial")
    public ResponseEntity<List<CompanyResponseDto>> getInitialCompanies(
            @RequestParam(defaultValue = "5") int size)
    {
        return ResponseEntity.ok(companyService.getInitialCompanies(size));
    }

    @Operation(summary = "Get company by ID")
    @GetMapping("/{id}")
    public ResponseEntity<CompanyResponseDto> getCompany(@PathVariable UUID id)
    {
        return ResponseEntity.ok(companyService.getCompanyById(id));
    }

    @Operation(summary = "Create a company", description = "Admin only")
    @PostMapping
    public ResponseEntity<CompanyResponseDto> createCompany(@RequestHeader("X-User-Role") String userRole, @Valid @RequestBody CompanyRequestDto companyRequestDto)
    {
        return ResponseEntity.status(HttpStatus.CREATED).body(companyService.createCompany(userRole, companyRequestDto));
    }

    @Operation(summary = "Update a company", description = "Admin only")
    @PutMapping("/{id}")
    public ResponseEntity<CompanyResponseDto> updateCompany(
            @RequestHeader("X-User-Role") String userRole,
            @PathVariable UUID id,
            @Valid @RequestBody CompanyRequestDto dto)
    {
        return ResponseEntity.ok(companyService.updateCompany(userRole, id, dto));
    }

    @Operation(summary = "Delete a company", description = "Admin only")
    @DeleteMapping("/{id}")
    public ResponseEntity<CompanyResponseDto> deleteCompany(
            @RequestHeader("X-User-Role") String userRole,
            @PathVariable UUID id)
    {
        return ResponseEntity.ok(companyService.deleteCompany(userRole, id));
    }
}
