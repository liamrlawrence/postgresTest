
CREATE TABLE posts(
    post_id         BIGINT      PRIMARY KEY,
    post_code       TEXT        NOT NULL UNIQUE,
    user_id         BIGINT      NOT NULL REFERENCES users(user_id) ,
    content         JSONB       NOT NULL,
    deleted         BOOLEAN     NOT NULL DEFAULT FALSE,
    create_date     TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_date   TIMESTAMP   NOT NULL DEFAULT TIMESTAMP 'epoch'
);
