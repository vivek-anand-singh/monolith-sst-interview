package com.sstinterview.repository;

import com.sstinterview.models.RoundType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface RoundTypeRepository extends JpaRepository<RoundType, UUID> {
    Page<RoundType> findByNameContainingIgnoreCase(String name, Pageable pageable);
}
