package com.sstinterview.repository;

import com.sstinterview.models.ExperienceReview;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface ExperienceReviewRepository extends JpaRepository<ExperienceReview, UUID> {
    List<ExperienceReview> findByExperienceIdOrderByCreatedAtAsc(UUID experienceId);
}
