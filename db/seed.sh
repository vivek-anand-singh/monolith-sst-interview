#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()   { echo -e "${GREEN}[seed]${NC} $1"; }
warn()  { echo -e "${YELLOW}[seed]${NC} $1"; }
error() { echo -e "${RED}[seed]${NC} $1"; exit 1; }

[ -f "$ROOT_DIR/.env" ] || error ".env not found at project root (cp .env.example .env)"
set -a; . "$ROOT_DIR/.env"; set +a

source "$SCRIPT_DIR/_psql.sh"

RESET=false
[ "$1" = "--reset" ] && RESET=true

# ── fixed seed UUIDs (never change these — they are the idempotency keys) ─────
# export all so seed-experiences.sh (called as subprocess) inherits them
set -a
USER_ALICE="00000000-0000-0000-0000-000000000001"
USER_BOB="00000000-0000-0000-0000-000000000002"
USER_ADMIN="00000000-0000-0000-0000-000000000003"

TAG_DSA="10000000-0000-0000-0000-000000000001"
TAG_SYSDESIGN="10000000-0000-0000-0000-000000000002"
TAG_HR="10000000-0000-0000-0000-000000000003"
TAG_OOP="10000000-0000-0000-0000-000000000004"

ROUND_OA="20000000-0000-0000-0000-000000000001"
ROUND_TECH="20000000-0000-0000-0000-000000000002"
ROUND_HR="20000000-0000-0000-0000-000000000003"
ROUND_MANAGER="20000000-0000-0000-0000-000000000004"

COMPANY_GOOGLE="30000000-0000-0000-0000-000000000001"
COMPANY_AMAZON="30000000-0000-0000-0000-000000000002"
COMPANY_MICROSOFT="30000000-0000-0000-0000-000000000003"

EXP_1="40000000-0000-0000-0000-000000000001"
EXP_2="40000000-0000-0000-0000-000000000002"
EXP_3="40000000-0000-0000-0000-000000000003"

COMMENT_1="50000000-0000-0000-0000-000000000001"
COMMENT_2="50000000-0000-0000-0000-000000000002"
COMMENT_3="50000000-0000-0000-0000-000000000003"

REPLY_1="60000000-0000-0000-0000-000000000001"

NOTIF_1="70000000-0000-0000-0000-000000000001"
NOTIF_2="70000000-0000-0000-0000-000000000002"
NOTIF_3="70000000-0000-0000-0000-000000000003"
NOTIF_4="70000000-0000-0000-0000-000000000004"
NOTIF_5="70000000-0000-0000-0000-000000000005"

# BCrypt hashes (cost 10) — do not re-generate, these are stable
# password for alice + bob: Test@1234
HASH_USER='$2b$10$6lf0HVcf5qqM3fdX7WuvR.rcDTuiRdEJrGgMz46Fq8ZAXcFIc80cG'
# password for admin: Admin@1234
HASH_ADMIN='$2b$10$hIAgrdidY62f/qCws86dMeMQfNj7l8ddYs9uFgkkg6oPjBC1Rfawy'
set +a

# ── reset ─────────────────────────────────────────────────────────────────────
if [ "$RESET" = true ]; then
    warn "--reset: wiping all content and seed users..."

    $PSQL -q <<-SQL
        TRUNCATE notification, reply, comment, flag, experience_tags, experience_question, experience, company_tags, company, round_type, tag CASCADE;

        DELETE FROM users WHERE id IN (
            '$USER_ALICE',
            '$USER_BOB',
            '$USER_ADMIN',
            '00000000-0000-0000-0000-000000000004',
            '00000000-0000-0000-0000-000000000005',
            '00000000-0000-0000-0000-000000000006',
            '00000000-0000-0000-0000-000000000007',
            '00000000-0000-0000-0000-000000000008',
            '00000000-0000-0000-0000-000000000009',
            '00000000-0000-0000-0000-000000000010',
            '00000000-0000-0000-0000-000000000011',
            '00000000-0000-0000-0000-000000000012',
            '00000000-0000-0000-0000-000000000013',
            '00000000-0000-0000-0000-000000000014',
            '00000000-0000-0000-0000-000000000015',
            '00000000-0000-0000-0000-000000000016',
            '00000000-0000-0000-0000-000000000017'
        );
SQL

    log "Reset complete"
fi

# ── first run: clear the tags migration V4 pre-inserted ───────────────────────
# The seed gives some tags fixed ids, but V4 already inserted tags with the same names under
# random ids, and tag.name is UNIQUE. On the first seed, drop the unreferenced tags; the full
# vocabulary is re-inserted at the end of seed-experiences.sh. Later runs skip this.
$PSQL -q <<-SQL
    DELETE FROM tag
    WHERE NOT EXISTS (SELECT 1 FROM tag WHERE id = '$TAG_DSA')
      AND id NOT IN (SELECT tag_id FROM company_tags UNION SELECT tag_id FROM experience_tags);
SQL

# ── users ─────────────────────────────────────────────────────────────────────
log "Seeding users..."

$PSQL -q <<-SQL
    INSERT INTO users (id, email, name, auth_type, password_hash, role, created_at, updated_at) VALUES
        ('$USER_ALICE', 'alice@example.com', 'Alice Sharma', 'PASSWORD', '${HASH_USER}',  'USER',  now(), now()),
        ('$USER_BOB',   'bob@example.com',   'Bob Mehta',    'PASSWORD', '${HASH_USER}',  'USER',  now(), now()),
        ('$USER_ADMIN', 'admin@example.com', 'Admin User',   'PASSWORD', '${HASH_ADMIN}', 'ADMIN', now(), now())
    ON CONFLICT (id) DO NOTHING;
SQL

log "Users seeded"

# ── content ───────────────────────────────────────────────────────────────────
log "Seeding content..."

$PSQL -q <<-SQL
    -- Tags with fixed ids, referenced directly by experience_tags/company_tags.
    -- The full 60-name canonical vocabulary is seeded at the END of
    -- seed-experiences.sh — it must run after every fixed-id tag insert, because
    -- tag.name is UNIQUE and those inserts only guard ON CONFLICT (id).
    INSERT INTO tag (id, name, created_at, updated_at) VALUES
        ('$TAG_DSA',       'DSA',           now(), now()),
        ('$TAG_SYSDESIGN', 'System Design', now(), now()),
        ('$TAG_HR',        'HR',            now(), now()),
        ('$TAG_OOP',       'OOP',           now(), now())
    ON CONFLICT (id) DO NOTHING;

    INSERT INTO round_type (id, name, created_at, updated_at) VALUES
        ('$ROUND_OA',      'Online Assessment', now(), now()),
        ('$ROUND_TECH',    'Technical Round',   now(), now()),
        ('$ROUND_HR',      'HR Round',          now(), now()),
        ('$ROUND_MANAGER', 'Managerial Round',  now(), now())
    ON CONFLICT (id) DO NOTHING;

    INSERT INTO company (id, name, created_at, updated_at) VALUES
        ('$COMPANY_GOOGLE',    'Google',    now(), now()),
        ('$COMPANY_AMAZON',    'Amazon',    now(), now()),
        ('$COMPANY_MICROSOFT', 'Microsoft', now(), now())
    ON CONFLICT (id) DO NOTHING;

    INSERT INTO company_tags (company_id, tag_id) VALUES
        ('$COMPANY_GOOGLE',    '$TAG_DSA'),
        ('$COMPANY_GOOGLE',    '$TAG_SYSDESIGN'),
        ('$COMPANY_AMAZON',    '$TAG_DSA'),
        ('$COMPANY_AMAZON',    '$TAG_OOP'),
        ('$COMPANY_MICROSOFT', '$TAG_SYSDESIGN'),
        ('$COMPANY_MICROSOFT', '$TAG_HR')
    ON CONFLICT DO NOTHING;

    INSERT INTO experience (id, user_id, content, company_id, round_type_id, round_number, status, difficulty, duration_bucket, advice, created_at, updated_at) VALUES
        ('$EXP_1', '$USER_ALICE',
         'The OA had 2 medium LC problems to solve in 90 minutes. First was a graph BFS problem (Rotting Oranges), second involved dynamic programming on intervals (Burst Balloons).',
         '$COMPANY_GOOGLE', '$ROUND_OA', 1, 'APPROVED', 'MEDIUM', 'MIN_60_90',
         'Practise grid BFS and interval DP together — both showed up back to back in the same 90 minutes.',
         now(), now()),

        ('$EXP_2', '$USER_ALICE',
         'Interviewer asked me to design a URL shortener. Discussed trade-offs between SQL and NoSQL, sharding strategies, and consistent hashing. Felt like a standard L4 system design bar.',
         '$COMPANY_GOOGLE', '$ROUND_TECH', 2, 'APPROVED', 'MEDIUM', 'MIN_30_60',
         'Be ready to defend your SQL vs NoSQL and sharding choices — the trade-off discussion was most of the round.',
         now(), now()),

        ('$EXP_3', '$USER_BOB',
         'One coding question on trees (Lowest Common Ancestor) and one system design on Amazon cart service. Leadership principle questions were woven in throughout the interview.',
         '$COMPANY_AMAZON', '$ROUND_TECH', 1, 'APPROVED', 'MEDIUM', 'MIN_60_90',
         'Expect leadership principle questions woven through the technical discussion rather than saved for a separate round.',
         now(), now())
    ON CONFLICT (id) DO NOTHING;

    -- Questions asked, derived from the prose above. Ids are random, so make the
    -- block re-runnable by clearing this experience set first.
    DELETE FROM experience_question WHERE experience_id IN ('$EXP_1', '$EXP_2', '$EXP_3');

    INSERT INTO experience_question (id, created_at, updated_at, experience_id, position, text) VALUES
        (gen_random_uuid(), now(), now(), '$EXP_1', 0, 'Rotting Oranges — multi-source BFS on a grid to find how long all oranges take to rot.'),
        (gen_random_uuid(), now(), now(), '$EXP_1', 1, 'Burst Balloons — dynamic programming on intervals.'),

        (gen_random_uuid(), now(), now(), '$EXP_2', 0, 'Design a URL shortener, covering SQL vs NoSQL trade-offs, sharding strategies and consistent hashing.'),

        (gen_random_uuid(), now(), now(), '$EXP_3', 0, 'Find the Lowest Common Ancestor of two nodes in a binary tree.'),
        (gen_random_uuid(), now(), now(), '$EXP_3', 1, 'Design the Amazon cart service.')
    ON CONFLICT (id) DO NOTHING;

    INSERT INTO experience_tags (experience_id, tag_id) VALUES
        ('$EXP_1', '$TAG_DSA'),
        ('$EXP_2', '$TAG_SYSDESIGN'),
        ('$EXP_3', '$TAG_DSA'),
        ('$EXP_3', '$TAG_OOP')
    ON CONFLICT DO NOTHING;

    INSERT INTO comment (id, user_id, message, experience_id, created_at, updated_at) VALUES
        ('$COMMENT_1', '$USER_BOB',   'Great write-up! Which LC problems came up in the OA?',  '$EXP_1', now(), now()),
        ('$COMMENT_2', '$USER_ADMIN', 'Did the interviewer ask about time complexity explicitly?', '$EXP_1', now(), now()),
        ('$COMMENT_3', '$USER_ALICE', 'How many LP questions did they squeeze in total?',        '$EXP_3', now(), now())
    ON CONFLICT (id) DO NOTHING;

    INSERT INTO reply (id, user_id, comment_id, message, created_at, updated_at) VALUES
        ('$REPLY_1', '$USER_ALICE', '$COMMENT_1',
         'One was Rotting Oranges (BFS) and the other was Burst Balloons (interval DP).',
         now(), now())
    ON CONFLICT (id) DO NOTHING;
SQL

log "Content seeded"

# ── notifications ─────────────────────────────────────────────────────────────
log "Seeding notifications..."

$PSQL -q <<-SQL
    -- Alice (EXP_1 author) gets notified when Bob and Admin comment on her experience
    INSERT INTO notification (id, recipient_user_id, type, message, reference_id, is_read, created_at, updated_at) VALUES
        ('$NOTIF_1', '$USER_ALICE', 'COMMENT_CREATED',
         'Great write-up! Which LC problems came up in the OA?',
         '$COMMENT_1', false, now() - interval '2 hours', now() - interval '2 hours'),
        ('$NOTIF_2', '$USER_ALICE', 'COMMENT_CREATED',
         'Did the interviewer ask about time complexity explicitly?',
         '$COMMENT_2', false, now() - interval '1 hour', now() - interval '1 hour'),
        -- Alice gets notified when Riya and Kushal comment on EXP_2 (added in seed-experiences.sh)
        ('$NOTIF_3', '$USER_ALICE', 'COMMENT_CREATED',
         'How did you structure the URL shortener answer — did you cover the encoding scheme?',
         '50000000-0000-0000-0000-000000000015', false, now() - interval '30 minutes', now() - interval '30 minutes'),
        ('$NOTIF_4', '$USER_ALICE', 'COMMENT_CREATED',
         'Was consistent hashing a must-know or just a bonus for L4?',
         '50000000-0000-0000-0000-000000000016', false, now() - interval '10 minutes', now() - interval '10 minutes'),
        -- Alice gets notified when Riya replies to her comment on EXP_3 (added in seed-experiences.sh)
        ('$NOTIF_5', '$USER_ALICE', 'REPLY_CREATED',
         'Yes, I had the same experience at Amazon — they always follow up on LP examples with quantified impact.',
         '60000000-0000-0000-0000-000000000007', true, now() - interval '3 hours', now() - interval '3 hours')
    ON CONFLICT (id) DO NOTHING;
SQL

log "Notifications seeded"

# ── extended community data ───────────────────────────────────────────────────
"$SCRIPT_DIR/seed-experiences.sh"

# Optional: make your own Google account an admin as part of seeding, so the pending/rejected
# seed experiences can be moderated straight away:  SEED_ADMIN_EMAIL=you@gmail.com ./db/seed.sh
if [ -n "$SEED_ADMIN_EMAIL" ]; then
    "$SCRIPT_DIR/make-admin.sh" "$SEED_ADMIN_EMAIL" || warn "Log in with Google once, then re-run to promote $SEED_ADMIN_EMAIL"
fi

log ""
log "Seed users are authors/commenters only: login is Google-only, so they cannot sign in."
log "  alice@example.com (USER), bob@example.com (USER), admin@example.com (ADMIN), + 14 more"
log "To call the API as them, use the dev tokens below. To make your own Google account an admin:"
log "  ./db/make-admin.sh you@gmail.com   (after logging in once)  — or: SEED_ADMIN_EMAIL=you@gmail.com ./db/seed.sh"
log "Print a token any time: ./db/dev-token.sh alice|bob|admin"

if [ -z "$JWT_SECRET" ]; then
    warn "JWT_SECRET not found in .env — skipping dev token generation"
else
    _b64url() { openssl base64 -e -A | tr '+' '-' | tr '/' '_' | tr -d '='; }

    # dev_token <user-id> <role>  → HS256 JWT, valid 1 year, same shape the app issues
    dev_token() {
        local header payload sig now exp
        header=$(printf '{"alg":"HS256","typ":"JWT"}' | _b64url)
        now=$(date +%s); exp=$((now + 31536000))
        payload=$(printf '{"sub":"%s","role":"%s","iat":%d,"exp":%d}' "$1" "$2" "$now" "$exp" | _b64url)
        sig=$(printf '%s' "${header}.${payload}" | openssl dgst -sha256 -hmac "$JWT_SECRET" -binary | _b64url)
        echo "${header}.${payload}.${sig}"
    }

    log ""
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log "  DEV TOKENS (valid 1 year) — use as:  Authorization: Bearer <token>"
    log ""
    log "  alice (USER):"
    log "  $(dev_token "$USER_ALICE" USER)"
    log ""
    log "  admin (ADMIN):"
    log "  $(dev_token "$USER_ADMIN" ADMIN)"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi
