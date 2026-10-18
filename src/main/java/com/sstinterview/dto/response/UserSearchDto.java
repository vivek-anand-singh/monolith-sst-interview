package com.sstinterview.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.UUID;

@Getter
@AllArgsConstructor
public class UserSearchDto {

    private UUID userId;
    private String name;
}
