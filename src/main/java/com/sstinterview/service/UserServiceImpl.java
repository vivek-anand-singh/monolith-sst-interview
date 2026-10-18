package com.sstinterview.service;

import com.sstinterview.dto.response.AuthResponseDto;
import com.sstinterview.dto.response.PagedResponseDto;
import com.sstinterview.dto.response.UserSearchDto;
import com.sstinterview.exception.ResourceNotFoundException;
import com.sstinterview.models.User;
import com.sstinterview.repository.UserRepository;
import com.sstinterview.models.Role;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class UserServiceImpl implements UserService
{
    private static final Logger log = LoggerFactory.getLogger(UserServiceImpl.class);
    private static final String UNKNOWN_USER = "Unknown User";
    private static final int DEFAULT_PAGE_SIZE = 10;

    private final UserRepository userRepository;

    public UserServiceImpl(UserRepository userRepository)
    {
        this.userRepository = userRepository;
    }

    @Override
    public AuthResponseDto getProfile(UUID userId)
    {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        AuthResponseDto dto = new AuthResponseDto();
        dto.setUserId(user.getId().toString());
        dto.setName(user.getName());
        dto.setEmail(user.getEmail());
        dto.setRole(user.getRole() != null ? user.getRole().name() : null);
        return dto;
    }

    @Override
    public String getAuthorName(UUID userId)
    {
        return userRepository.findById(userId).map(User::getName).orElseGet(() -> {
            log.warn("User not found for id={}", userId);
            return UNKNOWN_USER;
        });
    }

    @Override
    public PagedResponseDto<UserSearchDto> searchUsers(String query, int page, int size)
    {
        Page<User> result = userRepository.findByNameContainingIgnoreCase(
                query, PageRequest.of(page, size > 0 ? size : DEFAULT_PAGE_SIZE));
        List<UserSearchDto> users = result.getContent().stream()
                .map(user -> new UserSearchDto(user.getId(), user.getName()))
                .toList();
        return PagedResponseDto.of(users, page, size, (int) result.getTotalElements(), result.getTotalPages());
    }

    @Override
    public List<UUID> getAdminIds()
    {
        return userRepository.findByRoleIn(List.of(Role.ADMIN, Role.SUPERADMIN)).stream()
                .map(User::getId)
                .toList();
    }
}
