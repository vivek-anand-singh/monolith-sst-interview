package com.sstinterview.controller;

import com.sstinterview.dto.request.RoundTypeRequestDto;
import com.sstinterview.dto.response.RoundTypeResponseDto;
import com.sstinterview.service.RoundTypeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/round-types")
@Tag(name = "Round Types", description = "Interview round types (e.g. DSA, HR, System Design)")
public class RoundTypeController
{

    private final RoundTypeService roundTypeService;

    public RoundTypeController(RoundTypeService roundTypeService) {
        this.roundTypeService = roundTypeService;
    }

    @Operation(summary = "Get all round types", description = "Pass companyId to return only rounds that have experiences for that company")
    @GetMapping
    public ResponseEntity<List<RoundTypeResponseDto>> getAllRoundTypes(
            @RequestParam(required = false) UUID companyId)
    {
        return ResponseEntity.ok(roundTypeService.getAllRoundTypes(companyId));
    }

    @Operation(summary = "Create a round type")
    @PostMapping
    public ResponseEntity<RoundTypeResponseDto> createRoundType(@Valid @RequestBody RoundTypeRequestDto dto)
    {
        return ResponseEntity.status(HttpStatus.CREATED).body(roundTypeService.createRoundType(dto));
    }

    @Operation(summary = "Delete a round type", description = "Admin only")
    @DeleteMapping("/{id}")
    public ResponseEntity<RoundTypeResponseDto> deleteRoundType(
            @RequestHeader("X-User-Role") String userRole,
            @PathVariable UUID id)
    {
        return ResponseEntity.ok(roundTypeService.deleteRoundType(userRole, id));
    }
}
