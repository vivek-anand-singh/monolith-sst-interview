package com.sstinterview.models;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Entity
@Getter
@Setter
@Table(
    name = "notification",
    check = @CheckConstraint(
        name = "notification_type_check",
        constraint = "type IN ('COMMENT_CREATED','REPLY_CREATED','EXPERIENCE_FLAGGED','EXPERIENCE_SUBMITTED','EXPERIENCE_APPROVED','EXPERIENCE_REJECTED')"
    )
)
public class Notification extends BaseModel
{
    private UUID recipientUserId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private NotificationType type;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String message;

    private UUID referenceId;

    @Column(nullable = false)
    private boolean isRead = false;
}
