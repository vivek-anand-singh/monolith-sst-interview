-- Add status column to experience table
ALTER TABLE experience ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'PENDING';

-- Create experience_reviews table
CREATE TABLE IF NOT EXISTS experience_reviews (
    id          UUID        NOT NULL PRIMARY KEY,
    created_at  TIMESTAMPTZ NOT NULL,
    updated_at  TIMESTAMPTZ NOT NULL,
    experience_id UUID      NOT NULL REFERENCES experience(id) ON DELETE CASCADE,
    admin_id    UUID        NOT NULL,
    admin_name  VARCHAR(255) NOT NULL,
    status      VARCHAR(20) NOT NULL,
    feedback    TEXT
);

CREATE INDEX IF NOT EXISTS idx_experience_reviews_experience_id ON experience_reviews(experience_id);
CREATE INDEX IF NOT EXISTS idx_experience_status ON experience(status);
