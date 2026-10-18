package com.sstinterview.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class UserStatsResponseDto {
    private long totalExperiences;
    private long totalCompanies;
    private long totalComments;
}
