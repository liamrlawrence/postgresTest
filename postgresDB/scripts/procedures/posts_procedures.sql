CREATE OR REPLACE PROCEDURE SP_Insert_Post(
    _session_id UUID,
    _message    TEXT
)
LANGUAGE PLPGSQL
AS $$
    DECLARE
        new_id  BIGINT := next_id();
        user_id BIGINT := (SELECT session_user_id FROM sessions WHERE session_id = _session_id);
    BEGIN
        -- Constraints
        IF NOT EXISTS(SELECT session_id FROM sessions WHERE session_id = _session_id) THEN
            RAISE EXCEPTION 'invalid session';
        ELSIF LENGTH(_message) > 280 THEN
            RAISE EXCEPTION 'message length cannot exceed 280 characters';
        END IF;

        INSERT INTO posts(
            post_id,
            post_code,
            poster_user_id,
            content,
            modified_by
        ) VALUES(
            new_id,
            enc_64bit_crock32(new_id),
            user_id,
            CONCAT(
                '[{'
                    '"body": {'
                        '"message": "', _message, '"'
                    '}'
                '}]')::JSONB,
            'system'
        );
    END;
$$;
