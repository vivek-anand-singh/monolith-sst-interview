#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/.."

GREEN='\033[0;32m'
NC='\033[0m'

log() { echo -e "${GREEN}[seed-exp]${NC} $1"; }

[ -f "$ROOT_DIR/.env" ] || { echo "ERROR: .env not found at project root"; exit 1; }
set -a; . "$ROOT_DIR/.env"; set +a

source "$SCRIPT_DIR/_psql.sh"


# ── fixed UUIDs (never change — idempotency keys) ─────────────────────────────

# BCrypt hash (cost 10) for Test@1234 — same as base seed
HASH_USER='$2b$10$6lf0HVcf5qqM3fdX7WuvR.rcDTuiRdEJrGgMz46Fq8ZAXcFIc80cG'

# Additional community users
USER_RIYA="00000000-0000-0000-0000-000000000004"
USER_KUSHAL="00000000-0000-0000-0000-000000000005"
USER_ARJUN="00000000-0000-0000-0000-000000000006"
USER_MEHAK="00000000-0000-0000-0000-000000000007"
USER_ANANYA="00000000-0000-0000-0000-000000000008"
USER_VIKRAM="00000000-0000-0000-0000-000000000009"
USER_SNEHA="00000000-0000-0000-0000-000000000010"
USER_DEVANSH="00000000-0000-0000-0000-000000000011"
USER_TANVI="00000000-0000-0000-0000-000000000012"
USER_SIDDHARTH="00000000-0000-0000-0000-000000000013"
USER_ISHITA="00000000-0000-0000-0000-000000000014"
USER_ROHAN="00000000-0000-0000-0000-000000000015"
USER_AAKASH="00000000-0000-0000-0000-000000000016"
USER_RAHUL="00000000-0000-0000-0000-000000000017"

# Existing tags (from seed.sh — kept here for reference in company_tags)
TAG_DSA="10000000-0000-0000-0000-000000000001"
TAG_SYSDESIGN="10000000-0000-0000-0000-000000000002"
TAG_HR="10000000-0000-0000-0000-000000000003"
TAG_OOP="10000000-0000-0000-0000-000000000004"

# Additional tags
TAG_ARRAYS="10000000-0000-0000-0000-000000000005"
TAG_DP="10000000-0000-0000-0000-000000000006"
TAG_GRAPHS="10000000-0000-0000-0000-000000000007"
TAG_BEHAVIORAL="10000000-0000-0000-0000-000000000008"
TAG_JAVA="10000000-0000-0000-0000-000000000009"
TAG_SQL="10000000-0000-0000-0000-000000000010"
TAG_JAVASCRIPT="10000000-0000-0000-0000-000000000011"
TAG_REACT="10000000-0000-0000-0000-000000000012"
TAG_CPP="10000000-0000-0000-0000-000000000013"
TAG_MACHINE_CODING="10000000-0000-0000-0000-000000000014"
TAG_LLD="10000000-0000-0000-0000-000000000015"
TAG_HLD="10000000-0000-0000-0000-000000000016"
TAG_PRODUCT_STRATEGY="10000000-0000-0000-0000-000000000017"
TAG_CASE_STUDY="10000000-0000-0000-0000-000000000018"
TAG_ALGORITHMS="10000000-0000-0000-0000-000000000019"
TAG_LEADERSHIP="10000000-0000-0000-0000-000000000020"
TAG_TREES="10000000-0000-0000-0000-000000000021"
TAG_MATH="10000000-0000-0000-0000-000000000022"
TAG_OS="10000000-0000-0000-0000-000000000023"
TAG_FINANCE="10000000-0000-0000-0000-000000000024"
TAG_NODEJS="10000000-0000-0000-0000-000000000025"
TAG_PERFORMANCE="10000000-0000-0000-0000-000000000026"
TAG_PYTHON="10000000-0000-0000-0000-000000000027"
TAG_DBMS="10000000-0000-0000-0000-000000000028"
TAG_NETWORKING="10000000-0000-0000-0000-000000000029"
TAG_DATA_SCIENCE="10000000-0000-0000-0000-000000000030"

# Additional round types
ROUND_OA="20000000-0000-0000-0000-000000000001"
ROUND_TECH="20000000-0000-0000-0000-000000000002"
ROUND_HR="20000000-0000-0000-0000-000000000003"
ROUND_MANAGER="20000000-0000-0000-0000-000000000004"
ROUND_SYSDESIGN="20000000-0000-0000-0000-000000000005"
ROUND_BEHAVIORAL="20000000-0000-0000-0000-000000000006"

# Existing companies
COMPANY_GOOGLE="30000000-0000-0000-0000-000000000001"
COMPANY_AMAZON="30000000-0000-0000-0000-000000000002"
COMPANY_MICROSOFT="30000000-0000-0000-0000-000000000003"

# Additional companies
COMPANY_JPMORGAN="30000000-0000-0000-0000-000000000004"
COMPANY_DEUTSCHE="30000000-0000-0000-0000-000000000005"
COMPANY_GOLDMAN="30000000-0000-0000-0000-000000000006"
COMPANY_ADOBE="30000000-0000-0000-0000-000000000007"
COMPANY_SAMSUNG="30000000-0000-0000-0000-000000000008"
COMPANY_PHONEPE="30000000-0000-0000-0000-000000000009"
COMPANY_ZERODHA="30000000-0000-0000-0000-000000000010"
COMPANY_FLIPKART="30000000-0000-0000-0000-000000000011"
COMPANY_UBER="30000000-0000-0000-0000-000000000012"
COMPANY_META="30000000-0000-0000-0000-000000000013"
COMPANY_APPLE="30000000-0000-0000-0000-000000000014"
COMPANY_SALESFORCE="30000000-0000-0000-0000-000000000015"
COMPANY_RAZORPAY="30000000-0000-0000-0000-000000000016"
COMPANY_SWIGGY="30000000-0000-0000-0000-000000000017"
COMPANY_INFOSYS="30000000-0000-0000-0000-000000000018"

# Experiences (4–19 continue from seed.sh's 1–3)
EXP_4="40000000-0000-0000-0000-000000000004"
EXP_5="40000000-0000-0000-0000-000000000005"
EXP_6="40000000-0000-0000-0000-000000000006"
EXP_7="40000000-0000-0000-0000-000000000007"
EXP_8="40000000-0000-0000-0000-000000000008"
EXP_9="40000000-0000-0000-0000-000000000009"
EXP_10="40000000-0000-0000-0000-000000000010"
EXP_11="40000000-0000-0000-0000-000000000011"
EXP_12="40000000-0000-0000-0000-000000000012"
EXP_13="40000000-0000-0000-0000-000000000013"
EXP_14="40000000-0000-0000-0000-000000000014"
EXP_15="40000000-0000-0000-0000-000000000015"
EXP_16="40000000-0000-0000-0000-000000000016"
EXP_17="40000000-0000-0000-0000-000000000017"
EXP_18="40000000-0000-0000-0000-000000000018"
EXP_19="40000000-0000-0000-0000-000000000019"
# Experiences 20–30 (new companies)
EXP_20="40000000-0000-0000-0000-000000000020"
EXP_21="40000000-0000-0000-0000-000000000021"
EXP_22="40000000-0000-0000-0000-000000000022"
EXP_23="40000000-0000-0000-0000-000000000023"
EXP_24="40000000-0000-0000-0000-000000000024"
EXP_25="40000000-0000-0000-0000-000000000025"
EXP_26="40000000-0000-0000-0000-000000000026"
EXP_27="40000000-0000-0000-0000-000000000027"
EXP_28="40000000-0000-0000-0000-000000000028"
EXP_29="40000000-0000-0000-0000-000000000029"
EXP_30="40000000-0000-0000-0000-000000000030"

# Comments (4–14 continue from seed.sh's 1–3)
COMMENT_4="50000000-0000-0000-0000-000000000004"
COMMENT_5="50000000-0000-0000-0000-000000000005"
COMMENT_6="50000000-0000-0000-0000-000000000006"
COMMENT_7="50000000-0000-0000-0000-000000000007"
COMMENT_8="50000000-0000-0000-0000-000000000008"
COMMENT_9="50000000-0000-0000-0000-000000000009"
COMMENT_10="50000000-0000-0000-0000-000000000010"
COMMENT_11="50000000-0000-0000-0000-000000000011"
COMMENT_12="50000000-0000-0000-0000-000000000012"
COMMENT_13="50000000-0000-0000-0000-000000000013"
COMMENT_14="50000000-0000-0000-0000-000000000014"
# Alice's experiences — comments that trigger notifications for her
COMMENT_15="50000000-0000-0000-0000-000000000015"
COMMENT_16="50000000-0000-0000-0000-000000000016"
# Comments on new experiences (17–28)
COMMENT_17="50000000-0000-0000-0000-000000000017"
COMMENT_18="50000000-0000-0000-0000-000000000018"
COMMENT_19="50000000-0000-0000-0000-000000000019"
COMMENT_20="50000000-0000-0000-0000-000000000020"
COMMENT_21="50000000-0000-0000-0000-000000000021"
COMMENT_22="50000000-0000-0000-0000-000000000022"
COMMENT_23="50000000-0000-0000-0000-000000000023"
COMMENT_24="50000000-0000-0000-0000-000000000024"
COMMENT_25="50000000-0000-0000-0000-000000000025"
COMMENT_26="50000000-0000-0000-0000-000000000026"
COMMENT_27="50000000-0000-0000-0000-000000000027"
COMMENT_28="50000000-0000-0000-0000-000000000028"

# Replies (2–7 continue from seed.sh's 1; 8–14 are new)
REPLY_2="60000000-0000-0000-0000-000000000002"
REPLY_3="60000000-0000-0000-0000-000000000003"
REPLY_4="60000000-0000-0000-0000-000000000004"
REPLY_5="60000000-0000-0000-0000-000000000005"
REPLY_6="60000000-0000-0000-0000-000000000006"
REPLY_7="60000000-0000-0000-0000-000000000007"
REPLY_8="60000000-0000-0000-0000-000000000008"
REPLY_9="60000000-0000-0000-0000-000000000009"
REPLY_10="60000000-0000-0000-0000-000000000010"
REPLY_11="60000000-0000-0000-0000-000000000011"
REPLY_12="60000000-0000-0000-0000-000000000012"
REPLY_13="60000000-0000-0000-0000-000000000013"
REPLY_14="60000000-0000-0000-0000-000000000014"

# ── users ────────────────────────────────────────────────────────────────
log "Seeding community users..."

$PSQL -q <<-SQL
    INSERT INTO users (id, email, name, auth_type, password_hash, role, created_at, updated_at) VALUES
        ('$USER_RIYA',     'riya.sharma@example.com',    'Riya Sharma',     'PASSWORD', '${HASH_USER}', 'USER', now(), now()),
        ('$USER_KUSHAL',   'kushal.bansal@example.com',  'Kushal Bansal',   'PASSWORD', '${HASH_USER}', 'USER', now(), now()),
        ('$USER_ARJUN',    'arjun.singh@example.com',    'Arjun Singh',     'PASSWORD', '${HASH_USER}', 'USER', now(), now()),
        ('$USER_MEHAK',    'mehak.gupta@example.com',    'Mehak Gupta',     'PASSWORD', '${HASH_USER}', 'USER', now(), now()),
        ('$USER_ANANYA',   'ananya.patel@example.com',   'Ananya Patel',    'PASSWORD', '${HASH_USER}', 'USER', now(), now()),
        ('$USER_VIKRAM',   'vikram.rao@example.com',     'Vikram Rao',      'PASSWORD', '${HASH_USER}', 'USER', now(), now()),
        ('$USER_SNEHA',    'sneha.iyer@example.com',     'Sneha Iyer',      'PASSWORD', '${HASH_USER}', 'USER', now(), now()),
        ('$USER_DEVANSH',  'devansh.shah@example.com',   'Devansh Shah',    'PASSWORD', '${HASH_USER}', 'USER', now(), now()),
        ('$USER_TANVI',    'tanvi.mehta@example.com',    'Tanvi Mehta',     'PASSWORD', '${HASH_USER}', 'USER', now(), now()),
        ('$USER_SIDDHARTH','siddharth.verma@example.com','Siddharth Verma', 'PASSWORD', '${HASH_USER}', 'USER', now(), now()),
        ('$USER_ISHITA',   'ishita.roy@example.com',     'Ishita Roy',      'PASSWORD', '${HASH_USER}', 'USER', now(), now()),
        ('$USER_ROHAN',    'rohan.kapoor@example.com',   'Rohan Kapoor',    'PASSWORD', '${HASH_USER}', 'USER', now(), now()),
        ('$USER_AAKASH',   'aakash.srivastava@example.com','Aakash Srivastava','PASSWORD','${HASH_USER}','USER', now(), now()),
        ('$USER_RAHUL',    'rahul.nair@example.com',     'Rahul Nair',      'PASSWORD', '${HASH_USER}', 'USER', now(), now())
    ON CONFLICT (id) DO NOTHING;
SQL

log "Community users seeded"

# ── contentservice ────────────────────────────────────────────────────────────
log "Seeding extended tags, round types, companies, experiences, comments, replies..."

$PSQL -q <<-SQL

    -- Additional tags
    INSERT INTO tag (id, name, created_at, updated_at) VALUES
        ('$TAG_ARRAYS',          'Arrays',               now(), now()),
        ('$TAG_DP',              'Dynamic Programming',  now(), now()),
        ('$TAG_GRAPHS',          'Graphs',               now(), now()),
        ('$TAG_BEHAVIORAL',      'Behavioral',           now(), now()),
        ('$TAG_JAVA',            'Java',                 now(), now()),
        ('$TAG_SQL',             'SQL',                  now(), now()),
        ('$TAG_JAVASCRIPT',      'JavaScript',           now(), now()),
        ('$TAG_REACT',           'React',                now(), now()),
        ('$TAG_CPP',             'C++',                  now(), now()),
        ('$TAG_MACHINE_CODING',  'Machine Coding',       now(), now()),
        ('$TAG_LLD',             'Low Level Design',     now(), now()),
        ('$TAG_HLD',             'High Level Design',    now(), now()),
        ('$TAG_PRODUCT_STRATEGY','Product Strategy',     now(), now()),
        ('$TAG_CASE_STUDY',      'Case Study',           now(), now()),
        ('$TAG_ALGORITHMS',      'Algorithms',           now(), now()),
        ('$TAG_LEADERSHIP',      'Leadership Principles',now(), now()),
        ('$TAG_TREES',           'Trees',                now(), now()),
        ('$TAG_MATH',            'Math & Aptitude',      now(), now()),
        ('$TAG_OS',              'Operating Systems',    now(), now()),
        ('$TAG_FINANCE',         'Financial Modeling',   now(), now()),
        ('$TAG_NODEJS',          'Node.js',              now(), now()),
        ('$TAG_PERFORMANCE',     'Performance',          now(), now())
    ON CONFLICT (id) DO NOTHING;

    -- Additional round types
    INSERT INTO round_type (id, name, created_at, updated_at) VALUES
        ('$ROUND_SYSDESIGN', 'System Design', now(), now()),
        ('$ROUND_BEHAVIORAL','Behavioral',    now(), now())
    ON CONFLICT (id) DO NOTHING;

    -- Additional companies
    INSERT INTO company (id, name, created_at, updated_at) VALUES
        ('$COMPANY_JPMORGAN', 'JP Morgan Chase', now(), now()),
        ('$COMPANY_DEUTSCHE', 'Deutsche Bank',   now(), now()),
        ('$COMPANY_GOLDMAN',  'Goldman Sachs',   now(), now()),
        ('$COMPANY_ADOBE',    'Adobe',           now(), now()),
        ('$COMPANY_SAMSUNG',  'Samsung',         now(), now()),
        ('$COMPANY_PHONEPE',  'PhonePe',         now(), now()),
        ('$COMPANY_ZERODHA',  'Zerodha',         now(), now())
    ON CONFLICT (id) DO NOTHING;

    -- Company–tag associations for new companies
    INSERT INTO company_tags (company_id, tag_id) VALUES
        ('$COMPANY_JPMORGAN', '$TAG_CASE_STUDY'),
        ('$COMPANY_JPMORGAN', '$TAG_JAVA'),
        ('$COMPANY_JPMORGAN', '$TAG_SQL'),
        ('$COMPANY_DEUTSCHE', '$TAG_JAVA'),
        ('$COMPANY_DEUTSCHE', '$TAG_OOP'),
        ('$COMPANY_GOLDMAN',  '$TAG_DSA'),
        ('$COMPANY_GOLDMAN',  '$TAG_MATH'),
        ('$COMPANY_ADOBE',    '$TAG_CPP'),
        ('$COMPANY_ADOBE',    '$TAG_DSA'),
        ('$COMPANY_SAMSUNG',  '$TAG_DSA'),
        ('$COMPANY_SAMSUNG',  '$TAG_CPP'),
        ('$COMPANY_PHONEPE',  '$TAG_MACHINE_CODING'),
        ('$COMPANY_PHONEPE',  '$TAG_LLD'),
        ('$COMPANY_ZERODHA',  '$TAG_JAVASCRIPT'),
        ('$COMPANY_ZERODHA',  '$TAG_REACT')
    ON CONFLICT DO NOTHING;

    -- Experiences (one per former mock post)
    INSERT INTO experience (id, user_id, content, company_id, round_type_id, round_number, status, difficulty, duration_bucket, advice, created_at, updated_at) VALUES

        -- Google PM Interview — Riya Sharma
        ('$EXP_4', '$USER_RIYA',
         'It was a great experience overall. The interviews were very structured with a strong focus on product sense and behavioral rounds. Round 1 was a product design case where I had to redesign a feature for Google Maps with limited user research data. Round 2 was a metrics and success-measurement round — I had to define north-star metrics for YouTube Shorts. The interviewers were senior PMs and were probing for structured frameworks (CIRCLES, HEART) rather than memorised answers.',
         '$COMPANY_GOOGLE', '$ROUND_MANAGER', 1, 'APPROVED', 'MEDIUM', 'MIN_30_60',
         'Practice articulating trade-offs out loud.',
         now() - interval '2 hours', now() - interval '2 hours'),

        -- Google SDE Intern (2024) — Kushal Bansal
        ('$EXP_5', '$USER_KUSHAL',
         'The process had 3 rounds: Online Assessment, Technical Interviews, and HR. The OA had 2 coding questions (medium difficulty) on HackerEarth and I cleared it with a good score. Round 1 was mostly array and string-based questions — I got a sliding window variant and a prefix sum problem. Round 2 was a DP problem on interval scheduling. Interviewers were very supportive and gave hints when I was stuck. Advice: write clean code and explain your thought process before coding.',
         '$COMPANY_GOOGLE', '$ROUND_OA', 1, 'APPROVED', 'MEDIUM', 'MIN_60_90',
         'Write clean code and explain your thought process before you start coding.',
         now() - interval '2 hours', now() - interval '2 hours'),

        -- Google SDE (2023) — Arjun Singh
        ('$EXP_6', '$USER_ARJUN',
         'Had 2 technical rounds. The first round was on DSA (DP and Graphs) — I got a topological sort problem and a knapsack variant. The second round was a full System Design round where I designed a distributed rate limiter. Both rounds were challenging but the interviewers were friendly and collaborative. They care a lot about communication: talk through your approach before writing a single line. After clearing both rounds, there was a brief Googleyness & Leadership discussion.',
         '$COMPANY_GOOGLE', '$ROUND_TECH', 1, 'APPROVED', 'HARD', 'MIN_60_90',
         'Talk through your approach before writing a single line — communication counts as much as the solution here.',
         now() - interval '1 day', now() - interval '1 day'),

        -- Google HR Round (2024) — Mehak Gupta
        ('$EXP_7', '$USER_MEHAK',
         'The HR round was mainly about my resume, projects, and past experiences. The interviewer asked about my most challenging project, a time I had a conflict with a team member, and my long-term career goals. Overall a positive experience — they were genuinely curious rather than running through a checklist. Prepare your STAR stories well in advance. Also expect questions about why Google specifically.',
         '$COMPANY_GOOGLE', '$ROUND_HR', 1, 'PENDING', 'EASY', NULL,
         'Prepare your STAR stories well in advance, and have a specific answer ready for why Google.',
         now() - interval '2 days', now() - interval '2 days'),

        -- Microsoft SDE Intern — Kushal Bansal
        ('$EXP_8', '$USER_KUSHAL',
         '3 rounds in total. The OA on Codility had a DP and a Graph problem. Round 1 (Technical) focused on DSA — I was asked to implement an LRU Cache from scratch and then extend it to handle concurrency. Round 2 was a System Design discussion on designing an API rate limiter using a token bucket. Round 3 was an HR + Behavioural round. Microsoft interviewers pay close attention to OOP principles, so brush up on SOLID design.',
         '$COMPANY_MICROSOFT', '$ROUND_OA', 1, 'APPROVED', 'MEDIUM', 'MIN_60_90',
         'Brush up on SOLID design — Microsoft interviewers pay close attention to OOP principles.',
         now() - interval '4 hours', now() - interval '4 hours'),

        -- Microsoft Fullstack (2024) — Ananya Patel
        ('$EXP_9', '$USER_ANANYA',
         'Coding round on Codility followed by 2 technical rounds. Round 1 covered React internals (virtual DOM, reconciliation, hooks lifecycle) and Node.js event loop. Round 2 was a database indexing and query optimisation discussion — they asked me to analyse slow queries and suggest index strategies. The interviewers were very encouraging and gave positive signals during the discussion. Practice building end-to-end features in a limited time, not just algorithms.',
         '$COMPANY_MICROSOFT', '$ROUND_TECH', 1, 'APPROVED', 'MEDIUM', 'MIN_30_60',
         'Practice building end-to-end features in a limited time, not just algorithms.',
         now() - interval '1 day', now() - interval '1 day'),

        -- Amazon SDE — Arjun Singh
        ('$EXP_10', '$USER_ARJUN',
         'Online Assessment was tough — 2 hard-level problems in 90 minutes on HackerRank involving Arrays, Trees, and Dynamic Programming. Onsite had 4 rounds. Each round started with 15 minutes of Leadership Principles (LP) questions before moving to coding. The coding questions were Leetcode medium-hard. One round was purely System Design (design Amazon''s Cart service with eventual consistency).',
         '$COMPANY_AMAZON', '$ROUND_TECH', 1, 'APPROVED', 'HARD', 'MIN_60_90',
         'LP answers are as important as coding — follow the STAR format religiously.',
         now() - interval '6 hours', now() - interval '6 hours'),

        -- Amazon Leadership Principles — Vikram Rao
        ('$EXP_11', '$USER_VIKRAM',
         'Heavy focus on Leadership Principles (LPs) for 15–20 minutes in every single round, along with Leetcode Hard problems on Binary Trees. The system design round asked me to design Amazon''s recommendation engine. Amazon is unique in that even the SDE rounds are 50/50 coding vs LPs. The interviewers are trained to challenge your LP examples — be specific, quantify impact, and have backup stories. Do not memorise generic answers. I got Ownership, Customer Obsession, and Dive Deep the most.',
         '$COMPANY_AMAZON', '$ROUND_BEHAVIORAL', 1, 'APPROVED', 'HARD', NULL,
         'Be specific and quantify impact in your LP examples, and keep backup stories ready — the interviewers are trained to challenge them.',
         now() - interval '2 days', now() - interval '2 days'),

        -- JPMC Analyst — Sneha Iyer
        ('$EXP_12', '$USER_SNEHA',
         'The case study round was the most interesting part. I was given a real-world financial scenario and had to model revenue projections in Excel. The focus was on structured thinking and building a financial model from scratch under time pressure. Round 2 was a behavioural discussion about leadership and problem-solving. The interviewers appreciated clear communication more than perfect answers. JPMC values domain knowledge in finance — brush up on basic valuation and risk concepts.',
         '$COMPANY_JPMORGAN', '$ROUND_MANAGER', 1, 'APPROVED', 'MEDIUM', 'MIN_60_90',
         'Brush up on basic valuation and risk concepts, and prioritise clear communication over a perfect model.',
         now() - interval '8 hours', now() - interval '8 hours'),

        -- JPMC CodeForGood — Devansh Shah
        ('$EXP_13', '$USER_DEVANSH',
         'Participated in JPMC''s Code For Good hackathon, was shortlisted for full-time interviews. The interview process had 2 technical rounds. Round 1 focused on Java fundamentals — generics, collections, and exception handling. Round 2 covered Multithreading (ExecutorService, synchronized blocks) and SQL queries (window functions, joins). The panel was impressed by my hackathon project code quality. JPMC values clean Java and SQL proficiency above all else.',
         '$COMPANY_JPMORGAN', '$ROUND_TECH', 1, 'PENDING', 'MEDIUM', 'MIN_30_60',
         'Focus on clean Java and SQL proficiency — that is what the panel weighted above all else.',
         now() - interval '3 days', now() - interval '3 days'),

        -- Deutsche Bank — Tanvi Mehta
        ('$EXP_14', '$USER_TANVI',
         'OA on HackerEarth with medium-level coding questions. Technical interviews focused on Java OOP concepts (inheritance, polymorphism, design patterns), Java Streams and lambdas, memory management and garbage collection, and basic DBMS (normalisation, indexing). The interviewers were very methodical and probed deep on every concept. Deutsche Bank expects solid Java fundamentals — they are not looking for problem-solving speed but for depth of understanding.',
         '$COMPANY_DEUTSCHE', '$ROUND_TECH', 1, 'APPROVED', 'MEDIUM', 'MIN_30_60',
         'Go for depth of understanding on Java fundamentals rather than problem-solving speed.',
         now() - interval '1 day', now() - interval '1 day'),

        -- Goldman Sachs SWE — Siddharth Verma
        ('$EXP_15', '$USER_SIDDHARTH',
         'The OA had a Math & Aptitude section (quantitative reasoning, probability) along with 2 coding questions on HackerRank. Technical rounds covered Data Structures & Algorithms at a high difficulty bar and OS fundamentals (scheduling, memory, concurrency). One round was entirely focused on probability and expected value problems — something most candidates don''t prepare for. GS values depth over breadth. Be ready to go very deep on any topic you mention.',
         '$COMPANY_GOLDMAN', '$ROUND_OA', 1, 'APPROVED', 'HARD', 'MIN_60_90',
         'Prepare probability and expected value problems — most candidates skip them, and be ready to go very deep on anything you mention.',
         now() - interval '2 days', now() - interval '2 days'),

        -- Adobe Product Intern — Ishita Roy
        ('$EXP_16', '$USER_ISHITA',
         'Focused on C++ memory management, Data Structures, vector manipulation, and algorithmic problem solving. The OA had 3 problems on HackerEarth, one of which was a hard-level string processing problem. Technical rounds were in-depth on C++ — smart pointers, move semantics, RAII, and template metaprogramming basics. One round asked me to implement a basic image-processing pipeline in pseudocode. Adobe strongly prefers candidates with C++ proficiency over those who code only in Python/Java.',
         '$COMPANY_ADOBE', '$ROUND_TECH', 1, 'APPROVED', 'HARD', 'MIN_60_90',
         'Get genuinely fluent in C++ — Adobe prefers it over Python or Java.',
         now() - interval '3 days', now() - interval '3 days'),

        -- Samsung R&D — Rohan Kapoor
        ('$EXP_17', '$USER_ROHAN',
         'Samsung''s Advanced Coding Test (ACT) is 3 hours with a single very hard problem — 50 test cases with strict time limits. The problem I got was a graph traversal + recursion puzzle. Partial marks are awarded so optimise your approach iteratively. Clearing the ACT shortlists you for an onsite technical round focused on Graph traversal, recursion, and C++. The onsite interviewer also asked about Samsung''s embedded systems use cases.',
         '$COMPANY_SAMSUNG', '$ROUND_OA', 1, 'APPROVED', 'HARD', 'OVER_90',
         'Practice under strict time limits — the ACT is more of a marathon than a sprint, and partial marks reward iterative optimisation.',
         now() - interval '4 days', now() - interval '4 days'),

        -- PhonePe Backend — Aakash Srivastava
        ('$EXP_18', '$USER_AAKASH',
         'Machine Coding round (2 hours): build a rate limiter / payment gateway service from scratch in a language of your choice. The focus was on clean code, extensibility, and testability — not just a working solution. Follow-up rounds were LLD (design a payment transaction system with SOLID principles) and HLD (design UPI infrastructure at scale — 100M transactions/day). PhonePe interviewers are senior engineers who pick apart your design decisions.',
         '$COMPANY_PHONEPE', '$ROUND_TECH', 1, 'APPROVED', 'HARD', 'OVER_90',
         'Justify every architectural choice you make — the interviewers are senior engineers who pick apart your design decisions.',
         now() - interval '5 days', now() - interval '5 days'),

        -- Zerodha Frontend — Rahul Nair
        ('$EXP_19', '$USER_RAHUL',
         'Practical task: build a mini stock market dashboard using Vanilla JS (no frameworks) in 3 hours. The code was reviewed live and the interviewer asked detailed questions about my implementation choices. A follow-up discussion covered the browser rendering pipeline (critical render path, layout/paint/composite), Web APIs (WebSocket for live data, Intersection Observer, Service Workers), and JavaScript performance optimisation (memoisation, debounce, virtual scrolling). Zerodha values developers who understand the platform deeply, not just library users.',
         '$COMPANY_ZERODHA', '$ROUND_TECH', 1, 'APPROVED', 'MEDIUM', 'OVER_90',
         'Learn the browser platform itself, not just the libraries — the follow-up went straight at the rendering pipeline and Web APIs.',
         now() - interval '6 days', now() - interval '6 days')

    ON CONFLICT (id) DO NOTHING;

    -- Questions asked, derived from the prose above. Ids are random, so make the
    -- block re-runnable by clearing this experience set first.
    DELETE FROM experience_question WHERE experience_id IN (
        '$EXP_4',  '$EXP_5',  '$EXP_6',  '$EXP_7',  '$EXP_8',  '$EXP_9',  '$EXP_10',
        '$EXP_11', '$EXP_12', '$EXP_13', '$EXP_14', '$EXP_15', '$EXP_16', '$EXP_17',
        '$EXP_18', '$EXP_19'
    );

    INSERT INTO experience_question (id, created_at, updated_at, experience_id, position, text) VALUES
        -- EXP_4: Google PM
        (gen_random_uuid(), now(), now(), '$EXP_4', 0, 'Redesign a feature for Google Maps with limited user research data.'),
        (gen_random_uuid(), now(), now(), '$EXP_4', 1, 'Define north-star metrics for YouTube Shorts.'),
        -- EXP_5: Google SDE Intern
        (gen_random_uuid(), now(), now(), '$EXP_5', 0, 'A sliding window variant on arrays and strings.'),
        (gen_random_uuid(), now(), now(), '$EXP_5', 1, 'A prefix sum problem.'),
        (gen_random_uuid(), now(), now(), '$EXP_5', 2, 'A dynamic programming problem on interval scheduling.'),
        -- EXP_6: Google SDE 2023
        (gen_random_uuid(), now(), now(), '$EXP_6', 0, 'A topological sort problem.'),
        (gen_random_uuid(), now(), now(), '$EXP_6', 1, 'A knapsack variant.'),
        (gen_random_uuid(), now(), now(), '$EXP_6', 2, 'Design a distributed rate limiter.'),
        -- EXP_7: Google HR
        (gen_random_uuid(), now(), now(), '$EXP_7', 0, 'Tell me about your most challenging project.'),
        (gen_random_uuid(), now(), now(), '$EXP_7', 1, 'Describe a time you had a conflict with a team member.'),
        (gen_random_uuid(), now(), now(), '$EXP_7', 2, 'What are your long-term career goals?'),
        (gen_random_uuid(), now(), now(), '$EXP_7', 3, 'Why Google specifically?'),
        -- EXP_8: Microsoft SDE Intern
        (gen_random_uuid(), now(), now(), '$EXP_8', 0, 'Implement an LRU Cache from scratch.'),
        (gen_random_uuid(), now(), now(), '$EXP_8', 1, 'Extend the LRU Cache to handle concurrency.'),
        (gen_random_uuid(), now(), now(), '$EXP_8', 2, 'Design an API rate limiter using a token bucket.'),
        -- EXP_9: Microsoft Fullstack
        (gen_random_uuid(), now(), now(), '$EXP_9', 0, 'Explain React internals — virtual DOM, reconciliation and the hooks lifecycle.'),
        (gen_random_uuid(), now(), now(), '$EXP_9', 1, 'Explain the Node.js event loop.'),
        (gen_random_uuid(), now(), now(), '$EXP_9', 2, 'Analyse a set of slow queries and suggest index strategies.'),
        -- EXP_10: Amazon SDE
        (gen_random_uuid(), now(), now(), '$EXP_10', 0, 'Two hard-level problems in 90 minutes covering Arrays, Trees and Dynamic Programming.'),
        (gen_random_uuid(), now(), now(), '$EXP_10', 1, 'Design Amazon''s Cart service with eventual consistency.'),
        (gen_random_uuid(), now(), now(), '$EXP_10', 2, 'Fifteen minutes of Leadership Principles questions at the start of every round.'),
        -- EXP_11: Amazon LP & System Design
        (gen_random_uuid(), now(), now(), '$EXP_11', 0, 'Leetcode Hard problems on Binary Trees.'),
        (gen_random_uuid(), now(), now(), '$EXP_11', 1, 'Design Amazon''s recommendation engine.'),
        (gen_random_uuid(), now(), now(), '$EXP_11', 2, 'Leadership Principle questions on Ownership, Customer Obsession and Dive Deep.'),
        -- EXP_12: JPMC Analyst
        (gen_random_uuid(), now(), now(), '$EXP_12', 0, 'Model revenue projections in Excel for a real-world financial scenario.'),
        (gen_random_uuid(), now(), now(), '$EXP_12', 1, 'A behavioural discussion on leadership and problem-solving.'),
        -- EXP_13: JPMC CodeForGood
        (gen_random_uuid(), now(), now(), '$EXP_13', 0, 'Java fundamentals — generics, collections and exception handling.'),
        (gen_random_uuid(), now(), now(), '$EXP_13', 1, 'Multithreading with ExecutorService and synchronized blocks.'),
        (gen_random_uuid(), now(), now(), '$EXP_13', 2, 'SQL queries using window functions and joins.'),
        -- EXP_14: Deutsche Bank
        (gen_random_uuid(), now(), now(), '$EXP_14', 0, 'Java OOP concepts — inheritance, polymorphism and design patterns.'),
        (gen_random_uuid(), now(), now(), '$EXP_14', 1, 'Java Streams and lambdas.'),
        (gen_random_uuid(), now(), now(), '$EXP_14', 2, 'Java memory management and garbage collection.'),
        (gen_random_uuid(), now(), now(), '$EXP_14', 3, 'DBMS basics — normalisation and indexing.'),
        -- EXP_15: Goldman Sachs
        (gen_random_uuid(), now(), now(), '$EXP_15', 0, 'A Math & Aptitude section on quantitative reasoning and probability.'),
        (gen_random_uuid(), now(), now(), '$EXP_15', 1, 'Two coding questions on HackerRank.'),
        (gen_random_uuid(), now(), now(), '$EXP_15', 2, 'OS fundamentals — scheduling, memory and concurrency.'),
        (gen_random_uuid(), now(), now(), '$EXP_15', 3, 'Probability and expected value problems for a full round.'),
        -- EXP_16: Adobe
        (gen_random_uuid(), now(), now(), '$EXP_16', 0, 'A hard-level string processing problem.'),
        (gen_random_uuid(), now(), now(), '$EXP_16', 1, 'C++ deep dive — smart pointers, move semantics, RAII and template metaprogramming basics.'),
        (gen_random_uuid(), now(), now(), '$EXP_16', 2, 'Implement a basic image-processing pipeline in pseudocode.'),
        -- EXP_17: Samsung R&D
        (gen_random_uuid(), now(), now(), '$EXP_17', 0, 'A single very hard graph traversal and recursion puzzle — 3 hours, 50 test cases with strict time limits.'),
        (gen_random_uuid(), now(), now(), '$EXP_17', 1, 'Graph traversal, recursion and C++ questions in the onsite round.'),
        (gen_random_uuid(), now(), now(), '$EXP_17', 2, 'Samsung''s embedded systems use cases.'),
        -- EXP_18: PhonePe
        (gen_random_uuid(), now(), now(), '$EXP_18', 0, 'Build a rate limiter / payment gateway service from scratch in 2 hours, in a language of your choice.'),
        (gen_random_uuid(), now(), now(), '$EXP_18', 1, 'Design a payment transaction system using SOLID principles.'),
        (gen_random_uuid(), now(), now(), '$EXP_18', 2, 'Design UPI infrastructure at scale — 100M transactions per day.'),
        -- EXP_19: Zerodha
        (gen_random_uuid(), now(), now(), '$EXP_19', 0, 'Build a mini stock market dashboard using Vanilla JS (no frameworks) in 3 hours.'),
        (gen_random_uuid(), now(), now(), '$EXP_19', 1, 'Explain the browser rendering pipeline — critical render path, layout, paint and composite.'),
        (gen_random_uuid(), now(), now(), '$EXP_19', 2, 'Web APIs — WebSocket for live data, Intersection Observer and Service Workers.'),
        (gen_random_uuid(), now(), now(), '$EXP_19', 3, 'JavaScript performance optimisation — memoisation, debounce and virtual scrolling.')
    ON CONFLICT (id) DO NOTHING;

    -- Experience–tag associations
    INSERT INTO experience_tags (experience_id, tag_id) VALUES
        -- EXP_4: Google PM
        ('$EXP_4', '$TAG_PRODUCT_STRATEGY'),
        ('$EXP_4', '$TAG_CASE_STUDY'),
        -- EXP_5: Google SDE Intern
        ('$EXP_5', '$TAG_DSA'),
        ('$EXP_5', '$TAG_ARRAYS'),
        ('$EXP_5', '$TAG_DP'),
        -- EXP_6: Google SDE 2023
        ('$EXP_6', '$TAG_SYSDESIGN'),
        ('$EXP_6', '$TAG_GRAPHS'),
        ('$EXP_6', '$TAG_DP'),
        -- EXP_7: Google HR
        ('$EXP_7', '$TAG_BEHAVIORAL'),
        ('$EXP_7', '$TAG_HR'),
        -- EXP_8: Microsoft SDE Intern
        ('$EXP_8', '$TAG_DSA'),
        ('$EXP_8', '$TAG_SYSDESIGN'),
        ('$EXP_8', '$TAG_OOP'),
        -- EXP_9: Microsoft Fullstack
        ('$EXP_9', '$TAG_REACT'),
        ('$EXP_9', '$TAG_NODEJS'),
        ('$EXP_9', '$TAG_SYSDESIGN'),
        -- EXP_10: Amazon SDE
        ('$EXP_10', '$TAG_DSA'),
        ('$EXP_10', '$TAG_ARRAYS'),
        ('$EXP_10', '$TAG_DP'),
        -- EXP_11: Amazon Leadership
        ('$EXP_11', '$TAG_LEADERSHIP'),
        ('$EXP_11', '$TAG_SYSDESIGN'),
        ('$EXP_11', '$TAG_TREES'),
        -- EXP_12: JPMC Analyst
        ('$EXP_12', '$TAG_CASE_STUDY'),
        ('$EXP_12', '$TAG_FINANCE'),
        -- EXP_13: JPMC CodeForGood
        ('$EXP_13', '$TAG_JAVA'),
        ('$EXP_13', '$TAG_SQL'),
        -- EXP_14: Deutsche Bank
        ('$EXP_14', '$TAG_JAVA'),
        ('$EXP_14', '$TAG_OOP'),
        -- EXP_15: Goldman Sachs
        ('$EXP_15', '$TAG_DSA'),
        ('$EXP_15', '$TAG_MATH'),
        ('$EXP_15', '$TAG_OS'),
        -- EXP_16: Adobe
        ('$EXP_16', '$TAG_CPP'),
        ('$EXP_16', '$TAG_DSA'),
        ('$EXP_16', '$TAG_ALGORITHMS'),
        -- EXP_17: Samsung
        ('$EXP_17', '$TAG_DSA'),
        ('$EXP_17', '$TAG_CPP'),
        ('$EXP_17', '$TAG_GRAPHS'),
        -- EXP_18: PhonePe
        ('$EXP_18', '$TAG_MACHINE_CODING'),
        ('$EXP_18', '$TAG_LLD'),
        ('$EXP_18', '$TAG_HLD'),
        -- EXP_19: Zerodha
        ('$EXP_19', '$TAG_JAVASCRIPT'),
        ('$EXP_19', '$TAG_REACT'),
        ('$EXP_19', '$TAG_PERFORMANCE')
    ON CONFLICT DO NOTHING;

    -- Comments on the new experiences
    INSERT INTO comment (id, user_id, message, experience_id, created_at, updated_at) VALUES
        ('$COMMENT_4',  '$USER_ARJUN',   'Great write-up! Which product framework did you follow for the Maps case?',            '$EXP_4',  now(), now()),
        ('$COMMENT_5',  '$USER_MEHAK',   'Can you elaborate more on the DP round — was it a classic knapsack variant?',           '$EXP_5',  now(), now()),
        ('$COMMENT_6',  '$USER_RIYA',    'The System Design approach for rate limiter really helped me. Did they ask about Redis?','$EXP_6',  now(), now()),
        ('$COMMENT_7',  '$USER_ANANYA',  'What STAR stories worked best for the Googleyness questions?',                          '$EXP_7',  now(), now()),
        ('$COMMENT_8',  '$USER_VIKRAM',  'Was concurrency on the LRU Cache a follow-up or asked from the start?',                '$EXP_8',  now(), now()),
        ('$COMMENT_9',  '$USER_SNEHA',   'Super helpful for Microsoft Fullstack prep. What React version did they ask about?',    '$EXP_9',  now(), now()),
        ('$COMMENT_10', '$USER_DEVANSH', 'Were LP questions asked mid-coding or only at the start of each Amazon round?',        '$EXP_10', now(), now()),
        ('$COMMENT_11', '$USER_TANVI',   'I faced a similar case study round at JPMC. Great insights on the financial modelling!','$EXP_12', now(), now()),
        ('$COMMENT_12', '$USER_SIDDHARTH','Thanks for the Java Streams overview — super relevant for Deutsche Bank prep.',        '$EXP_14', now(), now()),
        ('$COMMENT_13', '$USER_ISHITA',  '3 hours for 1 question is intense! Did you get partial credit on the ACT?',            '$EXP_17', now(), now()),
        ('$COMMENT_14', '$USER_ROHAN',   'Did you use Redis for the rate limiter in the machine coding round at PhonePe?',       '$EXP_18', now(), now()),
        -- Comments on Alice's EXP_2 (Google Technical — URL shortener design) — generate NOTIF_3, NOTIF_4
        ('$COMMENT_15', '$USER_RIYA',    'How did you structure the URL shortener answer — did you cover the encoding scheme?',    '$EXP_2',  now() - interval '30 minutes', now() - interval '30 minutes'),
        ('$COMMENT_16', '$USER_KUSHAL',  'Was consistent hashing a must-know or just a bonus for L4?',                            '$EXP_2',  now() - interval '10 minutes', now() - interval '10 minutes')
    ON CONFLICT (id) DO NOTHING;

    -- Replies on the new comments
    INSERT INTO reply (id, user_id, comment_id, message, created_at, updated_at) VALUES
        ('$REPLY_2', '$USER_RIYA',    '$COMMENT_4',
         'I used the CIRCLES method — it worked well. The interviewers appreciated structured frameworks over ad-hoc answers.',
         now(), now()),
        ('$REPLY_3', '$USER_KUSHAL',  '$COMMENT_5',
         'Yes, it was a bounded knapsack variant. They also asked about the space optimisation from 2D to 1D DP.',
         now(), now()),
        ('$REPLY_4', '$USER_ARJUN',   '$COMMENT_6',
         'Yes, Redis with a sliding window counter was the answer they were looking for. Token bucket also accepted.',
         now(), now()),
        ('$REPLY_5', '$USER_KUSHAL',  '$COMMENT_8',
         'Concurrency was a follow-up after I built the basic cache. They asked me to add a read-write lock.',
         now(), now()),
        ('$REPLY_6', '$USER_ROHAN',   '$COMMENT_13',
         'Yes, partial credit saved me — I got 30/50 test cases first, then optimised to 47. Still got shortlisted.',
         now(), now()),
        -- Reply to Alice's COMMENT_3 on EXP_3 — generates NOTIF_5 (REPLY_CREATED for Alice)
        ('$REPLY_7', '$USER_RIYA',   '$COMMENT_3',
         'Yes, I had the same experience at Amazon — they always follow up on LP examples with quantified impact.',
         now() - interval '3 hours', now() - interval '3 hours')
    ON CONFLICT (id) DO NOTHING;

SQL

log "Extended experiences, comments, and replies seeded"

# ── new companies, experiences, comments, replies ─────────────────────────────
log "Seeding new companies (Flipkart, Uber, Meta, Apple, Salesforce, Razorpay, Swiggy, Infosys)..."

$PSQL -q <<-SQL

    -- Extra tags
    INSERT INTO tag (id, name, created_at, updated_at) VALUES
        ('$TAG_PYTHON',      'Python',        now(), now()),
        ('$TAG_DBMS',        'DBMS',          now(), now()),
        ('$TAG_NETWORKING',  'Networking',    now(), now()),
        ('$TAG_DATA_SCIENCE','Data Science',  now(), now())
    ON CONFLICT (id) DO NOTHING;

    -- New companies
    INSERT INTO company (id, name, created_at, updated_at) VALUES
        ('$COMPANY_FLIPKART',   'Flipkart',   now(), now()),
        ('$COMPANY_UBER',       'Uber',        now(), now()),
        ('$COMPANY_META',       'Meta',        now(), now()),
        ('$COMPANY_APPLE',      'Apple',       now(), now()),
        ('$COMPANY_SALESFORCE', 'Salesforce',  now(), now()),
        ('$COMPANY_RAZORPAY',   'Razorpay',   now(), now()),
        ('$COMPANY_SWIGGY',     'Swiggy',     now(), now()),
        ('$COMPANY_INFOSYS',    'Infosys',    now(), now())
    ON CONFLICT (id) DO NOTHING;

    -- Company–tag associations for new companies
    INSERT INTO company_tags (company_id, tag_id) VALUES
        ('$COMPANY_FLIPKART',   '$TAG_MACHINE_CODING'),
        ('$COMPANY_FLIPKART',   '$TAG_LLD'),
        ('$COMPANY_FLIPKART',   '$TAG_SYSDESIGN'),
        ('$COMPANY_UBER',       '$TAG_SYSDESIGN'),
        ('$COMPANY_UBER',       '$TAG_HLD'),
        ('$COMPANY_UBER',       '$TAG_DSA'),
        ('$COMPANY_META',       '$TAG_DSA'),
        ('$COMPANY_META',       '$TAG_GRAPHS'),
        ('$COMPANY_META',       '$TAG_ARRAYS'),
        ('$COMPANY_APPLE',      '$TAG_SYSDESIGN'),
        ('$COMPANY_APPLE',      '$TAG_CPP'),
        ('$COMPANY_APPLE',      '$TAG_BEHAVIORAL'),
        ('$COMPANY_SALESFORCE', '$TAG_JAVA'),
        ('$COMPANY_SALESFORCE', '$TAG_OOP'),
        ('$COMPANY_SALESFORCE', '$TAG_SQL'),
        ('$COMPANY_RAZORPAY',   '$TAG_LLD'),
        ('$COMPANY_RAZORPAY',   '$TAG_HLD'),
        ('$COMPANY_RAZORPAY',   '$TAG_MACHINE_CODING'),
        ('$COMPANY_SWIGGY',     '$TAG_HLD'),
        ('$COMPANY_SWIGGY',     '$TAG_MACHINE_CODING'),
        ('$COMPANY_SWIGGY',     '$TAG_PYTHON'),
        ('$COMPANY_INFOSYS',    '$TAG_JAVA'),
        ('$COMPANY_INFOSYS',    '$TAG_DBMS'),
        ('$COMPANY_INFOSYS',    '$TAG_NETWORKING')
    ON CONFLICT DO NOTHING;

    -- New experiences
    INSERT INTO experience (id, user_id, content, company_id, round_type_id, round_number, status, difficulty, duration_bucket, advice, created_at, updated_at) VALUES

        -- Flipkart SDE-1 Machine Coding — Riya Sharma
        ('$EXP_20', '$USER_RIYA',
         'The machine coding round was 90 minutes: build a parking lot system supporting multiple vehicle types, parking strategies (nearest-first, reserve), and ticket generation. Code had to compile and run with test cases provided by the interviewer. The follow-up LLD round asked me to extend it to a multi-floor, multi-lot system and discuss class hierarchy. Clean code mattered more than completion speed — I passed with a partially working floor system but very clean abstractions.',
         '$COMPANY_FLIPKART', '$ROUND_TECH', 1, 'APPROVED', 'MEDIUM', 'MIN_60_90',
         'Start with interfaces, not implementation.',
         now() - interval '1 day', now() - interval '1 day'),

        -- Flipkart System Design — Bob
        ('$EXP_21', '$USER_BOB',
         'Asked to design Flipkart''s Flash Sale infrastructure — 10M concurrent users hitting a single product page at T=0. Covered: CDN + edge caching for static content, distributed queue for order requests, Redis for inventory decrement with Lua scripts (atomic CAS), and read replicas for product catalog. The interviewer pushed on what happens when Redis crashes mid-flash-sale. Discussed two-phase commit vs saga pattern for distributed transactions. Key insight: eventual consistency is fine for catalog but ACID is required for inventory.',
         '$COMPANY_FLIPKART', '$ROUND_SYSDESIGN', 2, 'APPROVED', 'HARD', 'MIN_60_90',
         'Split your consistency requirements per subsystem — eventual consistency is fine for the catalog but inventory needs ACID.',
         now() - interval '2 days', now() - interval '2 days'),

        -- Uber SWE — Arjun Singh
        ('$EXP_22', '$USER_ARJUN',
         'Two technical rounds. Round 1 was DSA-heavy: I got a graph problem — find the shortest ride path in a dynamic grid where edges disappear over time (BFS with a time-dimension). Round 2 was a full HLD round: design Uber''s real-time driver location tracking system at 10M concurrent drivers. Covered: GPS event ingestion via Kafka, geospatial indexing with H3 hexagons, consistent hashing for driver state, and a fan-out push service for rider apps. Uber''s bar for system design is very high — they expect you to quantify everything (QPS, storage, bandwidth).',
         '$COMPANY_UBER', '$ROUND_TECH', 1, 'APPROVED', 'HARD', 'MIN_60_90',
         'Quantify everything — QPS, storage and bandwidth — the system design bar here expects real numbers.',
         now() - interval '3 days', now() - interval '3 days'),

        -- Meta SWE — Sneha Iyer
        ('$EXP_23', '$USER_SNEHA',
         'Meta had 2 pure coding rounds and 1 behavioural round. Round 1: hard graph problem — find the minimum number of edges to add to make a directed graph strongly connected. Round 2: a complex array/sliding-window problem involving a stock portfolio rebalancing constraint. Both rounds required optimal O(n log n) or better solutions — brute force gets you eliminated. The behavioural round (called "Ninja") focuses on Meta''s values: Move Fast, Be Bold. Prepare 2–3 stories per value with strong impact numbers. Do not underestimate this round.',
         '$COMPANY_META', '$ROUND_TECH', 1, 'APPROVED', 'HARD', 'MIN_30_60',
         'Prepare 2–3 stories per Meta value with strong impact numbers, and aim for optimal solutions — brute force gets you eliminated.',
         now() - interval '5 days', now() - interval '5 days'),

        -- Meta System Design — Vikram Rao
        ('$EXP_24', '$USER_VIKRAM',
         'Designed Facebook''s News Feed ranking and delivery system for 3B active users. Started with a naive fan-out-on-write approach, then the interviewer pushed on celebrity accounts (fan-out-on-read hybrid). Discussed: activity pub model, affinity ranking using ML scores (EdgeRank), timeline service sharding by user_id, Redis cluster for hot feeds, and CDN for media. The most insightful question: "How do you ensure a post from a user with 50M followers reaches all followers within 5 seconds?" — answer involves a tiered push/pull strategy.',
         '$COMPANY_META', '$ROUND_SYSDESIGN', 2, 'APPROVED', 'HARD', 'MIN_60_90',
         'Have a tiered push/pull strategy ready — the celebrity fan-out case is where this round is actually decided.',
         now() - interval '4 days', now() - interval '4 days'),

        -- Apple Software Engineer — Ananya Patel
        ('$EXP_25', '$USER_ANANYA',
         'Apple''s process is long — 5 rounds over two days. Rounds 1–2 were coding (Trees, Graphs, String manipulation, C++ memory model questions). Round 3 was a deep-dive on system design: design Apple''s iCloud sync conflict resolution — discussed CRDTs, vector clocks, and operational transformation. Round 4 was a code walkthrough of one of my own projects (they had reviewed my GitHub beforehand). Round 5 was a cross-team cultural fit discussion. Apple interviewers are detail-obsessed — expect follow-up questions on every statement you make. Never bluff.',
         '$COMPANY_APPLE', '$ROUND_TECH', 1, 'APPROVED', 'HARD', 'MIN_60_90',
         'Never bluff — they follow up on every statement, and they will have read your GitHub before the code walkthrough.',
         now() - interval '6 days', now() - interval '6 days'),

        -- Salesforce Developer — Devansh Shah
        ('$EXP_26', '$USER_DEVANSH',
         'Online Assessment on HackerRank with 3 Java coding questions (medium level). Technical rounds focused on Java Generics, Collections internals (HashMap rehashing, ConcurrentHashMap segments), Spring Boot (bean lifecycle, DI, AOP), and REST API design principles. One round covered Salesforce-specific concepts — multitenant architecture, the Salesforce metadata model, and bulk API patterns. The interviewers expected familiarity with enterprise Java — not Leetcode grinding. Knowing Spring deeply and having a Trailhead certification helped significantly.',
         '$COMPANY_SALESFORCE', '$ROUND_TECH', 1, 'PENDING', 'MEDIUM', 'MIN_30_60',
         'Know Spring deeply instead of grinding Leetcode — a Trailhead certification helps significantly too.',
         now() - interval '7 days', now() - interval '7 days'),

        -- Razorpay Backend Engineer — Mehak Gupta
        ('$EXP_27', '$USER_MEHAK',
         'Three rounds: Machine Coding, LLD, and HLD. Machine Coding (2 hours): build a payment gateway simulator with retry logic, idempotency keys, and webhook dispatch. LLD round: design a transaction dispute resolution system with state machines — interviewers were strict about SOLID principles. HLD round: design Razorpay''s payment processing pipeline at 1M TPS — discussed dual-write pattern, outbox pattern for reliable Kafka publishing, and ACID vs BASE trade-offs in financial systems. Razorpay expects deep payment domain knowledge — learn about PCI-DSS compliance basics.',
         '$COMPANY_RAZORPAY', '$ROUND_TECH', 1, 'APPROVED', 'HARD', 'OVER_90',
         'Learn the payment domain properly, PCI-DSS compliance basics included — the interviewers expect real domain depth.',
         now() - interval '8 days', now() - interval '8 days'),

        -- Swiggy Backend SDE-2 — Kushal Bansal
        ('$EXP_28', '$USER_KUSHAL',
         'Machine Coding round: build an order management system for a food delivery app — order state machine, restaurant assignment, delivery agent allocation. The follow-up HLD round asked me to design Swiggy''s real-time ETA prediction service. Discussed: Kafka for order event streaming, ML model serving via REST, geospatial indexing for delivery agents, and Redis for caching ETA windows. One interesting question: how do you handle ETA recalculation when a delivery agent''s route changes mid-delivery? Answer: event-driven re-scoring with debounce to avoid thrashing.',
         '$COMPANY_SWIGGY', '$ROUND_TECH', 1, 'APPROVED', 'HARD', 'MIN_60_90',
         'Debounce your event-driven re-scoring — recalculating the ETA on every route change thrashes the system.',
         now() - interval '9 days', now() - interval '9 days'),

        -- Infosys Specialist Programmer — Tanvi Mehta
        ('$EXP_29', '$USER_TANVI',
         'The SP track has a strong focus on Core Java and DBMS. Technical rounds covered: Java OOP fundamentals (abstraction, encapsulation, polymorphism with code examples), JDBC, SQL advanced queries (window functions, CTEs, query optimisation), and basic Networking concepts (TCP/IP, HTTP/HTTPS, REST vs SOAP). One round asked me to write a small Spring Boot REST API from scratch. The HR round discussed career goals, relocation, and learning commitment. The SP track pays significantly more than the regular SE track — prepare Java and SQL very thoroughly.',
         '$COMPANY_INFOSYS', '$ROUND_TECH', 1, 'REJECTED', 'EASY', 'MIN_30_60',
         'Prepare Java and SQL very thoroughly — the SP track pays significantly more than the regular SE track.',
         now() - interval '10 days', now() - interval '10 days'),

        -- Infosys Hackathon Path — Rahul Nair
        ('$EXP_30', '$USER_RAHUL',
         'Cleared the InfyTQ platform certification (Java + Python + Logical reasoning) which directly fast-tracks you to the final HR interview without the written test. The HR discussion was friendly — they asked about project contributions, team collaboration experiences, and knowledge of Infosys business units (BFS, Healthcare, Retail verticals). The campus interview at our college had a 3-hour online coding test with 2 Python problems (arrays + string manipulation). Practice Python over Java if you are targeting Infosys — they heavily use Python in their digital tracks.',
         '$COMPANY_INFOSYS', '$ROUND_HR', 2, 'REJECTED', NULL, NULL,
         'Clear the InfyTQ certification first — it skips the written test entirely and takes you straight to the HR round.',
         now() - interval '11 days', now() - interval '11 days')

    ON CONFLICT (id) DO NOTHING;

    -- Questions asked, derived from the prose above. Ids are random, so make the
    -- block re-runnable by clearing this experience set first.
    DELETE FROM experience_question WHERE experience_id IN (
        '$EXP_20', '$EXP_21', '$EXP_22', '$EXP_23', '$EXP_24', '$EXP_25',
        '$EXP_26', '$EXP_27', '$EXP_28', '$EXP_29', '$EXP_30'
    );

    INSERT INTO experience_question (id, created_at, updated_at, experience_id, position, text) VALUES
        -- EXP_20: Flipkart Machine Coding
        (gen_random_uuid(), now(), now(), '$EXP_20', 0, 'Build a parking lot system supporting multiple vehicle types, parking strategies (nearest-first, reserve) and ticket generation, in 90 minutes.'),
        (gen_random_uuid(), now(), now(), '$EXP_20', 1, 'Extend the parking lot to a multi-floor, multi-lot system and discuss the class hierarchy.'),
        -- EXP_21: Flipkart System Design
        (gen_random_uuid(), now(), now(), '$EXP_21', 0, 'Design Flipkart''s Flash Sale infrastructure — 10M concurrent users hitting a single product page at T=0.'),
        (gen_random_uuid(), now(), now(), '$EXP_21', 1, 'What happens when Redis crashes mid-flash-sale?'),
        (gen_random_uuid(), now(), now(), '$EXP_21', 2, 'Two-phase commit vs the saga pattern for distributed transactions.'),
        -- EXP_22: Uber SWE
        (gen_random_uuid(), now(), now(), '$EXP_22', 0, 'Find the shortest ride path in a dynamic grid where edges disappear over time.'),
        (gen_random_uuid(), now(), now(), '$EXP_22', 1, 'Design Uber''s real-time driver location tracking system at 10M concurrent drivers.'),
        -- EXP_23: Meta Coding
        (gen_random_uuid(), now(), now(), '$EXP_23', 0, 'Find the minimum number of edges to add to make a directed graph strongly connected.'),
        (gen_random_uuid(), now(), now(), '$EXP_23', 1, 'A complex array/sliding-window problem involving a stock portfolio rebalancing constraint.'),
        (gen_random_uuid(), now(), now(), '$EXP_23', 2, 'Behavioural questions mapped to Meta''s values — Move Fast, Be Bold.'),
        -- EXP_24: Meta System Design
        (gen_random_uuid(), now(), now(), '$EXP_24', 0, 'Design Facebook''s News Feed ranking and delivery system for 3B active users.'),
        (gen_random_uuid(), now(), now(), '$EXP_24', 1, 'How do you handle fan-out for celebrity accounts?'),
        (gen_random_uuid(), now(), now(), '$EXP_24', 2, 'How do you ensure a post from a user with 50M followers reaches all followers within 5 seconds?'),
        -- EXP_25: Apple SWE
        (gen_random_uuid(), now(), now(), '$EXP_25', 0, 'Coding questions on Trees, Graphs and String manipulation.'),
        (gen_random_uuid(), now(), now(), '$EXP_25', 1, 'C++ memory model questions.'),
        (gen_random_uuid(), now(), now(), '$EXP_25', 2, 'Design Apple''s iCloud sync conflict resolution — CRDTs, vector clocks and operational transformation.'),
        (gen_random_uuid(), now(), now(), '$EXP_25', 3, 'A code walkthrough of one of my own GitHub projects.'),
        -- EXP_26: Salesforce
        (gen_random_uuid(), now(), now(), '$EXP_26', 0, 'Three medium-level Java coding questions on HackerRank.'),
        (gen_random_uuid(), now(), now(), '$EXP_26', 1, 'Collections internals — HashMap rehashing and ConcurrentHashMap segments.'),
        (gen_random_uuid(), now(), now(), '$EXP_26', 2, 'Spring Boot bean lifecycle, dependency injection and AOP.'),
        (gen_random_uuid(), now(), now(), '$EXP_26', 3, 'Salesforce multitenant architecture, the metadata model and bulk API patterns.'),
        -- EXP_27: Razorpay
        (gen_random_uuid(), now(), now(), '$EXP_27', 0, 'Build a payment gateway simulator with retry logic, idempotency keys and webhook dispatch, in 2 hours.'),
        (gen_random_uuid(), now(), now(), '$EXP_27', 1, 'Design a transaction dispute resolution system with state machines.'),
        (gen_random_uuid(), now(), now(), '$EXP_27', 2, 'Design Razorpay''s payment processing pipeline at 1M TPS.'),
        -- EXP_28: Swiggy
        (gen_random_uuid(), now(), now(), '$EXP_28', 0, 'Build an order management system for a food delivery app — order state machine, restaurant assignment and delivery agent allocation.'),
        (gen_random_uuid(), now(), now(), '$EXP_28', 1, 'Design Swiggy''s real-time ETA prediction service.'),
        (gen_random_uuid(), now(), now(), '$EXP_28', 2, 'How do you handle ETA recalculation when a delivery agent''s route changes mid-delivery?'),
        -- EXP_29: Infosys SP
        (gen_random_uuid(), now(), now(), '$EXP_29', 0, 'Java OOP fundamentals — abstraction, encapsulation and polymorphism, with code examples.'),
        (gen_random_uuid(), now(), now(), '$EXP_29', 1, 'SQL advanced queries — window functions, CTEs and query optimisation.'),
        (gen_random_uuid(), now(), now(), '$EXP_29', 2, 'Networking basics — TCP/IP, HTTP/HTTPS, and REST vs SOAP.'),
        (gen_random_uuid(), now(), now(), '$EXP_29', 3, 'Write a small Spring Boot REST API from scratch.'),
        -- EXP_30: Infosys InfyTQ
        (gen_random_uuid(), now(), now(), '$EXP_30', 0, 'Two Python problems on arrays and string manipulation, in a 3-hour online coding test.'),
        (gen_random_uuid(), now(), now(), '$EXP_30', 1, 'What do you know about the Infosys business units — BFS, Healthcare and Retail verticals?'),
        (gen_random_uuid(), now(), now(), '$EXP_30', 2, 'Tell us about your project contributions and team collaboration experiences.')
    ON CONFLICT (id) DO NOTHING;

    -- Experience–tag associations for new experiences
    INSERT INTO experience_tags (experience_id, tag_id) VALUES
        -- EXP_20: Flipkart Machine Coding
        ('$EXP_20', '$TAG_MACHINE_CODING'),
        ('$EXP_20', '$TAG_LLD'),
        ('$EXP_20', '$TAG_OOP'),
        -- EXP_21: Flipkart System Design
        ('$EXP_21', '$TAG_SYSDESIGN'),
        ('$EXP_21', '$TAG_HLD'),
        -- EXP_22: Uber SWE
        ('$EXP_22', '$TAG_GRAPHS'),
        ('$EXP_22', '$TAG_HLD'),
        ('$EXP_22', '$TAG_DSA'),
        -- EXP_23: Meta Coding
        ('$EXP_23', '$TAG_DSA'),
        ('$EXP_23', '$TAG_GRAPHS'),
        ('$EXP_23', '$TAG_ARRAYS'),
        -- EXP_24: Meta System Design
        ('$EXP_24', '$TAG_SYSDESIGN'),
        ('$EXP_24', '$TAG_HLD'),
        -- EXP_25: Apple SWE
        ('$EXP_25', '$TAG_SYSDESIGN'),
        ('$EXP_25', '$TAG_CPP'),
        ('$EXP_25', '$TAG_BEHAVIORAL'),
        -- EXP_26: Salesforce
        ('$EXP_26', '$TAG_JAVA'),
        ('$EXP_26', '$TAG_OOP'),
        ('$EXP_26', '$TAG_SQL'),
        -- EXP_27: Razorpay
        ('$EXP_27', '$TAG_MACHINE_CODING'),
        ('$EXP_27', '$TAG_LLD'),
        ('$EXP_27', '$TAG_HLD'),
        -- EXP_28: Swiggy
        ('$EXP_28', '$TAG_MACHINE_CODING'),
        ('$EXP_28', '$TAG_HLD'),
        ('$EXP_28', '$TAG_SYSDESIGN'),
        -- EXP_29: Infosys SP
        ('$EXP_29', '$TAG_JAVA'),
        ('$EXP_29', '$TAG_DBMS'),
        ('$EXP_29', '$TAG_NETWORKING'),
        -- EXP_30: Infosys InfyTQ
        ('$EXP_30', '$TAG_PYTHON'),
        ('$EXP_30', '$TAG_HR')
    ON CONFLICT DO NOTHING;

    -- Comments on new experiences
    INSERT INTO comment (id, user_id, message, experience_id, created_at, updated_at) VALUES
        ('$COMMENT_17', '$USER_KUSHAL',  'Did the interviewer provide test cases upfront or did you have to write them yourself?',             '$EXP_20', now() - interval '20 hours', now() - interval '20 hours'),
        ('$COMMENT_18', '$USER_ARJUN',   'The flash sale Redis + Lua atomicity approach is exactly what I used too — great write-up!',         '$EXP_21', now() - interval '1 day',   now() - interval '1 day'),
        ('$COMMENT_19', '$USER_SNEHA',   'The H3 hexagon indexing idea for Uber is brilliant. Did they ask about H3 resolution levels?',       '$EXP_22', now() - interval '2 days',  now() - interval '2 days'),
        ('$COMMENT_20', '$USER_MEHAK',   'How long did you have per coding round? Were you allowed to look up documentation?',                 '$EXP_23', now() - interval '4 days',  now() - interval '4 days'),
        ('$COMMENT_21', '$USER_TANVI',   'The fan-out-on-write vs fan-out-on-read trade-off explanation is the clearest I''ve read. Thanks!',  '$EXP_24', now() - interval '3 days',  now() - interval '3 days'),
        ('$COMMENT_22', '$USER_RIYA',    'The CRDT mention is gold — did they expect you to implement one or just explain the concept?',       '$EXP_25', now() - interval '5 days',  now() - interval '5 days'),
        ('$COMMENT_23', '$USER_DEVANSH', 'Was the Salesforce-specific architecture knowledge required or just a bonus for the interviews?',    '$EXP_26', now() - interval '6 days',  now() - interval '6 days'),
        ('$COMMENT_24', '$USER_VIKRAM',  'The outbox pattern for reliable Kafka publishing is a great tip. Did they ask about at-least-once?', '$EXP_27', now() - interval '7 days',  now() - interval '7 days'),
        ('$COMMENT_25', '$USER_ANANYA',  'The debounce approach for ETA recalculation is clever. How did you quantify the debounce window?',  '$EXP_28', now() - interval '8 days',  now() - interval '8 days'),
        ('$COMMENT_26', '$USER_ISHITA',  'Is the SP track open for freshers or only for experienced candidates at Infosys?',                  '$EXP_29', now() - interval '9 days',  now() - interval '9 days'),
        ('$COMMENT_27', '$USER_ROHAN',   'Is InfyTQ certification valid for all Infosys roles or only specific tracks?',                      '$EXP_30', now() - interval '10 days', now() - interval '10 days'),
        ('$COMMENT_28', '$USER_SIDDHARTH','Did Flipkart give feedback after the machine coding round? Most companies don''t.',                '$EXP_20', now() - interval '18 hours', now() - interval '18 hours')
    ON CONFLICT (id) DO NOTHING;

    -- Replies on new comments
    INSERT INTO reply (id, user_id, comment_id, message, created_at, updated_at) VALUES
        ('$REPLY_8',  '$USER_RIYA',      '$COMMENT_17',
         'They provided 3 sample test cases upfront. Writing your own edge-case tests was part of the evaluation.',
         now() - interval '19 hours', now() - interval '19 hours'),
        ('$REPLY_9',  '$USER_BOB',       '$COMMENT_18',
         'Exactly. They also asked about handling race conditions when two users decrement the same SKU simultaneously.',
         now() - interval '23 hours', now() - interval '23 hours'),
        ('$REPLY_10', '$USER_ARJUN',     '$COMMENT_19',
         'Yes, they asked about resolution 9 vs 10 for city-level granularity. Resolution 9 (0.1 km²) was the sweet spot.',
         now() - interval '1 day 12 hours', now() - interval '1 day 12 hours'),
        ('$REPLY_11', '$USER_SNEHA',     '$COMMENT_20',
         '45 minutes per round. No documentation allowed — it was a shared IDE (CoderPad) with the interviewer watching live.',
         now() - interval '3 days', now() - interval '3 days'),
        ('$REPLY_12', '$USER_ANANYA',    '$COMMENT_22',
         'Conceptual explanation was enough. I drew the merge-on-read algorithm on the whiteboard and they were satisfied.',
         now() - interval '4 days', now() - interval '4 days'),
        ('$REPLY_13', '$USER_DEVANSH',   '$COMMENT_23',
         'It was a strong bonus — the interviewer visibly lit up when I mentioned the metadata model. Not required but differentiating.',
         now() - interval '5 days', now() - interval '5 days'),
        ('$REPLY_14', '$USER_ISHITA',    '$COMMENT_26',
         'It is open for freshers — the SP track is specifically a fresher-level track, you just need to clear a harder coding test.',
         now() - interval '8 days', now() - interval '8 days')
    ON CONFLICT (id) DO NOTHING;

SQL

log "New companies, experiences, comments, and replies seeded"

# ── 20 Google experiences + Airbnb / Netflix / Atlassian ─────────────────────
log "Seeding extended Google experiences and new companies..."

# New experience UUIDs (31–47)
EXP_31="40000000-0000-0000-0000-000000000031"
EXP_32="40000000-0000-0000-0000-000000000032"
EXP_33="40000000-0000-0000-0000-000000000033"
EXP_34="40000000-0000-0000-0000-000000000034"
EXP_35="40000000-0000-0000-0000-000000000035"
EXP_36="40000000-0000-0000-0000-000000000036"
EXP_37="40000000-0000-0000-0000-000000000037"
EXP_38="40000000-0000-0000-0000-000000000038"
EXP_39="40000000-0000-0000-0000-000000000039"
EXP_40="40000000-0000-0000-0000-000000000040"
EXP_41="40000000-0000-0000-0000-000000000041"
EXP_42="40000000-0000-0000-0000-000000000042"
EXP_43="40000000-0000-0000-0000-000000000043"
EXP_44="40000000-0000-0000-0000-000000000044"
EXP_45="40000000-0000-0000-0000-000000000045"
EXP_46="40000000-0000-0000-0000-000000000046"
EXP_47="40000000-0000-0000-0000-000000000047"

# New comment UUIDs (29–44)
COMMENT_29="50000000-0000-0000-0000-000000000029"
COMMENT_30="50000000-0000-0000-0000-000000000030"
COMMENT_31="50000000-0000-0000-0000-000000000031"
COMMENT_32="50000000-0000-0000-0000-000000000032"
COMMENT_33="50000000-0000-0000-0000-000000000033"
COMMENT_34="50000000-0000-0000-0000-000000000034"
COMMENT_35="50000000-0000-0000-0000-000000000035"
COMMENT_36="50000000-0000-0000-0000-000000000036"
COMMENT_37="50000000-0000-0000-0000-000000000037"
COMMENT_38="50000000-0000-0000-0000-000000000038"
COMMENT_39="50000000-0000-0000-0000-000000000039"
COMMENT_40="50000000-0000-0000-0000-000000000040"
COMMENT_41="50000000-0000-0000-0000-000000000041"
COMMENT_42="50000000-0000-0000-0000-000000000042"
COMMENT_43="50000000-0000-0000-0000-000000000043"
COMMENT_44="50000000-0000-0000-0000-000000000044"

# New reply UUIDs (15–21)
REPLY_15="60000000-0000-0000-0000-000000000015"
REPLY_16="60000000-0000-0000-0000-000000000016"
REPLY_17="60000000-0000-0000-0000-000000000017"
REPLY_18="60000000-0000-0000-0000-000000000018"
REPLY_19="60000000-0000-0000-0000-000000000019"
REPLY_20="60000000-0000-0000-0000-000000000020"
REPLY_21="60000000-0000-0000-0000-000000000021"

# New companies
COMPANY_AIRBNB="30000000-0000-0000-0000-000000000019"
COMPANY_NETFLIX="30000000-0000-0000-0000-000000000020"
COMPANY_ATLASSIAN="30000000-0000-0000-0000-000000000021"

# New tags
TAG_ML="10000000-0000-0000-0000-000000000031"
TAG_CLOUD="10000000-0000-0000-0000-000000000032"
TAG_BIGDATA="10000000-0000-0000-0000-000000000033"
TAG_DEVOPS="10000000-0000-0000-0000-000000000034"

$PSQL -q <<-SQL

    -- New tags
    INSERT INTO tag (id, name, created_at, updated_at) VALUES
        ('$TAG_ML',      'Machine Learning', now(), now()),
        ('$TAG_CLOUD',   'Cloud',            now(), now()),
        ('$TAG_BIGDATA', 'Big Data',         now(), now()),
        ('$TAG_DEVOPS',  'DevOps',           now(), now())
    ON CONFLICT (id) DO NOTHING;

    -- New companies
    INSERT INTO company (id, name, created_at, updated_at) VALUES
        ('$COMPANY_AIRBNB',    'Airbnb',    now(), now()),
        ('$COMPANY_NETFLIX',   'Netflix',   now(), now()),
        ('$COMPANY_ATLASSIAN', 'Atlassian', now(), now())
    ON CONFLICT (id) DO NOTHING;

    INSERT INTO company_tags (company_id, tag_id) VALUES
        ('$COMPANY_AIRBNB',    '$TAG_DSA'),
        ('$COMPANY_AIRBNB',    '$TAG_SYSDESIGN'),
        ('$COMPANY_AIRBNB',    '$TAG_BEHAVIORAL'),
        ('$COMPANY_NETFLIX',   '$TAG_SYSDESIGN'),
        ('$COMPANY_NETFLIX',   '$TAG_HLD'),
        ('$COMPANY_NETFLIX',   '$TAG_DEVOPS'),
        ('$COMPANY_ATLASSIAN', '$TAG_JAVA'),
        ('$COMPANY_ATLASSIAN', '$TAG_SYSDESIGN'),
        ('$COMPANY_ATLASSIAN', '$TAG_OOP')
    ON CONFLICT DO NOTHING;

    -- ── 14 additional Google experiences (takes Google total to 20) ────────────

    INSERT INTO experience (id, user_id, content, company_id, round_type_id, round_number, status, difficulty, duration_bucket, advice, created_at, updated_at) VALUES

        -- Google SWE L4 OA 2024 — Vikram Rao
        ('$EXP_31', '$USER_VIKRAM',
         'The OA was hosted on an internal Google platform — 2 questions in 90 minutes. Q1 was a hard graph problem: given a city grid where edges disappear at specific times, find the earliest arrival time using a modified Dijkstra. Q2 was a sliding window on strings — finding the minimum window substring covering all characters of a pattern with frequency constraints. Scored 13/13 on Q2 and 10/13 on Q1. Got a callback for the virtual interview loop within a week.',
         '$COMPANY_GOOGLE', '$ROUND_OA', 1, 'APPROVED', 'HARD', 'MIN_60_90',
         'The OA platform has no hints; practice pure problem solving without IDE support.',
         now() - interval '3 hours', now() - interval '3 hours'),

        -- Google ML Engineer Technical — Sneha Iyer
        ('$EXP_32', '$USER_SNEHA',
         'Round 1 was a coding round with an ML twist: implement gradient descent from scratch in Python, then extend it to mini-batch SGD with a learning rate scheduler. The interviewer asked me to analyse convergence behaviour mathematically. Round 2 was an ML system design round: design YouTube''s video recommendation system end-to-end — data collection, feature engineering, candidate generation (two-tower model), re-ranking with a pointwise LTR model, and A/B testing infrastructure. Knowing TFX pipelines and serving latency constraints was a differentiator.',
         '$COMPANY_GOOGLE', '$ROUND_TECH', 2, 'APPROVED', 'HARD', 'MIN_60_90',
         'Know TFX pipelines and serving latency constraints — that was the differentiator in the ML design round.',
         now() - interval '5 hours', now() - interval '5 hours'),

        -- Google SDE-2 System Design — Devansh Shah
        ('$EXP_33', '$USER_DEVANSH',
         'Designed Google Docs real-time collaborative editing for 10M concurrent documents. Started with naive last-write-wins, then the interviewer pushed for stronger consistency. Walked through Operational Transformation (OT) vs CRDTs — chose OT since Google Docs uses it. Discussed: WebSocket connection management at scale (load balancing with sticky sessions), the operational log for change persistence, snapshot + delta merge strategy for recovery, and conflict resolution when two users edit the same character position simultaneously. The interviewer was particularly interested in failure modes — what happens if the OT server crashes mid-session.',
         '$COMPANY_GOOGLE', '$ROUND_SYSDESIGN', 1, 'APPROVED', 'HARD', 'MIN_60_90',
         'Have failure modes ready — the interviewer was most interested in what happens if the OT server crashes mid-session.',
         now() - interval '1 day', now() - interval '1 day'),

        -- Google SRE Interview — Tanvi Mehta
        ('$EXP_34', '$USER_TANVI',
         'The SRE loop had 3 rounds: a systems troubleshooting round, a coding round, and a design round. Troubleshooting round: given a production scenario (p99 latency spike to 500ms on a serving system), walk through your debugging methodology — USE method, flamegraphs, distributed tracing. Coding: Python script to parse structured logs, aggregate error rates per endpoint, and alert on anomalies. Design: design Google''s monitoring and alerting infrastructure (similar to Monarch). Knowing Linux internals (scheduler, kernel bypass networking with DPDK), TCP tuning, and SLO/SLI/error-budget concepts is non-negotiable for SRE.',
         '$COMPANY_GOOGLE', '$ROUND_TECH', 2, 'APPROVED', 'HARD', 'MIN_60_90',
         'Linux internals, TCP tuning and SLO/SLI/error-budget concepts are non-negotiable for the SRE loop.',
         now() - interval '2 days', now() - interval '2 days'),

        -- Google Data Engineer — Siddharth Verma
        ('$EXP_35', '$USER_SIDDHARTH',
         'SQL-heavy round first: complex window functions (RANK vs DENSE_RANK vs ROW_NUMBER with partition gotchas), CTE vs subquery performance trade-offs, query execution plan analysis in BigQuery. The system design round asked me to design a real-time analytics pipeline for Google Search click-through rates — ingesting 5M events/second. Discussed: Pub/Sub for event ingestion, Dataflow (Apache Beam) for windowed aggregations, BigQuery for storage with clustering and partitioning strategies, and Looker for serving. Key insight: partitioning by _PARTITIONTIME and clustering by query string reduced cost by 80%.',
         '$COMPANY_GOOGLE', '$ROUND_TECH', 1, 'APPROVED', 'HARD', 'MIN_60_90',
         'Come with a concrete cost story — partitioning by _PARTITIONTIME and clustering by query string cut cost by 80% in my answer.',
         now() - interval '3 days', now() - interval '3 days'),

        -- Google New Grad Full Loop — Ishita Roy
        ('$EXP_36', '$USER_ISHITA',
         'Five virtual rounds over two days. Round 1: OA — 2 medium problems (arrays + binary search). Round 2: Coding — hard DP problem (minimum cost to partition an array with a constraint). Round 3: Coding — tree problem (serialize/deserialize a binary tree, then extend to N-ary). Round 4: System Design (simplified for new grad bar) — design a URL shortener with analytics. Round 5: Googleyness & Leadership — 45 minutes of behavioural questions focused on collaboration, failure, and ambiguity. All rounds were virtual with a shared Google doc — no special IDE. The bar for new grads is L3 equivalent. Practising 200+ LeetCode problems is table stakes.',
         '$COMPANY_GOOGLE', '$ROUND_OA', 1, 'APPROVED', 'HARD', 'MIN_30_60',
         'Practising 200+ LeetCode problems is table stakes, and get comfortable coding in a plain shared doc with no IDE.',
         now() - interval '4 days', now() - interval '4 days'),

        -- Google Technical Phone Screen — Rohan Kapoor
        ('$EXP_37', '$USER_ROHAN',
         'Single 45-minute phone screen before the full loop invitation. Got an interval scheduling problem: given a list of meetings with start/end times, find the minimum number of conference rooms needed (classic heap approach). The interviewer then extended it: "What if room capacities differ and meetings have attendee counts?" — required a more complex greedy matching. Communication matters as much as correctness in a phone screen: the interviewer interrupted when I started coding without explaining my approach first.',
         '$COMPANY_GOOGLE', '$ROUND_TECH', 1, 'APPROVED', 'MEDIUM', 'MIN_30_60',
         'Always talk through the algorithm fully before writing a single line — the interviewer interrupted me for coding too early.',
         now() - interval '5 days', now() - interval '5 days'),

        -- Google STEP Intern — Aakash Srivastava
        ('$EXP_38', '$USER_AAKASH',
         'STEP (Student Training in Engineering Program) targets first and second-year students. Two virtual coding interviews, each 45 minutes. Problems were LeetCode easy-to-medium level — I got a Two Sum variant and a linked list cycle detection. Interviewers were very supportive and gave hints proactively — it is not about getting the optimal solution immediately but about demonstrating logical thinking and curiosity. The process also includes a Googleyness conversation (not scored heavily). The STEP programme is a stepping stone to a full SWE internship — Google tracks STEP interns for return offers.',
         '$COMPANY_GOOGLE', '$ROUND_TECH', 1, 'PENDING', 'EASY', 'MIN_30_60',
         'Show logical thinking and curiosity rather than rushing to the optimal solution — the interviewers hand out hints proactively.',
         now() - interval '6 days', now() - interval '6 days'),

        -- Google Hiring Committee Meta-Experience — Rahul Nair
        ('$EXP_39', '$USER_RAHUL',
         'After clearing all 5 technical rounds, my packet went to the Hiring Committee (HC). The recruiter explained what HC reviews: interviewer write-ups (the detailed notes each interviewer submits, not just pass/fail), a resume summary, and references if applicable. HC can pass, reject, or ask for an additional round. My packet got an additional round request because one interviewer''s write-up was lukewarm. The extra round was a coding round — I got a hard problem on segment trees. Advice: perform consistently across all rounds. A single weak round can trigger HC scrutiny even if you aced the rest.',
         '$COMPANY_GOOGLE', '$ROUND_TECH', 3, 'APPROVED', NULL, NULL,
         'Perform consistently across all rounds — a single lukewarm write-up can trigger Hiring Committee scrutiny even if you aced the rest.',
         now() - interval '7 days', now() - interval '7 days'),

        -- Google System Design L5 — Bob Mehta
        ('$EXP_40', '$USER_BOB',
         'Senior-level design round: design Google''s global CDN for serving static assets (images, CSS, JS) to 1B daily users. Started with PoP (Point of Presence) placement strategy using anycast routing. Discussed: cache hierarchy (edge → regional → origin), cache invalidation strategies (TTL vs event-driven purge), consistent hashing for PoP selection, BGP routing and latency-aware DNS, and handling a thundering herd when a PoP fails. The interviewer pushed on the cold-start problem — when a new PoP comes online, how do you warm its cache without overwhelming the origin. Answer: request coalescing at the PoP level with a probabilistic early expiration strategy.',
         '$COMPANY_GOOGLE', '$ROUND_SYSDESIGN', 2, 'APPROVED', 'HARD', 'MIN_60_90',
         'Have a cache cold-start answer ready — request coalescing at the PoP with probabilistic early expiration is what landed.',
         now() - interval '8 days', now() - interval '8 days'),

        -- Google Googleyness Round — Alice Sharma
        ('$EXP_41', '$USER_ALICE',
         'The Googleyness round is a standalone 45-minute behavioural interview, not combined with coding. Questions I got: (1) Tell me about a time you disagreed with your manager and how you handled it. (2) Describe a project where you had to navigate ambiguity without a clear spec. (3) A time you failed and what you learned. (4) How you have helped a peer grow. Google evaluates Comfort with Ambiguity, Collaboration, and Emergent Leadership. STAR format is essential but do not make it robotic — the interviewer wants a real conversation.',
         '$COMPANY_GOOGLE', '$ROUND_BEHAVIORAL', 1, 'APPROVED', 'MEDIUM', 'MIN_30_60',
         'Prepare 5–6 stories that can flex across multiple question types, and keep the STAR delivery conversational rather than robotic.',
         now() - interval '9 days', now() - interval '9 days'),

        -- Google Coding — Trees & Recursion — Kushal Bansal
        ('$EXP_42', '$USER_KUSHAL',
         'Two problems in one 60-minute round. Problem 1: serialize and deserialize a BST (BFS-based approach, then interviewer asked about a DFS preorder alternative and space trade-offs). Problem 2: given a board of N×N cells, find all valid N-Queens placements and return the count — classic backtracking. After solving both, the interviewer asked me to analyse the time complexity precisely: N-Queens is O(N!) worst case but with pruning closer to O(N! / (N/e)^N).',
         '$COMPANY_GOOGLE', '$ROUND_TECH', 2, 'APPROVED', 'HARD', 'MIN_30_60',
         'Write clean code — Google interviewers specifically note code quality in their write-up, including variable names and edge case handling.',
         now() - interval '10 days', now() - interval '10 days'),

        -- Google Intern Host Matching — Arjun Singh
        ('$EXP_43', '$USER_ARJUN',
         'Host matching happens after you receive a provisional offer. Google sends your resume to teams who are looking for interns; teams that are interested reach out for a 30-minute matching call. I had 4 matching calls in 2 weeks. The calls are conversational — the host explains the project, asks about your interests and past work, and gauges culture fit. You can also decline a team if the project does not interest you. Teams with a strong return-offer track record are worth prioritising.',
         '$COMPANY_GOOGLE', '$ROUND_HR', 1, 'PENDING', NULL, 'MIN_30_60',
         'Research the team and the host''s published work before the call, and ask about mentorship structure and what success looks like for the project.',
         now() - interval '11 days', now() - interval '11 days'),

        -- Google APM Interview — Riya Sharma
        ('$EXP_44', '$USER_RIYA',
         'The APM loop has 4 rounds: Product Design, Product Strategy, Analytical, and Leadership. Product Design: redesign Google Maps for visually impaired users — I applied a jobs-to-be-done framework and proposed audio-first navigation with haptic waypoints. Product Strategy: if you were the PM for Google Search, what one metric would you optimise and why? (I chose search satisfaction rate over click-through rate — explained why CTR can be gamed.) Analytical: a SQL-style question on interpreting a metrics dashboard and diagnosing a 15% drop in query volume. Leadership: behavioural stories. The bar is very high — APM hires fewer than 100 people globally per year.',
         '$COMPANY_GOOGLE', '$ROUND_MANAGER', 2, 'APPROVED', 'HARD', 'MIN_30_60',
         'Pick a metric you can defend against gaming — I argued search satisfaction rate over click-through rate and had to justify why.',
         now() - interval '12 days', now() - interval '12 days'),

        -- ── 3 new company experiences ──────────────────────────────────────────

        -- Airbnb SWE Interview — Ananya Patel
        ('$EXP_45', '$USER_ANANYA',
         'Airbnb''s process: OA → 2 coding rounds → 1 system design → 1 cross-functional round. OA: 2 medium problems (arrays, strings) on HackerRank. Coding rounds were pair-programming style on a shared editor with the interviewer actively participating — they can guide you. I got a problem about merging overlapping calendar events and then a graph problem about finding connected components in a booking network. System Design: design Airbnb''s search and ranking system — property indexing, geo-search with quadtrees, personalised ranking with collaborative filtering. Cross-functional round: no coding — a case study on improving Airbnb''s host onboarding funnel with metrics to track success.',
         '$COMPANY_AIRBNB', '$ROUND_TECH', 1, 'APPROVED', 'MEDIUM', 'MIN_30_60',
         'Treat the coding rounds as real pair programming — the interviewer actively participates and will guide you if you keep talking.',
         now() - interval '14 days', now() - interval '14 days'),

        -- Netflix Senior SWE — Vikram Rao
        ('$EXP_46', '$USER_VIKRAM',
         'Netflix does not do OAs. The process starts directly with a phone screen (one coding problem, 45 min), then a virtual onsite with 5 rounds: 2 coding, 1 system design, 1 culture, 1 hiring manager. Coding: hard DP problem on video stream chunking optimisation. System design: design Netflix''s video transcoding pipeline — ingestion, ABR encoding at multiple bitrates (H.264, AV1), storage (S3-compatible), and CDN delivery with client-side adaptive streaming (HLS/DASH). Culture round is Netflix-specific — the "Keeper Test" (would your manager fight to keep you?), "Informed Captains", and the no-process philosophy. Netflix pays top of market but the culture fit bar is as high as the technical bar.',
         '$COMPANY_NETFLIX', '$ROUND_TECH', 1, 'APPROVED', 'HARD', 'MIN_30_60',
         'Prepare the culture round as seriously as the technical ones — the culture fit bar is as high as the technical bar.',
         now() - interval '16 days', now() - interval '16 days'),

        -- Atlassian SWE — Devansh Shah
        ('$EXP_47', '$USER_DEVANSH',
         'Three rounds after an OA. OA: 3 Java problems on HackerRank (medium level — collections, OOP). Round 1: live coding on JIRA''s internal platform — implement a simplified Jira board with tickets, states, and transitions using Java; focus was on clean OOP design and extensibility. Round 2: system design — design Confluence''s real-time page editing with multi-user collaboration (similar to Google Docs but Atlassian''s own variant). Round 3: behavioural + values alignment — Atlassian has 5 core values and the interviewer explicitly maps answers to them. Knowing the Atlassian product suite (Jira, Confluence, Bitbucket, Trello) contextualises your system design answers significantly.',
         '$COMPANY_ATLASSIAN', '$ROUND_TECH', 1, 'APPROVED', 'MEDIUM', 'MIN_30_60',
         'Know the Atlassian product suite — Jira, Confluence, Bitbucket, Trello — it contextualises your system design answers significantly.',
         now() - interval '18 days', now() - interval '18 days')

    ON CONFLICT (id) DO NOTHING;

    -- Questions asked, derived from the prose above. Ids are random, so make the
    -- block re-runnable by clearing this experience set first.
    DELETE FROM experience_question WHERE experience_id IN (
        '$EXP_31', '$EXP_32', '$EXP_33', '$EXP_34', '$EXP_35', '$EXP_36',
        '$EXP_37', '$EXP_38', '$EXP_39', '$EXP_40', '$EXP_41', '$EXP_42',
        '$EXP_43', '$EXP_44', '$EXP_45', '$EXP_46', '$EXP_47'
    );

    INSERT INTO experience_question (id, created_at, updated_at, experience_id, position, text) VALUES
        -- EXP_31: Google L4 OA
        (gen_random_uuid(), now(), now(), '$EXP_31', 0, 'Given a city grid where edges disappear at specific times, find the earliest arrival time using a modified Dijkstra.'),
        (gen_random_uuid(), now(), now(), '$EXP_31', 1, 'Find the minimum window substring covering all characters of a pattern with frequency constraints.'),
        -- EXP_32: Google ML Engineer
        (gen_random_uuid(), now(), now(), '$EXP_32', 0, 'Implement gradient descent from scratch in Python.'),
        (gen_random_uuid(), now(), now(), '$EXP_32', 1, 'Extend it to mini-batch SGD with a learning rate scheduler, and analyse convergence behaviour mathematically.'),
        (gen_random_uuid(), now(), now(), '$EXP_32', 2, 'Design YouTube''s video recommendation system end-to-end — data collection, feature engineering, candidate generation, re-ranking and A/B testing.'),
        -- EXP_33: Google SDE-2 System Design
        (gen_random_uuid(), now(), now(), '$EXP_33', 0, 'Design Google Docs real-time collaborative editing for 10M concurrent documents.'),
        (gen_random_uuid(), now(), now(), '$EXP_33', 1, 'Compare Operational Transformation and CRDTs, and justify your choice.'),
        (gen_random_uuid(), now(), now(), '$EXP_33', 2, 'How do you resolve conflicts when two users edit the same character position simultaneously?'),
        (gen_random_uuid(), now(), now(), '$EXP_33', 3, 'What happens if the OT server crashes mid-session?'),
        -- EXP_34: Google SRE
        (gen_random_uuid(), now(), now(), '$EXP_34', 0, 'A production p99 latency spike to 500ms on a serving system — walk through your debugging methodology.'),
        (gen_random_uuid(), now(), now(), '$EXP_34', 1, 'Write a Python script to parse structured logs, aggregate error rates per endpoint and alert on anomalies.'),
        (gen_random_uuid(), now(), now(), '$EXP_34', 2, 'Design Google''s monitoring and alerting infrastructure.'),
        -- EXP_35: Google Data Engineer
        (gen_random_uuid(), now(), now(), '$EXP_35', 0, 'Window functions — RANK vs DENSE_RANK vs ROW_NUMBER, including partition gotchas.'),
        (gen_random_uuid(), now(), now(), '$EXP_35', 1, 'CTE vs subquery performance trade-offs, and query execution plan analysis in BigQuery.'),
        (gen_random_uuid(), now(), now(), '$EXP_35', 2, 'Design a real-time analytics pipeline for Google Search click-through rates, ingesting 5M events per second.'),
        -- EXP_36: Google New Grad Full Loop
        (gen_random_uuid(), now(), now(), '$EXP_36', 0, 'Two medium problems on arrays and binary search.'),
        (gen_random_uuid(), now(), now(), '$EXP_36', 1, 'A hard DP problem — minimum cost to partition an array with a constraint.'),
        (gen_random_uuid(), now(), now(), '$EXP_36', 2, 'Serialize and deserialize a binary tree, then extend it to an N-ary tree.'),
        (gen_random_uuid(), now(), now(), '$EXP_36', 3, 'Design a URL shortener with analytics.'),
        -- EXP_37: Google Phone Screen
        (gen_random_uuid(), now(), now(), '$EXP_37', 0, 'Given a list of meetings with start/end times, find the minimum number of conference rooms needed.'),
        (gen_random_uuid(), now(), now(), '$EXP_37', 1, 'What if room capacities differ and meetings have attendee counts?'),
        -- EXP_38: Google STEP Intern
        (gen_random_uuid(), now(), now(), '$EXP_38', 0, 'A Two Sum variant.'),
        (gen_random_uuid(), now(), now(), '$EXP_38', 1, 'Linked list cycle detection.'),
        -- EXP_39: Google Hiring Committee
        (gen_random_uuid(), now(), now(), '$EXP_39', 0, 'A hard problem on segment trees, in the additional round the Hiring Committee requested.'),
        -- EXP_40: Google L5 CDN Design
        (gen_random_uuid(), now(), now(), '$EXP_40', 0, 'Design Google''s global CDN for serving static assets to 1B daily users.'),
        (gen_random_uuid(), now(), now(), '$EXP_40', 1, 'How do you handle a thundering herd when a PoP fails?'),
        (gen_random_uuid(), now(), now(), '$EXP_40', 2, 'When a new PoP comes online, how do you warm its cache without overwhelming the origin?'),
        -- EXP_41: Google Googleyness
        (gen_random_uuid(), now(), now(), '$EXP_41', 0, 'Tell me about a time you disagreed with your manager and how you handled it.'),
        (gen_random_uuid(), now(), now(), '$EXP_41', 1, 'Describe a project where you had to navigate ambiguity without a clear spec.'),
        (gen_random_uuid(), now(), now(), '$EXP_41', 2, 'Tell me about a time you failed and what you learned.'),
        (gen_random_uuid(), now(), now(), '$EXP_41', 3, 'How have you helped a peer grow?'),
        -- EXP_42: Google Trees & Recursion
        (gen_random_uuid(), now(), now(), '$EXP_42', 0, 'Serialize and deserialize a BST, then compare a DFS preorder alternative and its space trade-offs.'),
        (gen_random_uuid(), now(), now(), '$EXP_42', 1, 'Given a board of N×N cells, find all valid N-Queens placements and return the count.'),
        (gen_random_uuid(), now(), now(), '$EXP_42', 2, 'Analyse the precise time complexity of the N-Queens backtracking solution.'),
        -- EXP_43: Google Host Matching
        (gen_random_uuid(), now(), now(), '$EXP_43', 0, 'What are your interests and what have you worked on before?'),
        (gen_random_uuid(), now(), now(), '$EXP_43', 1, 'A conversational walkthrough of the team''s project and culture fit.'),
        -- EXP_44: Google APM
        (gen_random_uuid(), now(), now(), '$EXP_44', 0, 'Redesign Google Maps for visually impaired users.'),
        (gen_random_uuid(), now(), now(), '$EXP_44', 1, 'If you were the PM for Google Search, what one metric would you optimise and why?'),
        (gen_random_uuid(), now(), now(), '$EXP_44', 2, 'Interpret a metrics dashboard and diagnose a 15% drop in query volume.'),
        -- EXP_45: Airbnb SWE
        (gen_random_uuid(), now(), now(), '$EXP_45', 0, 'Merge overlapping calendar events.'),
        (gen_random_uuid(), now(), now(), '$EXP_45', 1, 'Find connected components in a booking network.'),
        (gen_random_uuid(), now(), now(), '$EXP_45', 2, 'Design Airbnb''s search and ranking system — property indexing, geo-search with quadtrees and personalised ranking.'),
        (gen_random_uuid(), now(), now(), '$EXP_45', 3, 'A case study on improving Airbnb''s host onboarding funnel, with metrics to track success.'),
        -- EXP_46: Netflix Senior SWE
        (gen_random_uuid(), now(), now(), '$EXP_46', 0, 'A hard DP problem on video stream chunking optimisation.'),
        (gen_random_uuid(), now(), now(), '$EXP_46', 1, 'Design Netflix''s video transcoding pipeline — ingestion, ABR encoding at multiple bitrates, storage and CDN delivery.'),
        (gen_random_uuid(), now(), now(), '$EXP_46', 2, 'Culture round questions on the Keeper Test and Informed Captains.'),
        -- EXP_47: Atlassian SWE
        (gen_random_uuid(), now(), now(), '$EXP_47', 0, 'Three medium-level Java problems on collections and OOP.'),
        (gen_random_uuid(), now(), now(), '$EXP_47', 1, 'Implement a simplified Jira board with tickets, states and transitions using Java.'),
        (gen_random_uuid(), now(), now(), '$EXP_47', 2, 'Design Confluence''s real-time page editing with multi-user collaboration.'),
        (gen_random_uuid(), now(), now(), '$EXP_47', 3, 'Behavioural questions mapped to Atlassian''s 5 core values.')
    ON CONFLICT (id) DO NOTHING;

    -- Experience–tag associations
    INSERT INTO experience_tags (experience_id, tag_id) VALUES
        -- EXP_31: Google L4 OA
        ('$EXP_31', '$TAG_DSA'),
        ('$EXP_31', '$TAG_GRAPHS'),
        ('$EXP_31', '$TAG_ARRAYS'),
        -- EXP_32: Google ML Engineer
        ('$EXP_32', '$TAG_ML'),
        ('$EXP_32', '$TAG_SYSDESIGN'),
        ('$EXP_32', '$TAG_PYTHON'),
        -- EXP_33: Google SDE-2 System Design
        ('$EXP_33', '$TAG_SYSDESIGN'),
        ('$EXP_33', '$TAG_HLD'),
        -- EXP_34: Google SRE
        ('$EXP_34', '$TAG_DEVOPS'),
        ('$EXP_34', '$TAG_OS'),
        ('$EXP_34', '$TAG_PYTHON'),
        -- EXP_35: Google Data Engineer
        ('$EXP_35', '$TAG_SQL'),
        ('$EXP_35', '$TAG_BIGDATA'),
        ('$EXP_35', '$TAG_CLOUD'),
        -- EXP_36: Google New Grad Full Loop
        ('$EXP_36', '$TAG_DSA'),
        ('$EXP_36', '$TAG_DP'),
        ('$EXP_36', '$TAG_TREES'),
        -- EXP_37: Google Phone Screen
        ('$EXP_37', '$TAG_DSA'),
        ('$EXP_37', '$TAG_ALGORITHMS'),
        -- EXP_38: Google STEP Intern
        ('$EXP_38', '$TAG_DSA'),
        ('$EXP_38', '$TAG_ARRAYS'),
        -- EXP_39: Google HC Meta-Experience
        ('$EXP_39', '$TAG_DSA'),
        ('$EXP_39', '$TAG_BEHAVIORAL'),
        -- EXP_40: Google L5 CDN Design
        ('$EXP_40', '$TAG_SYSDESIGN'),
        ('$EXP_40', '$TAG_HLD'),
        ('$EXP_40', '$TAG_CLOUD'),
        -- EXP_41: Google Googleyness
        ('$EXP_41', '$TAG_BEHAVIORAL'),
        ('$EXP_41', '$TAG_HR'),
        -- EXP_42: Google Trees & Recursion
        ('$EXP_42', '$TAG_TREES'),
        ('$EXP_42', '$TAG_DSA'),
        ('$EXP_42', '$TAG_ALGORITHMS'),
        -- EXP_43: Google Host Matching
        ('$EXP_43', '$TAG_HR'),
        ('$EXP_43', '$TAG_BEHAVIORAL'),
        -- EXP_44: Google APM
        ('$EXP_44', '$TAG_PRODUCT_STRATEGY'),
        ('$EXP_44', '$TAG_CASE_STUDY'),
        -- EXP_45: Airbnb SWE
        ('$EXP_45', '$TAG_DSA'),
        ('$EXP_45', '$TAG_SYSDESIGN'),
        ('$EXP_45', '$TAG_BEHAVIORAL'),
        -- EXP_46: Netflix Senior SWE
        ('$EXP_46', '$TAG_SYSDESIGN'),
        ('$EXP_46', '$TAG_HLD'),
        ('$EXP_46', '$TAG_DEVOPS'),
        -- EXP_47: Atlassian SWE
        ('$EXP_47', '$TAG_JAVA'),
        ('$EXP_47', '$TAG_OOP'),
        ('$EXP_47', '$TAG_SYSDESIGN')
    ON CONFLICT DO NOTHING;

    -- Comments on new experiences
    INSERT INTO comment (id, user_id, message, experience_id, created_at, updated_at) VALUES
        ('$COMMENT_29', '$USER_SNEHA',    'Great OA breakdown! Which platform did Google use — HackerEarth or an internal tool?',                '$EXP_31', now() - interval '2 hours',   now() - interval '2 hours'),
        ('$COMMENT_30', '$USER_ARJUN',    'Did they ask you to code gradient descent from memory or could you use NumPy?',                       '$EXP_32', now() - interval '4 hours',   now() - interval '4 hours'),
        ('$COMMENT_31', '$USER_RIYA',     'Great OT vs CRDT comparison! Did they ask you to prove OT''s correctness properties?',               '$EXP_33', now() - interval '12 hours',  now() - interval '12 hours'),
        ('$COMMENT_32', '$USER_VIKRAM',   'The USE method tip for SRE rounds is gold. Did they ask about eBPF or just classic Linux tools?',    '$EXP_34', now() - interval '1 day',     now() - interval '1 day'),
        ('$COMMENT_33', '$USER_TANVI',    'The BigQuery partitioning trick is a game changer. Which time window did you pick for partitions?',   '$EXP_35', now() - interval '2 days',    now() - interval '2 days'),
        ('$COMMENT_34', '$USER_KUSHAL',   'Did the simplified system design for new grads still include scalability discussions?',               '$EXP_36', now() - interval '3 days',    now() - interval '3 days'),
        ('$COMMENT_35', '$USER_DEVANSH',  'Was the phone screen on Google Meet with a Google Doc or did they use a different editor?',           '$EXP_37', now() - interval '4 days',    now() - interval '4 days'),
        ('$COMMENT_36', '$USER_MEHAK',    'How early should a first-year student start preparing for STEP? Is CP required?',                     '$EXP_38', now() - interval '5 days',    now() - interval '5 days'),
        ('$COMMENT_37', '$USER_ISHITA',   'The HC additional round insight is something nobody talks about. How long did the whole process take?','$EXP_39', now() - interval '6 days',    now() - interval '6 days'),
        ('$COMMENT_38', '$USER_ANANYA',   'The thundering herd / cache warm-up question is very common at senior rounds. Great answer!',         '$EXP_40', now() - interval '7 days',    now() - interval '7 days'),
        ('$COMMENT_39', '$USER_ROHAN',    'Did they push back on any of your STAR stories or was it more of a free-flowing conversation?',       '$EXP_41', now() - interval '8 days',    now() - interval '8 days'),
        ('$COMMENT_40', '$USER_SIDDHARTH','Did they give you any boilerplate for the N-Queens problem or start from a blank file?',              '$EXP_42', now() - interval '9 days',    now() - interval '9 days'),
        ('$COMMENT_41', '$USER_AAKASH',   'How many host matching calls is it normal to have? Can you reject all and still keep the offer?',     '$EXP_43', now() - interval '10 days',   now() - interval '10 days'),
        ('$COMMENT_42', '$USER_BOB',      'The APM search satisfaction vs CTR distinction is very insightful — did the interviewer agree?',      '$EXP_44', now() - interval '11 days',   now() - interval '11 days'),
        ('$COMMENT_43', '$USER_TANVI',    'Was the cross-functional Airbnb round entirely product-focused or did they ask technical questions?',  '$EXP_45', now() - interval '13 days',   now() - interval '13 days'),
        ('$COMMENT_44', '$USER_ARJUN',    'The Keeper Test round sounds intense — did they actually ask you to rate yourself against it?',       '$EXP_46', now() - interval '15 days',   now() - interval '15 days')
    ON CONFLICT (id) DO NOTHING;

    -- Replies on new comments
    INSERT INTO reply (id, user_id, comment_id, message, created_at, updated_at) VALUES
        ('$REPLY_15', '$USER_VIKRAM',  '$COMMENT_29',
         'It was an internal Google platform — looks like a plain code editor with no autocomplete. Not HackerEarth.',
         now() - interval '1 hour', now() - interval '1 hour'),
        ('$REPLY_16', '$USER_SNEHA',   '$COMMENT_30',
         'No NumPy — pure Python with lists only. They wanted to see you understand the maths, not just call a library.',
         now() - interval '3 hours', now() - interval '3 hours'),
        ('$REPLY_17', '$USER_DEVANSH', '$COMMENT_31',
         'They asked for the two OT properties (causality preservation and effect equivalence) but not a formal proof.',
         now() - interval '10 hours', now() - interval '10 hours'),
        ('$REPLY_18', '$USER_TANVI',   '$COMMENT_32',
         'Classic Linux tools (strace, perf, tcpdump). They mentioned eBPF as a follow-up but it was not required.',
         now() - interval '23 hours', now() - interval '23 hours'),
        ('$REPLY_19', '$USER_AAKASH',  '$COMMENT_36',
         'Start by sophomore year. CP is not required — clean thinking and communication matter more at the STEP level.',
         now() - interval '4 days', now() - interval '4 days'),
        ('$REPLY_20', '$USER_RAHUL',   '$COMMENT_37',
         'From first OA to final offer was 11 weeks including the extra HC round. The wait is the hardest part.',
         now() - interval '5 days', now() - interval '5 days'),
        ('$REPLY_21', '$USER_ARJUN',   '$COMMENT_41',
         'You can reject up to 3 matching offers before HR re-evaluates the offer. Most people match within 2 calls.',
         now() - interval '9 days', now() - interval '9 days')
    ON CONFLICT (id) DO NOTHING;

SQL

log "Extended Google experiences and new companies seeded"

# ── canonical 60-name tag vocabulary ─────────────────────────────────────────
# Mirrors the INSERT INTO tag block in
#   ContentService/src/main/resources/db/migration/postgresql/V4__questions_quickfacts_and_tags.sql
# Flyway will not re-run V4, so without this a `seed.sh --reset` (which TRUNCATEs
# tag) would permanently destroy the 31 names that only exist there.
#
# MUST run LAST, after every fixed-id tag insert above: tag.name is UNIQUE and
# those inserts only guard ON CONFLICT (id), so if a random-id row claimed e.g.
# 'Arrays' first, the fixed-id insert would fail on the name constraint. Running
# in this order lets the fixed-id rows win the names they own, and the remaining
# vocabulary names get fresh random ids.
#
# Not listed, and intentionally not deleted: DSA, Algorithms, HR, Performance,
# Networking — still referenced by experience_tags/company_tags rows above.
log "Seeding canonical tag vocabulary..."

$PSQL -q <<-SQL

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
SQL

log "Canonical tag vocabulary seeded"
