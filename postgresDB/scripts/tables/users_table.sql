CREATE TYPE user_roles_e AS ENUM(
    'guest',
    'user',
    'banned',
    'admin',
    'debug',
    'bot'
);

CREATE TYPE user_vis_e AS ENUM(
    'public',
    'private',
    'hidden'
);


CREATE TABLE users(
    user_id         BIGINT          PRIMARY KEY,
    user_code       TEXT            NOT NULL UNIQUE,
    username        TEXT            NOT NULL UNIQUE,
    nickname        TEXT            NOT NULL,
    email           TEXT            NOT NULL UNIQUE,
    password        TEXT            NOT NULL,
    role            USER_ROLES_E    NOT NULL,
    visibility      USER_VIS_E      NOT NULL,
    profile         JSONB           NOT NULL,
    settings        JSONB           NOT NULL,
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    create_date     TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_date   TIMESTAMP       NOT NULL DEFAULT TIMESTAMP 'epoch',
    modified_by     TEXT            NOT NULL,
    CHECK (3 <= LENGTH(username) AND LENGTH(username) <= 30),
    CHECK (3 <= LENGTH(email) AND LENGTH(email) <= 256),
    CHECK (LENGTH(nickname) <= 50)
);
