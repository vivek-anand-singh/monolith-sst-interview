package com.sstinterview.repository;

import com.sstinterview.models.User;
import com.sstinterview.models.Role;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByAuthProviderId(String authProviderId);
    Page<User> findByNameContainingIgnoreCase(String name, Pageable pageable);
    List<User> findByRoleIn(Collection<Role> roles);
}

