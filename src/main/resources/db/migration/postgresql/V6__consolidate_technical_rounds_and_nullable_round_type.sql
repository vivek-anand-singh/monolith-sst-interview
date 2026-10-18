-- Step 1: Insert a single canonical "Technical Round"
INSERT INTO round_type (id, created_at, updated_at, name)
VALUES (gen_random_uuid(), NOW(), NOW(), 'Technical Round');

-- Step 2: Re-point all experiences that used Technical Round 1/2/3 to the new entry
UPDATE experience
SET round_type_id = (SELECT id FROM round_type WHERE name = 'Technical Round' ORDER BY created_at DESC LIMIT 1)
WHERE round_type_id IN (
    SELECT id FROM round_type WHERE name IN ('Technical Round 1', 'Technical Round 2', 'Technical Round 3')
);

-- Step 3: Delete the old Technical Round 1/2/3 entries
DELETE FROM round_type WHERE name IN ('Technical Round 1', 'Technical Round 2', 'Technical Round 3');

-- Step 4: Make round_type_id nullable with ON DELETE SET NULL so future deletes just unlink
-- Drop whichever FK constraint points from experience.round_type_id → round_type, regardless of its generated name
DO $$
DECLARE
    v_constraint text;
BEGIN
    SELECT conname INTO v_constraint
    FROM pg_constraint
    WHERE conrelid = 'experience'::regclass
      AND contype   = 'f'
      AND confrelid = 'round_type'::regclass;

    IF v_constraint IS NOT NULL THEN
        EXECUTE 'ALTER TABLE experience DROP CONSTRAINT ' || quote_ident(v_constraint);
    END IF;
END $$;

ALTER TABLE experience ALTER COLUMN round_type_id DROP NOT NULL;
ALTER TABLE experience ADD CONSTRAINT experience_round_type_id_fkey
    FOREIGN KEY (round_type_id) REFERENCES round_type(id) ON DELETE SET NULL;
