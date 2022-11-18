CREATE OR REPLACE PROCEDURE SP_Insert_Post(
    _user_id BIGINT,
    _message TEXT
)
LANGUAGE PLPGSQL
AS $$
    DECLARE
        new_id BIGINT := next_id();
    BEGIN
        -- Constraints
        IF LENGTH(_message) > 280 THEN
            RAISE EXCEPTION 'Error - Message length cannot exceed 280 characters';
        END IF;

        INSERT INTO posts(
            post_id,
            post_code,
            user_id,
            content
        ) VALUES(
            new_id,
            enc_64bit_crock32(new_id),
            _user_id,
            CONCAT(
                '[{'
                    '"body": {'
                        '"message": "', _message, '"'
                    '}'
                '}]')::JSONB
        );
    END;
$$;
