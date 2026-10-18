package com.sstinterview.service;

import com.sstinterview.dto.request.RoundTypeRequestDto;
import com.sstinterview.dto.response.RoundTypeResponseDto;
import com.sstinterview.exception.ForbiddenException;
import com.sstinterview.models.Role;
import com.sstinterview.util.RoleUtils;
import com.sstinterview.exception.ResourceNotFoundException;
import com.sstinterview.models.RoundType;
import com.sstinterview.repository.ExperienceRepository;
import com.sstinterview.repository.RoundTypeRepository;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class RoundTypeServiceImpl implements RoundTypeService
{
    private final RoundTypeRepository roundTypeRepository;
    private final ExperienceRepository experienceRepository;

    public RoundTypeServiceImpl(RoundTypeRepository roundTypeRepository, ExperienceRepository experienceRepository)
    {
        this.roundTypeRepository = roundTypeRepository;
        this.experienceRepository = experienceRepository;
    }

    @Override
    public List<RoundTypeResponseDto> getAllRoundTypes(UUID companyId)
    {
        List<RoundType> list = companyId != null
                ? experienceRepository.findDistinctRoundTypesByCompanyId(companyId)
                : roundTypeRepository.findAll();

        List<RoundTypeResponseDto> responseList = new ArrayList<>();
        for (RoundType roundType : list) responseList.add(RoundTypeResponseDto.from(roundType));
        return responseList;
    }

    @Override
    public RoundTypeResponseDto createRoundType(RoundTypeRequestDto dto)
    {
        RoundType roundType = new RoundType();
        roundType.setName(dto.getName());
        return RoundTypeResponseDto.from(roundTypeRepository.save(roundType));
    }

    @Override
    public RoundTypeResponseDto deleteRoundType(String userRole, UUID id)
    {
        if (!RoleUtils.hasAtLeast(userRole, Role.ADMIN))
        {
            throw new ForbiddenException("Only admins can delete round types");
        }

        RoundType roundType = roundTypeRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Round type not found with id: " + id));

        RoundTypeResponseDto response = RoundTypeResponseDto.from(roundType);
        roundTypeRepository.deleteById(id);
        return response;
    }
}
