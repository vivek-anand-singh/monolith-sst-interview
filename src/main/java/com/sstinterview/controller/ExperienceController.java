package com.sstinterview.controller;

import com.sstinterview.dto.request.ExperienceRequestDto;
import com.sstinterview.dto.request.ExperienceUpdateRequestDto;
import com.sstinterview.dto.response.CompanyBriefDto;
import com.sstinterview.dto.response.ExperienceResponseDto;
import com.sstinterview.dto.response.ExperienceReviewResponseDto;
import com.sstinterview.dto.response.PagedResponseDto;
import com.sstinterview.dto.response.UserStatsResponseDto;
import com.sstinterview.service.ExperienceService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/experiences")
@Tag(name = "Experiences", description = "Submit and browse interview experiences")
public class ExperienceController
{
    private final ExperienceService experienceService;

    public ExperienceController(ExperienceService experienceService)
    {
        this.experienceService = experienceService;
    }

    @Operation(summary = "Get all experiences", description = "Filter by companyId, tagId, roundTypeId, or userId. Sorted by newest first.")
    @GetMapping
    public ResponseEntity<PagedResponseDto<ExperienceResponseDto>> getAllExperiences(
            @RequestParam(required = false) UUID companyId,
            @RequestParam(required = false) UUID tagId,
            @RequestParam(required = false) UUID roundTypeId,
            @RequestParam(required = false) UUID userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size)
    {
        return ResponseEntity.ok(experienceService.getAllExperiences(companyId, tagId, roundTypeId, userId, page, size));
    }

    @Operation(summary = "Get my experiences", description = "Returns paginated experiences for the current user, optionally filtered by company or search term")
    @GetMapping("/me")
    public ResponseEntity<PagedResponseDto<ExperienceResponseDto>> getMyExperiences(
            @RequestHeader("X-User-Id") UUID userId,
            @RequestParam(required = false) UUID companyId,
            @RequestParam(required = false) String search,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size)
    {
        return ResponseEntity.ok(experienceService.getMyExperiences(userId, companyId, search, page, size));
    }

    @Operation(summary = "Get my stats", description = "Returns aggregate counts for the current user's experiences")
    @GetMapping("/me/stats")
    public ResponseEntity<UserStatsResponseDto> getMyStats(@RequestHeader("X-User-Id") UUID userId)
    {
        return ResponseEntity.ok(experienceService.getMyStats(userId));
    }

    @Operation(summary = "Get my companies", description = "Returns distinct companies the current user has posted about")
    @GetMapping("/me/companies")
    public ResponseEntity<List<CompanyBriefDto>> getMyCompanies(@RequestHeader("X-User-Id") UUID userId)
    {
        return ResponseEntity.ok(experienceService.getMyCompanies(userId));
    }

    @Operation(summary = "Get experience by ID", description = "APPROVED experiences are public. PENDING/REJECTED are only visible to the owner or an admin.")
    @GetMapping("/{id}")
    public ResponseEntity<ExperienceResponseDto> getExperienceById(
            @RequestHeader("X-User-Id") UUID requestingUserId,
            @RequestHeader("X-User-Role") String requestingUserRole,
            @PathVariable UUID id)
    {
        return ResponseEntity.ok(experienceService.getExperienceById(id, requestingUserId, requestingUserRole));
    }

    @Operation(summary = "Submit an interview experience")
    @PostMapping
    public ResponseEntity<ExperienceResponseDto> createExperience(@RequestHeader("X-User-Id") UUID userId, @Valid @RequestBody ExperienceRequestDto dto)
    {
        return ResponseEntity.status(HttpStatus.CREATED).body(experienceService.createExperience(userId, dto));
    }

    @Operation(summary = "Update an experience", description = "Owner only; resets status to PENDING")
    @PutMapping("/{id}")
    public ResponseEntity<ExperienceResponseDto> updateExperience(
            @RequestHeader("X-User-Id") UUID userId,
            @PathVariable UUID id,
            @Valid @RequestBody ExperienceUpdateRequestDto dto)
    {
        return ResponseEntity.ok(experienceService.updateExperience(userId, id, dto));
    }

    @Operation(summary = "Get review history for an experience")
    @GetMapping("/{id}/reviews")
    public ResponseEntity<List<ExperienceReviewResponseDto>> getReviews(@PathVariable UUID id)
    {
        return ResponseEntity.ok(experienceService.getExperienceReviews(id));
    }

    @Operation(summary = "Delete an experience", description = "Owner or admin only")
    @DeleteMapping("/{id}")
    public ResponseEntity<ExperienceResponseDto> deleteExperience(
            @RequestHeader("X-User-Id") UUID userId,
            @RequestHeader("X-User-Role") String userRole,
            @PathVariable UUID id)
    {
        return ResponseEntity.ok(experienceService.deleteExperience(userId, userRole, id));
    }
}
