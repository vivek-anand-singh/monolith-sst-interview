package com.sstinterview.repository;

import com.sstinterview.models.Company;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.UUID;

public interface CompanyRepository extends JpaRepository<Company, UUID> {

    @Query(value = "SELECT DISTINCT c FROM Company c LEFT JOIN FETCH c.tags WHERE LOWER(c.name) LIKE LOWER(CONCAT('%', :q, '%'))",
           countQuery = "SELECT COUNT(DISTINCT c) FROM Company c WHERE LOWER(c.name) LIKE LOWER(CONCAT('%', :q, '%'))")
    Page<Company> searchByNameWithTags(String q, Pageable pageable);

    @Query("SELECT DISTINCT c FROM Company c LEFT JOIN FETCH c.tags")
    List<Company> findAllWithTags();
}
