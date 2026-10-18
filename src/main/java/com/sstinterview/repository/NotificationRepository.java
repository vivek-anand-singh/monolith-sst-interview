package com.sstinterview.repository;

import com.sstinterview.models.Notification;
import com.sstinterview.models.NotificationType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface NotificationRepository extends JpaRepository<Notification, UUID>
{
    List<Notification> findByRecipientUserIdOrderByCreatedAtDesc(UUID recipientUserId);

    List<Notification> findByTypeOrderByCreatedAtDesc(NotificationType type);
}
