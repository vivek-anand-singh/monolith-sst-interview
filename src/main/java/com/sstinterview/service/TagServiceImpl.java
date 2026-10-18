package com.sstinterview.service;

import com.sstinterview.dto.request.TagRequestDto;
import com.sstinterview.dto.response.TagResponseDto;
import com.sstinterview.exception.ForbiddenException;
import com.sstinterview.models.Role;
import com.sstinterview.util.RoleUtils;
import com.sstinterview.exception.ResourceNotFoundException;
import com.sstinterview.models.Company;
import com.sstinterview.models.Experience;
import com.sstinterview.models.Tag;
import com.sstinterview.repository.CompanyRepository;
import com.sstinterview.repository.ExperienceRepository;
import com.sstinterview.repository.TagRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class TagServiceImpl implements TagService
{
    private final TagRepository tagRepository;
    private final CompanyRepository companyRepository;
    private final ExperienceRepository experienceRepository;

    public TagServiceImpl(TagRepository tagRepository, CompanyRepository companyRepository,
                          ExperienceRepository experienceRepository)
    {
        this.tagRepository = tagRepository;
        this.companyRepository = companyRepository;
        this.experienceRepository = experienceRepository;
    }

    @Override
    public List<TagResponseDto> getAllTags()
    {
        List<Tag> list = tagRepository.findAll();

        List<TagResponseDto> responseList = new ArrayList<>();

        for (Tag tag : list) responseList.add(TagResponseDto.from(tag));
        return responseList;
    }

    @Override
    public TagResponseDto createTag(TagRequestDto dto)
    {
        Tag tag = new Tag();
        tag.setName(dto.getName());
        return TagResponseDto.from(tagRepository.save(tag));
    }

    @Override
    @Transactional
    public TagResponseDto deleteTag(String userRole, UUID id)
    {
        if (!RoleUtils.hasAtLeast(userRole, Role.ADMIN))
        {
            throw new ForbiddenException("Only admins can delete tags");
        }

        Tag tag = tagRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Tag not found with id: " + id));

        TagResponseDto response = TagResponseDto.from(tag);

        List<Company> companies = new ArrayList<>(tag.getCompanies());
        for (Company company : companies)
        {
            company.getTags().remove(tag);
            companyRepository.save(company);
        }

        List<Experience> experiences = new ArrayList<>(tag.getExperiences());
        for (Experience experience : experiences)
        {
            experience.getTags().remove(tag);
            experienceRepository.save(experience);
        }

        tagRepository.deleteById(id);
        return response;
    }
}
