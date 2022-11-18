CREATE OR REPLACE PROCEDURE SP_Upsert_Follower(
    _user_id BIGINT,
    _follower_id BIGINT,
    _following BOOLEAN
)
LANGUAGE PLPGSQL
AS $$
    BEGIN
        -- Constraints
        IF _user_id = _follower_id THEN
            RAISE EXCEPTION 'Error - Users cannot follow themselves';
        END IF;

        -- Update a follower record that already exists if there is a change detected
        IF EXISTS(SELECT FROM followers WHERE user_id = _user_id AND follower_id = _follower_id) THEN
            UPDATE followers
            SET
                following = _following,
                follow_date = (CASE WHEN _following = TRUE THEN CLOCK_TIMESTAMP() ELSE follow_date END),
                unfollow_date = (CASE WHEN _following = TRUE THEN unfollow_date ELSE CLOCK_TIMESTAMP() END)
            WHERE
                following = NOT _following
                AND user_id = _user_id
                AND follower_id = _follower_id;

        -- Create a new follower record
        ELSIF _following = TRUE THEN
            INSERT INTO followers(
                user_id,
                follower_id
            ) VALUES(
                _user_id,
                _follower_id
            );
        END IF;
    END;
$$;
