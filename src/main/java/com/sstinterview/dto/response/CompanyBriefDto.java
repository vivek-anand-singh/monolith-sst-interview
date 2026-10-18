package com.sstinterview.dto.response;

import com.sstinterview.models.Company;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.UUID;

@Getter
@AllArgsConstructor
public class CompanyBriefDto {
    private UUID id;
    private String name;

    public static CompanyBriefDto from(Company company) {
        return new CompanyBriefDto(company.getId(), company.getName());
    }
}
