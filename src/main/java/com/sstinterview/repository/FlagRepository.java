package com.sstinterview.repository;

import com.sstinterview.models.Flag;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface FlagRepository extends JpaRepository<Flag, UUID> {

    List<Flag> findByExperienceId(UUID experienceId);

    List<Flag> findByCommentId(UUID commentId);

    List<Flag> findByReplyId(UUID replyId);

    void deleteByExperienceId(UUID experienceId);

    void deleteByCommentId(UUID commentId);
}
