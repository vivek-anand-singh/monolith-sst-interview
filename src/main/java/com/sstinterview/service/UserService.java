package com.sstinterview.service;

import com.sstinterview.dto.response.AuthResponseDto;
import com.sstinterview.dto.response.PagedResponseDto;
import com.sstinterview.dto.response.UserSearchDto;

import java.util.List;
import java.util.UUID;

public interface UserService
{
    AuthResponseDto getProfile(UUID userId);

    String getAuthorName(UUID userId);

    PagedResponseDto<UserSearchDto> searchUsers(String query, int page, int size);

    List<UUID> getAdminIds();
}
