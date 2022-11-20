-- Get the contents of a post
CREATE OR REPLACE FUNCTION FN_Get_Post(
    _user_id BIGINT,
    _post_id BIGINT
) RETURNS TABLE(post_content JSONB)
LANGUAGE PLPGSQL
AS $$
    DECLARE
        user_role           USER_ROLES_E;
        poster_visibility   USER_VIS_E;
        poster_user_id      BIGINT;
        post_deleted        BOOLEAN;
    BEGIN
        -- Get the Current user's role, visibility of the poster, & status of the post
        SELECT role INTO user_role FROM users WHERE user_id = _user_id;
        SELECT ut.visibility, pt.user_id, pt.deleted INTO poster_visibility, poster_user_id, post_deleted
        FROM users ut
            LEFT JOIN posts pt ON ut.user_id = pt.user_id
        WHERE pt.post_id = _post_id;

        -- Validate if the user has permissions to view the post
        IF user_role NOT IN ('admin', 'debug', 'bot') THEN
            CASE
                WHEN post_deleted = TRUE THEN
                    RAISE EXCEPTION 'post is deleted';
                WHEN poster_visibility = 'hidden' THEN
                    RAISE EXCEPTION 'user is hidden';
                WHEN poster_visibility = 'private' AND FN_Is_Following(_user_id, poster_user_id) = FALSE THEN
                    RAISE EXCEPTION 'user is private and you are not following them';
            END CASE;
        END IF;

        RETURN QUERY SELECT content FROM posts WHERE post_id = _post_id;
    END;
$$;
