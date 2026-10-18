package com.sstinterview.service;

import com.sstinterview.dto.request.CommentRequestDto;
import com.sstinterview.dto.response.CommentResponseDto;

import java.util.List;
import java.util.UUID;

public interface CommentService
{
    List<CommentResponseDto> getCommentsByExperienceId(UUID experienceId);
    CommentResponseDto getCommentById(UUID id);
    CommentResponseDto createComment(UUID userId, CommentRequestDto dto);
    CommentResponseDto deleteComment(UUID userId, String userRole, UUID id);
}
