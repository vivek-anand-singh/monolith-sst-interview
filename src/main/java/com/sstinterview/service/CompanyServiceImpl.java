package com.sstinterview.service;

import com.sstinterview.dto.request.CompanyRequestDto;
import com.sstinterview.dto.response.CompanyResponseDto;
import com.sstinterview.dto.response.PagedResponseDto;
import com.sstinterview.exception.ForbiddenException;
import com.sstinterview.models.Role;
import com.sstinterview.util.RoleUtils;
import com.sstinterview.exception.ResourceNotFoundException;
import com.sstinterview.models.Comment;
import com.sstinterview.models.Company;
import com.sstinterview.models.Experience;
import com.sstinterview.models.Flag;
import com.sstinterview.models.FlagStatus;
import com.sstinterview.models.Tag;
import com.sstinterview.repository.CommentRepository;
import com.sstinterview.repository.CompanyRepository;
import com.sstinterview.repository.ExperienceRepository;
import com.sstinterview.repository.FlagRepository;
import com.sstinterview.repository.ReplyRepository;
import com.sstinterview.repository.TagRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class CompanyServiceImpl implements CompanyService
{
    private final CompanyRepository companyRepository;
    private final TagRepository tagRepository;
    private final ExperienceRepository experienceRepository;
    private final CommentRepository commentRepository;
    private final FlagRepository flagRepository;
    private final ReplyRepository replyRepository;

    public CompanyServiceImpl(CompanyRepository companyRepository, TagRepository tagRepository,
                               ExperienceRepository experienceRepository, CommentRepository commentRepository,
                               FlagRepository flagRepository, ReplyRepository replyRepository)
    {
        this.companyRepository = companyRepository;
        this.tagRepository = tagRepository;
        this.experienceRepository = experienceRepository;
        this.commentRepository = commentRepository;
        this.flagRepository = flagRepository;
        this.replyRepository = replyRepository;
    }

    @Override
    public PagedResponseDto<CompanyResponseDto> getCompanies(String q, int page, int size)
    {
        String query = (q == null) ? "" : q.trim();
        PageRequest pageable = PageRequest.of(page, size);
        return PagedResponseDto.from(
                companyRepository.searchByNameWithTags(query, pageable),
                CompanyResponseDto::from
        );
    }

    @Override
    public List<CompanyResponseDto> getInitialCompanies(int size)
    {
        return companyRepository.findAllWithTags().stream()
                .limit(size)
                .map(CompanyResponseDto::from)
                .toList();
    }

    @Override
    public CompanyResponseDto getCompanyById(UUID id)
    {
        Company company = companyRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Company not found with id: " + id));
        return CompanyResponseDto.from(company);
    }

    @Override
    public CompanyResponseDto createCompany(String userRole, CompanyRequestDto dto)
    {
        if (!RoleUtils.hasAtLeast(userRole, Role.ADMIN))
        {
            throw new ForbiddenException("Only admins can create companies");
        }

        List<Tag> tags = dto.getTagIds() != null
                ? new ArrayList<>(tagRepository.findAllById(dto.getTagIds()))
                : new ArrayList<>();

        Company company = new Company();
        company.setName(dto.getName());
        company.setTags(tags);

        return CompanyResponseDto.from(companyRepository.save(company));
    }

    @Override
    public CompanyResponseDto updateCompany(String userRole, UUID id, CompanyRequestDto dto)
    {
        if (!RoleUtils.hasAtLeast(userRole, Role.ADMIN))
        {
            throw new ForbiddenException("Only admins can update companies");
        }

        Company company = companyRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Company not found with id: " + id));

        List<Tag> tags = dto.getTagIds() != null
                ? new ArrayList<>(tagRepository.findAllById(dto.getTagIds()))
                : new ArrayList<>();

        company.setName(dto.getName());
        company.setTags(tags);

        return CompanyResponseDto.from(companyRepository.save(company));
    }

    @Override
    @Transactional
    public CompanyResponseDto deleteCompany(String userRole, UUID id)
    {
        if (!RoleUtils.hasAtLeast(userRole, Role.ADMIN))
        {
            throw new ForbiddenException("Only admins can delete companies");
        }

        Company company = companyRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Company not found with id: " + id));

        CompanyResponseDto response = CompanyResponseDto.from(company);

        List<Experience> experiences = experienceRepository.findByCompanyId(id);
        for (Experience experience : experiences)
        {
            List<Comment> comments = commentRepository.findByExperienceId(experience.getId());
            for (Comment comment : comments)
            {
                resolveFlags(flagRepository.findByCommentId(comment.getId()));
                replyRepository.deleteByCommentId(comment.getId());
            }
            commentRepository.deleteByExperienceId(experience.getId());
            resolveFlags(flagRepository.findByExperienceId(experience.getId()));
        }

        for (Experience experience : experiences)
        {
            experienceRepository.deleteById(experience.getId());
        }

        companyRepository.deleteById(id);
        return response;
    }

    private void resolveFlags(List<Flag> flags)
    {
        java.time.Instant now = java.time.Instant.now();
        for (Flag flag : flags)
        {
            flag.setStatus(FlagStatus.RESOLVED);
            flag.setResolvedAt(now);
            flag.setExperience(null);
            flag.setComment(null);
            flag.setReply(null);
        }
        flagRepository.saveAll(flags);
    }
}
