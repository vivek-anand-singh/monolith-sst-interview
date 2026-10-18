package com.sstinterview.service;

import com.sstinterview.dto.request.AuthRequestDto;
import com.sstinterview.dto.response.AuthResponseDto;

public interface AuthProviderService {
    public AuthResponseDto getJWT(AuthRequestDto authRequestDto);
}
