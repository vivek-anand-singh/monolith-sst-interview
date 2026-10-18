package com.sstinterview.repository;

import com.sstinterview.models.ExperienceQuestion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

public interface ExperienceQuestionRepository extends JpaRepository<ExperienceQuestion, UUID> {

    List<ExperienceQuestion> findByExperienceIdOrderByPositionAsc(UUID experienceId);

    void deleteByExperienceId(UUID experienceId);

    /**
     * One query for a whole page of experiences. Returns the texts themselves rather
     * than a count, so the same round trip serves both the feed snippet fallback and
     * the questions count — no N+1, no second aggregate query.
     *
     * Projects the experience id rather than the entity, so grouping never touches a
     * lazy proxy outside a session.
     */
    @Query("SELECT q.experience.id, q.text FROM ExperienceQuestion q " +
           "WHERE q.experience.id IN :ids ORDER BY q.experience.id, q.position ASC")
    List<Object[]> findTextsByExperienceIdIn(@Param("ids") List<UUID> ids);

    default Map<UUID, List<String>> questionsByExperienceIds(List<UUID> ids) {
        Map<UUID, List<String>> grouped = new LinkedHashMap<>();
        if (ids == null || ids.isEmpty()) return grouped;
        for (Object[] row : findTextsByExperienceIdIn(ids)) {
            grouped.computeIfAbsent((UUID) row[0], k -> new ArrayList<>())
                    .add((String) row[1]);
        }
        return grouped;
    }
}
