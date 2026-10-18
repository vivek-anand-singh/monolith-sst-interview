package com.sstinterview.repository;

import com.sstinterview.models.Tag;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface TagRepository extends JpaRepository<Tag, UUID> {
    Page<Tag> findByNameContainingIgnoreCase(String name, Pageable pageable);
}
