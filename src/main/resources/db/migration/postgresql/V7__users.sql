-- Moved here from the old UserService, whose schema was managed by Hibernate ddl-auto=update.
-- IF NOT EXISTS so the script is a no-op when pointed at a database that already has the table.
CREATE TABLE IF NOT EXISTS users (
    id                UUID         NOT NULL PRIMARY KEY,
    email             VARCHAR(255) NOT NULL UNIQUE,
    name              VARCHAR(255) NOT NULL,
    auth_type         VARCHAR(255) NOT NULL,
    password_hash     VARCHAR(255),
    auth_provider_id  VARCHAR(255) UNIQUE,
    role              VARCHAR(255) NOT NULL,
    created_at        TIMESTAMPTZ  NOT NULL,
    updated_at        TIMESTAMPTZ  NOT NULL,
    CONSTRAINT auth_fields_check CHECK (
        (auth_type = 'PASSWORD' AND password_hash IS NOT NULL AND auth_provider_id IS NULL)
        OR
        (auth_type <> 'PASSWORD' AND password_hash IS NULL AND auth_provider_id IS NOT NULL)
    )
);
