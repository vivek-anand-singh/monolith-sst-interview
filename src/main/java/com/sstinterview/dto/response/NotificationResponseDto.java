package com.sstinterview.dto.response;

import com.sstinterview.models.Notification;
import com.sstinterview.models.NotificationType;
import lombok.Getter;
import lombok.Setter;

import java.time.Instant;
import java.util.UUID;

@Getter
@Setter
public class NotificationResponseDto
{
    private UUID id;
    private UUID recipientUserId;
    private NotificationType type;
    private String message;
    private UUID referenceId;
    private boolean isRead;
    private Instant createdAt;

    public static NotificationResponseDto from(Notification notification)
    {
        NotificationResponseDto dto = new NotificationResponseDto();
        dto.setId(notification.getId());
        dto.setRecipientUserId(notification.getRecipientUserId());
        dto.setType(notification.getType());
        dto.setMessage(notification.getMessage());
        dto.setReferenceId(notification.getReferenceId());
        dto.setRead(notification.isRead());
        dto.setCreatedAt(notification.getCreatedAt());
        return dto;
    }
}
