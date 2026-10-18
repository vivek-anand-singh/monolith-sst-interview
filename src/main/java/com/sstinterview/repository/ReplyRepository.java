package com.sstinterview.repository;

import com.sstinterview.models.Reply;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface ReplyRepository extends JpaRepository<Reply, UUID> {
    List<Reply> findByCommentId(UUID commentId);

    long countByCommentId(UUID commentId);

    void deleteByCommentId(UUID commentId);
}
