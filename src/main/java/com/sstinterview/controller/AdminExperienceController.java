package com.sstinterview.controller;

import com.sstinterview.dto.request.ExperienceReviewRequestDto;
import com.sstinterview.dto.response.ExperienceResponseDto;
import com.sstinterview.dto.response.ExperienceReviewResponseDto;
import com.sstinterview.dto.response.PagedResponseDto;
import com.sstinterview.exception.ForbiddenException;
import com.sstinterview.models.ExperienceStatus;
import com.sstinterview.service.ExperienceService;
import com.sstinterview.service.UserService;
import com.sstinterview.models.Role;
import com.sstinterview.util.RoleUtils;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/admin/experiences")
@Tag(name = "Admin — Experiences", description = "Admin review queue for interview experiences")
public class AdminExperienceController {

    private final ExperienceService experienceService;
    private final UserService userService;

    public AdminExperienceController(ExperienceService experienceService, UserService userService) {
        this.experienceService = experienceService;
        this.userService = userService;
    }

    @Operation(summary = "List experiences by status (admin only)")
    @GetMapping
    public ResponseEntity<PagedResponseDto<ExperienceResponseDto>> getAdminExperiences(
            @RequestHeader("X-User-Role") String userRole,
            @RequestParam(defaultValue = "PENDING") ExperienceStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size)
    {
        if (!RoleUtils.hasAtLeast(userRole, Role.ADMIN))
            throw new ForbiddenException("Only admins can access the experience queue");
        return ResponseEntity.ok(experienceService.getAdminExperiences(status, page, size));
    }

    @Operation(summary = "Approve or reject an experience (admin only)")
    @PostMapping("/{id}/review")
    public ResponseEntity<ExperienceReviewResponseDto> reviewExperience(
            @RequestHeader("X-User-Id") UUID adminId,
            @RequestHeader("X-User-Role") String userRole,
            @PathVariable UUID id,
            @Valid @RequestBody ExperienceReviewRequestDto dto)
    {
        if (!RoleUtils.hasAtLeast(userRole, Role.ADMIN))
            throw new ForbiddenException("Only admins can review experiences");
        String adminName = userService.getAuthorName(adminId);
        return ResponseEntity.ok(experienceService.reviewExperience(adminId, adminName, id, dto));
    }
}
