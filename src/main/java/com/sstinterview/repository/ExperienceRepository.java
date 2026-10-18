package com.sstinterview.repository;

import com.sstinterview.models.Experience;
import com.sstinterview.models.ExperienceStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface ExperienceRepository extends JpaRepository<Experience, UUID> {

    List<Experience> findByCompanyId(UUID companyId);

    @Query("SELECT DISTINCT e.roundType FROM Experience e WHERE e.company.id = :companyId")
    List<com.sstinterview.models.RoundType> findDistinctRoundTypesByCompanyId(@Param("companyId") UUID companyId);

    @Query("SELECT DISTINCT e FROM Experience e LEFT JOIN e.tags t WHERE " +
           "(:companyId IS NULL OR e.company.id = :companyId) AND " +
           "(:tagId IS NULL OR t.id = :tagId) AND " +
           "(:roundTypeId IS NULL OR e.roundType.id = :roundTypeId) AND " +
           "(:userId IS NULL OR e.userId = :userId) AND " +
           "(:status IS NULL OR e.status = :status)")
    Page<Experience> findWithFilters(@Param("companyId") UUID companyId,
                                     @Param("tagId") UUID tagId,
                                     @Param("roundTypeId") UUID roundTypeId,
                                     @Param("userId") UUID userId,
                                     @Param("status") ExperienceStatus status,
                                     Pageable pageable);

    Page<Experience> findByStatus(ExperienceStatus status, Pageable pageable);

    long countByUserId(UUID userId);

    @Query("SELECT COUNT(DISTINCT e.company.id) FROM Experience e WHERE e.userId = :userId")
    long countDistinctCompaniesByUserId(@Param("userId") UUID userId);

    @Query("SELECT DISTINCT e.company FROM Experience e WHERE e.userId = :userId")
    List<com.sstinterview.models.Company> findDistinctCompaniesByUserId(@Param("userId") UUID userId);

    // Questions live in their own table now, so a keyword search has to look there
    // too — otherwise searching your own posts by a question stops matching.
    @Query("SELECT e FROM Experience e WHERE e.userId = :userId " +
           "AND (:companyId IS NULL OR e.company.id = :companyId) " +
           "AND (CAST(:search AS string) IS NULL " +
           "     OR LOWER(e.content) LIKE LOWER(CONCAT('%', CAST(:search AS string), '%')) " +
           "     OR EXISTS (SELECT 1 FROM ExperienceQuestion q WHERE q.experience = e " +
           "                AND LOWER(q.text) LIKE LOWER(CONCAT('%', CAST(:search AS string), '%'))))")
    Page<Experience> findByUserIdWithFilters(@Param("userId") UUID userId,
                                             @Param("companyId") UUID companyId,
                                             @Param("search") String search,
                                             Pageable pageable);
}
