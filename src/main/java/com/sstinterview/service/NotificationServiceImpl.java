package com.sstinterview.service;

import com.sstinterview.dto.response.NotificationResponseDto;
import com.sstinterview.models.Role;
import com.sstinterview.util.RoleUtils;
import com.sstinterview.models.Notification;
import com.sstinterview.models.ExperienceStatus;
import com.sstinterview.models.NotificationType;
import com.sstinterview.repository.NotificationRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.NoSuchElementException;

@Service
public class NotificationServiceImpl implements NotificationService
{
    private static final Logger log = LoggerFactory.getLogger(NotificationServiceImpl.class);

    private final NotificationRepository notificationRepository;
    private final UserService userService;

    public NotificationServiceImpl(NotificationRepository notificationRepository, UserService userService)
    {
        this.notificationRepository = notificationRepository;
        this.userService = userService;
    }

    @Override
    public List<NotificationResponseDto> getMyNotifications(UUID userId)
    {
        List<Notification> list = notificationRepository.findByRecipientUserIdOrderByCreatedAtDesc(userId);

        List<NotificationResponseDto> responseList = new ArrayList<>();

        for (Notification notification : list)
            responseList.add(NotificationResponseDto.from(notification));

        return responseList;
    }

    @Override
    public NotificationResponseDto markAsRead(UUID userId, UUID notificationId)
    {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new NoSuchElementException("Notification not found: " + notificationId));

        if (notification.getRecipientUserId() == null || !notification.getRecipientUserId().equals(userId))
            throw new SecurityException("Not allowed");

        notification.setRead(true);
        return NotificationResponseDto.from(notificationRepository.save(notification));
    }

    @Override
    public List<NotificationResponseDto> getAdminNotifications(String userRole)
    {
        if (!RoleUtils.hasAtLeast(userRole, Role.ADMIN))
        {
            throw new SecurityException("Only admins can view flagged notifications");
        }

        List<Notification> list = notificationRepository.findByTypeOrderByCreatedAtDesc(NotificationType.EXPERIENCE_FLAGGED);

        List<NotificationResponseDto> responseList = new ArrayList<>();

        for (Notification notification : list)
            responseList.add(NotificationResponseDto.from(notification));

        return responseList;
    }

    // The notify* methods are best-effort: a failure is logged and never fails the caller's request.

    @Override
    public void notifyCommentCreated(UUID commentId, UUID experienceAuthorId, String message)
    {
        saveSafely(() -> save(experienceAuthorId, NotificationType.COMMENT_CREATED, message, commentId));
    }

    @Override
    public void notifyReplyCreated(UUID replyId, UUID commentAuthorId, String message)
    {
        saveSafely(() -> save(commentAuthorId, NotificationType.REPLY_CREATED, message, replyId));
    }

    @Override
    public void notifyExperienceFlagged(UUID experienceId, UUID commentId, String reason)
    {
        UUID referenceId = experienceId != null ? experienceId : commentId;
        saveSafely(() -> saveForAdmins(NotificationType.EXPERIENCE_FLAGGED, "A post has been flagged. Reason: " + reason, referenceId));
    }

    @Override
    public void notifyExperienceSubmitted(UUID experienceId, String companyName)
    {
        saveSafely(() -> saveForAdmins(NotificationType.EXPERIENCE_SUBMITTED, "New experience pending review for " + companyName, experienceId));
    }

    @Override
    public void notifyExperienceReviewed(UUID experienceId, UUID authorUserId, ExperienceStatus status, String feedback, String companyName)
    {
        saveSafely(() -> {
            if (status == ExperienceStatus.APPROVED)
            {
                save(authorUserId, NotificationType.EXPERIENCE_APPROVED,
                        "Your experience for " + companyName + " has been approved and is now live!", experienceId);
                return;
            }

            String base = "Your experience for " + companyName + " was not approved.";
            String message = feedback != null && !feedback.isBlank() ? base + " Feedback: " + feedback : base;
            save(authorUserId, NotificationType.EXPERIENCE_REJECTED, message, experienceId);
        });
    }

    private void saveForAdmins(NotificationType type, String message, UUID referenceId)
    {
        List<UUID> adminIds = userService.getAdminIds();
        if (adminIds.isEmpty())
        {
            log.warn("No admin users found — skipping {} notifications", type);
            return;
        }
        for (UUID adminId : adminIds)
            save(adminId, type, message, referenceId);
    }

    private void save(UUID recipientUserId, NotificationType type, String message, UUID referenceId)
    {
        Notification notification = new Notification();
        notification.setRecipientUserId(recipientUserId);
        notification.setType(type);
        notification.setMessage(message);
        notification.setReferenceId(referenceId);
        notificationRepository.save(notification);
    }

    private void saveSafely(Runnable action)
    {
        try
        {
            action.run();
        }
        catch (Exception e)
        {
            log.warn("Notification skipped: {}", e.getMessage());
        }
    }
}
