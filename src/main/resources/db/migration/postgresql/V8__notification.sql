CREATE TABLE IF NOT EXISTS notification (
    id                  UUID        NOT NULL PRIMARY KEY,
    created_at          TIMESTAMPTZ NOT NULL,
    updated_at          TIMESTAMPTZ NOT NULL,
    recipient_user_id   UUID,
    type                VARCHAR(50) NOT NULL,
    message             TEXT        NOT NULL,
    reference_id        UUID,
    is_read             BOOLEAN     NOT NULL DEFAULT FALSE,
    CONSTRAINT notification_type_check CHECK (type IN (
        'COMMENT_CREATED',
        'REPLY_CREATED',
        'EXPERIENCE_FLAGGED',
        'EXPERIENCE_SUBMITTED',
        'EXPERIENCE_APPROVED',
        'EXPERIENCE_REJECTED'
    ))
);

CREATE INDEX IF NOT EXISTS idx_notification_recipient_user_id ON notification(recipient_user_id);
CREATE INDEX IF NOT EXISTS idx_notification_type ON notification(type);
CREATE INDEX IF NOT EXISTS idx_notification_created_at ON notification(created_at DESC);
