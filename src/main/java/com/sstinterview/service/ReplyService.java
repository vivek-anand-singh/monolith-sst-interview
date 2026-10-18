package com.sstinterview.service;

import com.sstinterview.dto.request.ReplyRequestDto;
import com.sstinterview.dto.response.ReplyResponseDto;

import java.util.List;
import java.util.UUID;

public interface ReplyService
{
    List<ReplyResponseDto> getRepliesByCommentId(UUID commentId);
    ReplyResponseDto getReplyById(UUID id);
    ReplyResponseDto createReply(UUID userId, ReplyRequestDto dto);
    ReplyResponseDto deleteReply(UUID userId, String userRole, UUID id);
}
