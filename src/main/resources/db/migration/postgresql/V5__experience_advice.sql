-- ---------------------------------------------------------------------------
-- "Advice for the next person" becomes its own column rather than being folded
-- into `content`. With questions already in their own table, `content` now
-- means exactly one thing: the "how it went" narrative.
--
-- Nullable, so the pre-existing rows (whose whole prose stays in `content`)
-- remain valid and unchanged.
-- ---------------------------------------------------------------------------
ALTER TABLE experience ADD COLUMN IF NOT EXISTS advice TEXT;
