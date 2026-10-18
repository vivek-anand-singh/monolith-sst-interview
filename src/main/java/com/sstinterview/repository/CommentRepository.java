package com.sstinterview.repository;

import com.sstinterview.models.Comment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

public interface CommentRepository extends JpaRepository<Comment, UUID> {
    List<Comment> findByExperienceId(UUID experienceId);

    long countByExperienceId(UUID experienceId);

    void deleteByExperienceId(UUID experienceId);

    long countByExperienceUserId(UUID userId);

    @Query("SELECT c.experience.id, COUNT(c) FROM Comment c WHERE c.experience.id IN :ids GROUP BY c.experience.id")
    List<Object[]> countByExperienceIdIn(@Param("ids") List<UUID> ids);

    default Map<UUID, Long> countByExperienceIds(List<UUID> ids) {
        return countByExperienceIdIn(ids).stream()
                .collect(Collectors.toMap(r -> (UUID) r[0], r -> (Long) r[1]));
    }
}
