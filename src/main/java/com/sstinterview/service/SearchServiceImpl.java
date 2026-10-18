package com.sstinterview.service;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import com.sstinterview.dto.response.CompanyResponseDto;
import com.sstinterview.dto.response.PagedResponseDto;
import com.sstinterview.dto.response.RoundTypeResponseDto;
import com.sstinterview.dto.response.SearchResultDto;
import com.sstinterview.dto.response.TagResponseDto;
import com.sstinterview.dto.response.UserSearchDto;
import com.sstinterview.repository.CompanyRepository;
import com.sstinterview.repository.RoundTypeRepository;
import com.sstinterview.repository.TagRepository;

@Service
public class SearchServiceImpl implements SearchService {

    private final CompanyRepository companyRepository;
    private final TagRepository tagRepository;
    private final RoundTypeRepository roundTypeRepository;
    private final UserService userService;

    public SearchServiceImpl(CompanyRepository companyRepository,
                             TagRepository tagRepository,
                             RoundTypeRepository roundTypeRepository,
                             UserService userService) {
        this.companyRepository = companyRepository;
        this.tagRepository = tagRepository;
        this.roundTypeRepository = roundTypeRepository;
        this.userService = userService;
    }

    @Override
    public SearchResultDto search(String query, int page, int size) {
        String trimmed = query == null ? "" : query.trim();

        if (trimmed.length() < 2) {
            PagedResponseDto<CompanyResponseDto> emptyCompanies = PagedResponseDto.from(Page.empty(), c -> null);
            PagedResponseDto<TagResponseDto> emptyTags = PagedResponseDto.from(Page.empty(), t -> null);
            PagedResponseDto<RoundTypeResponseDto> emptyRoundTypes = PagedResponseDto.from(Page.empty(), r -> null);
            PagedResponseDto<UserSearchDto> emptyUsers = PagedResponseDto.of(java.util.List.of(), page, size, 0, 0);
            return new SearchResultDto(emptyCompanies, emptyTags, emptyRoundTypes, emptyUsers);
        }

        PageRequest namePageable = PageRequest.of(page, size);

        PagedResponseDto<CompanyResponseDto> companies = PagedResponseDto.from(
                companyRepository.searchByNameWithTags(trimmed, namePageable),
                CompanyResponseDto::from);

        PagedResponseDto<TagResponseDto> tags = PagedResponseDto.from(
                tagRepository.findByNameContainingIgnoreCase(trimmed, namePageable),
                TagResponseDto::from);

        PagedResponseDto<RoundTypeResponseDto> roundTypes = PagedResponseDto.from(
                roundTypeRepository.findByNameContainingIgnoreCase(trimmed, namePageable),
                RoundTypeResponseDto::from);

        PagedResponseDto<UserSearchDto> users = userService.searchUsers(trimmed, page, size);

        return new SearchResultDto(companies, tags, roundTypes, users);
    }
}
