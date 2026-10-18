package com.sstinterview.controller;

import com.sstinterview.dto.request.ReplyRequestDto;
import com.sstinterview.dto.response.ReplyResponseDto;
import com.sstinterview.service.ReplyService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/replies")
@Tag(name = "Replies", description = "1-level replies on comments")
public class ReplyController
{
    private final ReplyService replyService;

    public ReplyController(ReplyService replyService)
    {
        this.replyService = replyService;
    }

    @Operation(summary = "Get replies by comment ID")
    @GetMapping
    public ResponseEntity<List<ReplyResponseDto>> getRepliesByCommentId(@RequestParam UUID commentId)
    {
        return ResponseEntity.ok(replyService.getRepliesByCommentId(commentId));
    }

    @Operation(summary = "Get a reply by ID")
    @GetMapping("/{id}")
    public ResponseEntity<ReplyResponseDto> getReplyById(@PathVariable UUID id)
    {
        return ResponseEntity.ok(replyService.getReplyById(id));
    }

    @Operation(summary = "Post a reply on a comment")
    @PostMapping
    public ResponseEntity<ReplyResponseDto> createReply(
            @RequestHeader("X-User-Id") UUID userId,
            @Valid @RequestBody ReplyRequestDto dto)
    {
        return ResponseEntity.status(HttpStatus.CREATED).body(replyService.createReply(userId, dto));
    }

    @Operation(summary = "Delete a reply", description = "Owner or admin only")
    @DeleteMapping("/{id}")
    public ResponseEntity<ReplyResponseDto> deleteReply(
            @RequestHeader("X-User-Id") UUID userId,
            @RequestHeader("X-User-Role") String userRole,
            @PathVariable UUID id)
    {
        return ResponseEntity.ok(replyService.deleteReply(userId, userRole, id));
    }
}
