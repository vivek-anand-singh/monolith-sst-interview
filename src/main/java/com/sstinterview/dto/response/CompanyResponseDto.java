package com.sstinterview.dto.response;

import com.sstinterview.models.Company;
import com.sstinterview.models.Tag;
import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.UUID;

@Getter
@Setter
public class CompanyResponseDto {

    private UUID id;
    private String name;
    private List<String> tags;

    public static CompanyResponseDto from(Company company) {
        CompanyResponseDto dto = new CompanyResponseDto();
        dto.setId(company.getId());
        dto.setName(company.getName());
        dto.setTags(company.getTags().stream().map(Tag::getName).toList());
        return dto;
    }
}
