package com.sstinterview.dto.response;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AuthResponseDto {
    private String accessToken;
    private String userId;
    private String name;
    private String email;
    private String role;
}
