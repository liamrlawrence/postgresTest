-- TODO: Currently only one session can exist at a time
CREATE OR REPLACE PROCEDURE SP_Insert_Session(
    INOUT   _return_session_id      UUID,
    INOUT   _return_refresh_token   UUID,
            _user_id                BIGINT
)
LANGUAGE PLPGSQL
AS $$
    DECLARE
        sid         UUID;
        ref_token   UUID;
        is_admin    BOOLEAN := EXISTS(SELECT user_id FROM users WHERE user_id = _user_id AND role = 'admin');
    BEGIN
        -- Remove the user's old session
        CALL SP_Delete_User_Sessions(_user_id);

        -- Create a new session
        INSERT INTO sessions(
            session_user_id,
            admin
        ) VALUES(
            _user_id,
            is_admin
        ) RETURNING session_id, refresh_token INTO sid, ref_token;

        _return_session_id := sid;
        _return_refresh_token := ref_token;
    END;
$$;


CREATE OR REPLACE PROCEDURE SP_Refresh_Session(
            _session_id     UUID,
            _refresh_token  UUID,
    INOUT   _new_refresh    UUID
)
LANGUAGE PLPGSQL
AS $$
    DECLARE
        ref_token UUID;
        exp_time TIMESTAMPTZ;
    BEGIN
        -- Validate input and expiration time
        SELECT refresh_token, refresh_expiration INTO ref_token, exp_time FROM sessions
        WHERE
            session_id = _session_id;

        IF ref_token IS NULL THEN
            RAISE EXCEPTION 'session ID is invalid';
        ELSIF _refresh_token <> ref_token THEN
            RAISE EXCEPTION 'invalid refresh token';
        ELSIF CLOCK_TIMESTAMP() >= exp_time THEN
            RAISE EXCEPTION 'session has expired';
        END IF;

        -- Refresh the token
        UPDATE sessions
        SET
            refresh_token = DEFAULT,
            session_expiration = DEFAULT,
            refresh_expiration = DEFAULT,
            times_refreshed = times_refreshed + 1,
            modified_date = CLOCK_TIMESTAMP()
        WHERE session_id = _session_id
        RETURNING refresh_token INTO _new_refresh;
    END;
$$;


CREATE OR REPLACE PROCEDURE SP_Delete_Session(
    _session_id UUID
)
LANGUAGE PLPGSQL
AS $$
    BEGIN
        DELETE FROM sessions
        WHERE
            session_id = _session_id;
    END;
$$;


CREATE OR REPLACE PROCEDURE SP_Delete_User_Sessions(
    _user_id BIGINT
)
LANGUAGE PLPGSQL
AS $$
    BEGIN
        DELETE FROM sessions
        WHERE
            session_user_id = _user_id;
    END;
$$;
