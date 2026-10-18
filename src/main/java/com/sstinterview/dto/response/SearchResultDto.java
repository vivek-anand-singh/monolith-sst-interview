package com.sstinterview.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class SearchResultDto {

    private PagedResponseDto<CompanyResponseDto> companies;
    private PagedResponseDto<TagResponseDto> tags;
    private PagedResponseDto<RoundTypeResponseDto> roundTypes;
    private PagedResponseDto<UserSearchDto> users;
}
