package com.sstinterview.controller;

import com.sstinterview.dto.request.FlagRequestDto;
import com.sstinterview.dto.request.FlagUpdateRequestDto;
import com.sstinterview.dto.response.FlagResponseDto;
import com.sstinterview.service.FlagService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@Tag(name = "Flags", description = "Report posts; admin endpoints to review and remove flags")
public class FlagController
{
    private final FlagService flagService;

    public FlagController(FlagService flagService)
    {
        this.flagService = flagService;
    }

    @Operation(summary = "Flag a post", description = "Flag an experience, comment, or reply for review")
    @PostMapping("/flags")
    public ResponseEntity<FlagResponseDto> createFlag(
            @RequestHeader("X-User-Id") UUID userId,
            @Valid @RequestBody FlagRequestDto dto)
    {
        return ResponseEntity.status(HttpStatus.CREATED).body(flagService.createFlag(userId, dto));
    }

    @Operation(summary = "Get all flags", description = "Admin only. Optionally filter by status: PENDING, DISMISSED, RESOLVED")
    @GetMapping("/admin/flags")
    public ResponseEntity<List<FlagResponseDto>> getAllFlags(
            @RequestHeader("X-User-Role") String userRole,
            @RequestParam(required = false) String status)
    {
        return ResponseEntity.ok(flagService.getAllFlags(userRole, status));
    }

    @Operation(summary = "Update flag status", description = "Admin only. Set status to DISMISSED or RESOLVED")
    @PatchMapping("/admin/flags/{id}")
    public ResponseEntity<FlagResponseDto> updateFlagStatus(
            @RequestHeader("X-User-Role") String userRole,
            @RequestHeader("X-User-Id") UUID adminUserId,
            @PathVariable UUID id,
            @Valid @RequestBody FlagUpdateRequestDto dto)
    {
        return ResponseEntity.ok(flagService.updateFlagStatus(userRole, adminUserId, id, dto.getStatus()));
    }

    @Operation(summary = "Remove a flag", description = "Admin only")
    @DeleteMapping("/admin/flags/{id}")
    public ResponseEntity<FlagResponseDto> deleteFlag(
            @RequestHeader("X-User-Role") String userRole,
            @PathVariable UUID id)
    {
        return ResponseEntity.ok(flagService.deleteFlag(userRole, id));
    }
}
