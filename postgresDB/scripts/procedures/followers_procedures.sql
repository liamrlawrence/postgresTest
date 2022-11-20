CREATE OR REPLACE PROCEDURE SP_Upsert_Follower(
    _followed_user_id   BIGINT,
    _follower_user_id   BIGINT,
    _following          BOOLEAN
)
LANGUAGE PLPGSQL
AS $$
    BEGIN
        -- Constraints
        IF _followed_user_id = _follower_user_id THEN
            RAISE EXCEPTION 'users cannot follow themselves';
        END IF;

        -- Update a follower record that already exists if there is a change detected
        IF EXISTS(
            SELECT followed_user_id FROM followers
            WHERE
                followed_user_id = _followed_user_id
                AND follower_user_id = _follower_user_id
        ) THEN
            UPDATE followers
            SET
                following = _following,
                followed_date = (CASE WHEN _following = TRUE THEN CLOCK_TIMESTAMP() ELSE followed_date END),
                unfollowed_date = (CASE WHEN _following = TRUE THEN unfollowed_date ELSE CLOCK_TIMESTAMP() END)
            WHERE
                following = NOT _following
                AND followed_user_id = _followed_user_id
                AND follower_user_id = _follower_user_id;

        -- Create a new follower record
        ELSIF _following = TRUE THEN
            INSERT INTO followers(
                followed_user_id,
                follower_user_id
            ) VALUES(
                _followed_user_id,
                _follower_user_id
            );
        END IF;
    END;
$$;
