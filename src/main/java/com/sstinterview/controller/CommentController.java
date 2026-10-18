package com.sstinterview.controller;

import com.sstinterview.dto.request.CommentRequestDto;
import com.sstinterview.dto.response.CommentResponseDto;
import com.sstinterview.service.CommentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/comments")
@Tag(name = "Comments", description = "Threaded comments on experiences and company rooms")
public class CommentController
{
    private final CommentService commentService;

    public CommentController(CommentService commentService)
    {
        this.commentService = commentService;
    }

    @Operation(summary = "Get comments by experience ID")
    @GetMapping
    public ResponseEntity<List<CommentResponseDto>> getCommentsByExperienceId(@RequestParam UUID experienceId)
    {
        return ResponseEntity.ok(commentService.getCommentsByExperienceId(experienceId));
    }

    @Operation(summary = "Get a comment by ID")
    @GetMapping("/{id}")
    public ResponseEntity<CommentResponseDto> getCommentById(@PathVariable UUID id)
    {
        return ResponseEntity.ok(commentService.getCommentById(id));
    }

    @Operation(summary = "Post a comment on an experience")
    @PostMapping
    public ResponseEntity<CommentResponseDto> createComment(
            @RequestHeader("X-User-Id") UUID userId,
            @Valid @RequestBody CommentRequestDto dto)
    {
        return ResponseEntity.status(HttpStatus.CREATED).body(commentService.createComment(userId, dto));
    }

    @Operation(summary = "Delete a comment", description = "Owner or admin only")
    @DeleteMapping("/{id}")
    public ResponseEntity<CommentResponseDto> deleteComment(
            @RequestHeader("X-User-Id") UUID userId,
            @RequestHeader("X-User-Role") String userRole,
            @PathVariable UUID id)
    {
        return ResponseEntity.ok(commentService.deleteComment(userId, userRole, id));
    }
}
