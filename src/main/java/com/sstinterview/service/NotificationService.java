package com.sstinterview.service;

import com.sstinterview.dto.response.NotificationResponseDto;
import com.sstinterview.models.ExperienceStatus;

import java.util.List;
import java.util.UUID;

public interface NotificationService
{
    List<NotificationResponseDto> getMyNotifications(UUID userId);

    List<NotificationResponseDto> getAdminNotifications(String userRole);

    NotificationResponseDto markAsRead(UUID userId, UUID notificationId);

    void notifyCommentCreated(UUID commentId, UUID experienceAuthorId, String message);

    void notifyReplyCreated(UUID replyId, UUID commentAuthorId, String message);

    void notifyExperienceFlagged(UUID experienceId, UUID commentId, String reason);

    void notifyExperienceSubmitted(UUID experienceId, String companyName);

    void notifyExperienceReviewed(UUID experienceId, UUID authorUserId, ExperienceStatus status, String feedback, String companyName);
}
