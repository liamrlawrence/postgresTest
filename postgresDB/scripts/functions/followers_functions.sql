-- Get the users.user_id of the followers of _user_id
CREATE OR REPLACE FUNCTION FN_Get_Followers(
    _user_id BIGINT
) RETURNS TABLE(followers_user_id BIGINT)
LANGUAGE SQL
AS $$
    SELECT follower_id FROM followers
    WHERE user_id = _user_id;
$$;


-- Get the users.user_id of everyone _user_id is following
CREATE OR REPLACE FUNCTION FN_Get_Following(
    _user_id BIGINT
) RETURNS TABLE(following_user_id BIGINT)
LANGUAGE SQL
AS $$
    SELECT user_id FROM followers
    WHERE follower_id = _user_id;
$$;


-- Returns TRUE if _user_id is following _follow_id
CREATE OR REPLACE FUNCTION FN_Is_Following(
    _user_id BIGINT,
    _follow_id BIGINT
) RETURNS BOOLEAN
LANGUAGE PLPGSQL
AS $$
    BEGIN
        RETURN EXISTS(
            SELECT user_id FROM followers
            WHERE
                user_id = _follow_id
                AND follower_id = _user_id
        );
    END;
$$;
