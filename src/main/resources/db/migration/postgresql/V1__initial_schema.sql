CREATE TABLE IF NOT EXISTS tag (
    id          UUID        NOT NULL PRIMARY KEY,
    created_at  TIMESTAMPTZ NOT NULL,
    updated_at  TIMESTAMPTZ NOT NULL,
    name        VARCHAR     NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS company (
    id          UUID        NOT NULL PRIMARY KEY,
    created_at  TIMESTAMPTZ NOT NULL,
    updated_at  TIMESTAMPTZ NOT NULL,
    name        VARCHAR     NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS company_tags (
    company_id  UUID NOT NULL REFERENCES company(id),
    tag_id      UUID NOT NULL REFERENCES tag(id),
    PRIMARY KEY (company_id, tag_id)
);

CREATE TABLE IF NOT EXISTS round_type (
    id          UUID        NOT NULL PRIMARY KEY,
    created_at  TIMESTAMPTZ NOT NULL,
    updated_at  TIMESTAMPTZ NOT NULL,
    name        VARCHAR
);

CREATE TABLE IF NOT EXISTS experience (
    id              UUID        NOT NULL PRIMARY KEY,
    created_at      TIMESTAMPTZ NOT NULL,
    updated_at      TIMESTAMPTZ NOT NULL,
    user_id         UUID        NOT NULL,
    title           VARCHAR     NOT NULL,
    content         TEXT        NOT NULL,
    company_id      UUID        NOT NULL REFERENCES company(id),
    round_type_id   UUID        NOT NULL REFERENCES round_type(id),
    round_number    INT         NOT NULL
);

CREATE TABLE IF NOT EXISTS experience_tags (
    experience_id   UUID NOT NULL REFERENCES experience(id),
    tag_id          UUID NOT NULL REFERENCES tag(id),
    PRIMARY KEY (experience_id, tag_id)
);

CREATE TABLE IF NOT EXISTS comment (
    id              UUID        NOT NULL PRIMARY KEY,
    created_at      TIMESTAMPTZ NOT NULL,
    updated_at      TIMESTAMPTZ NOT NULL,
    user_id         UUID        NOT NULL,
    message         TEXT        NOT NULL,
    experience_id   UUID        NOT NULL REFERENCES experience(id)
);

CREATE TABLE IF NOT EXISTS reply (
    id          UUID        NOT NULL PRIMARY KEY,
    created_at  TIMESTAMPTZ NOT NULL,
    updated_at  TIMESTAMPTZ NOT NULL,
    user_id     UUID,
    message     VARCHAR,
    comment_id  UUID REFERENCES comment(id)
);

CREATE TABLE IF NOT EXISTS flag (
    id                    UUID        NOT NULL PRIMARY KEY,
    created_at            TIMESTAMPTZ NOT NULL,
    updated_at            TIMESTAMPTZ NOT NULL,
    user_id               UUID,
    experience_id         UUID REFERENCES experience(id),
    comment_id            UUID REFERENCES comment(id),
    reply_id              UUID REFERENCES reply(id),
    target_experience_id  UUID,
    reason                VARCHAR,
    status                VARCHAR,
    resolved_by_user_id   UUID,
    resolved_at           TIMESTAMPTZ
);
