-- ---------------------------------------------------------------------------
-- Quick facts on experience: difficulty + duration bucket. Both nullable, so
-- every pre-existing row stays valid and simply has no value.
-- IF NOT EXISTS is deliberate: some environments already carry a `difficulty`
-- column from an earlier, un-migrated change.
-- ---------------------------------------------------------------------------
ALTER TABLE experience ADD COLUMN IF NOT EXISTS difficulty      VARCHAR(20);
ALTER TABLE experience ADD COLUMN IF NOT EXISTS duration_bucket VARCHAR(20);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'experience_difficulty_check') THEN
        ALTER TABLE experience ADD CONSTRAINT experience_difficulty_check
            CHECK (difficulty IS NULL OR difficulty IN ('EASY', 'MEDIUM', 'HARD'));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'experience_duration_bucket_check') THEN
        ALTER TABLE experience ADD CONSTRAINT experience_duration_bucket_check
            CHECK (duration_bucket IS NULL OR duration_bucket IN ('UNDER_30', 'MIN_30_60', 'MIN_60_90', 'OVER_90'));
    END IF;
END $$;

-- ---------------------------------------------------------------------------
-- Questions asked, one row per question, so the count is queryable rather
-- than parsed out of the content blob.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS experience_question (
    id            UUID        NOT NULL PRIMARY KEY,
    created_at    TIMESTAMPTZ NOT NULL,
    updated_at    TIMESTAMPTZ NOT NULL,
    experience_id UUID        NOT NULL REFERENCES experience(id) ON DELETE CASCADE,
    position      INT         NOT NULL,
    text          TEXT        NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_experience_question_experience_id ON experience_question(experience_id);

-- ---------------------------------------------------------------------------
-- Canonical tag vocabulary, shared by the submit form and the experiences
-- filter. Inserted by name with ON CONFLICT DO NOTHING, so this is idempotent
-- and leaves the tags that already exist (and their experience links) alone.
--
-- Not inserted, and intentionally NOT deleted: DSA, Algorithms, HR,
-- Performance, Networking. They are superseded by more specific tags above,
-- but existing experiences are linked to them — removing them would need a
-- remap first. They cost nothing but a little noise in the list.
-- ---------------------------------------------------------------------------
INSERT INTO tag (id, created_at, updated_at, name)
SELECT gen_random_uuid(), now(), now(), name
FROM (VALUES
    ('API Design'), ('Arrays'), ('Backtracking'), ('Behavioral'), ('Big Data'),
    ('Binary Search'), ('Bit Manipulation'), ('C++'), ('Caching'), ('Case Study'),
    ('Cloud'), ('Compensation'), ('Computer Networks'), ('Concurrency'), ('Culture Fit'),
    ('Data Science'), ('Database Design'), ('DBMS'), ('DevOps'), ('Dynamic Programming'),
    ('Financial Modeling'), ('Git'), ('Graphs'), ('Greedy'), ('Guesstimates'),
    ('Hash Maps'), ('Heaps'), ('High Level Design'), ('Java'), ('JavaScript'),
    ('Leadership Principles'), ('Linked Lists'), ('Linux'), ('Low Level Design'),
    ('Machine Coding'), ('Machine Learning'), ('Math & Aptitude'), ('Node.js'),
    ('OOP'), ('Operating Systems'), ('Product Strategy'), ('Project Discussion'),
    ('Python'), ('React'), ('Recursion'), ('Resume Deep Dive'), ('Scalability'),
    ('Sliding Window'), ('Sorting'), ('Spring Boot'), ('SQL'), ('Stacks & Queues'),
    ('Statistics'), ('Strings'), ('System Design'), ('Time & Space Complexity'),
    ('Trees'), ('Tries'), ('Two Pointers'), ('TypeScript')
) AS seed(name)
ON CONFLICT (name) DO NOTHING;
