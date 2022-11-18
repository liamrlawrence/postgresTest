
CREATE TABLE followers(
    user_id         BIGINT      REFERENCES users(user_id),
    follower_id     BIGINT      REFERENCES users(user_id),
    following       BOOLEAN     NOT NULL DEFAULT TRUE,
    follow_date     TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    unfollow_date   TIMESTAMP   NOT NULL DEFAULT TIMESTAMP 'epoch',
    PRIMARY KEY (user_id, follower_id)
);
