-- Sessions table
CREATE TABLE sessions(
    session_id          UUID        PRIMARY KEY DEFAULT GEN_RANDOM_UUID(),
    refresh_token       UUID        NOT NULL DEFAULT GEN_RANDOM_UUID(),
    session_expiration  TIMESTAMPTZ NOT NULL DEFAULT CLOCK_TIMESTAMP() + INTERVAL '10m',
    refresh_expiration  TIMESTAMPTZ NOT NULL DEFAULT CLOCK_TIMESTAMP() + INTERVAL '30m',
    session_user_id     BIGINT      REFERENCES users(user_id),
    admin               BOOLEAN     NOT NULL,
    times_refreshed     INT         NOT NULL DEFAULT 0,
    modified_date       TIMESTAMPTZ NOT NULL DEFAULT TIMESTAMPTZ 'epoch',
    created_date        TIMESTAMPTZ NOT NULL DEFAULT CLOCK_TIMESTAMP()
);
-- Update expiration times: ALTER COLUMN refresh_expiration SET DEFAULT CLOCK_TIMESTAMP() + INTERVAL '10m';
