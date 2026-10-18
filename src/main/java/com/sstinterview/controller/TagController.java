package com.sstinterview.controller;

import com.sstinterview.dto.request.TagRequestDto;
import com.sstinterview.dto.response.TagResponseDto;
import com.sstinterview.service.TagService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/tags")
@Tag(name = "Tags", description = "Tags for categorising interview experiences")
public class TagController
{
    private final TagService tagService;

    public TagController(TagService tagService) {
        this.tagService = tagService;
    }

    @Operation(summary = "Get all tags")
    @GetMapping
    public ResponseEntity<List<TagResponseDto>> getAllTags() {
        return ResponseEntity.ok(tagService.getAllTags());
    }

    @Operation(summary = "Create a tag")
    @PostMapping
    public ResponseEntity<TagResponseDto> createTag(@Valid @RequestBody TagRequestDto dto)
    {
        return ResponseEntity.status(HttpStatus.CREATED).body(tagService.createTag(dto));
    }

    @Operation(summary = "Delete a tag", description = "Admin only")
    @DeleteMapping("/{id}")
    public ResponseEntity<TagResponseDto> deleteTag(
            @RequestHeader("X-User-Role") String userRole,
            @PathVariable UUID id)
    {
        return ResponseEntity.ok(tagService.deleteTag(userRole, id));
    }
}
