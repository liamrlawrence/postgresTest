CREATE OR REPLACE PROCEDURE SP_Insert_User(
    _username   TEXT,
    _nickname   TEXT,
    _password   TEXT,
    _email      TEXT
)
LANGUAGE PLPGSQL
AS $$
    DECLARE
        new_id BIGINT := next_id();
    BEGIN
        -- Constraints
        IF LENGTH(_password) < 8 THEN
            RAISE EXCEPTION 'Error - Password length must be at least 8 characters';
        ELSIF LENGTH(_password) > 500 THEN
            RAISE EXCEPTION 'Error - Password length cannot exceed 500 characters';
        END IF;

        INSERT INTO users(
            user_id,
            user_code,
            username,
            nickname,
            email,
            password,
            role,
            visibility,
            profile,
            settings,
            modified_by
        ) VALUES(
            new_id,
            enc_64bit_crock32(new_id),
            _username,
            _nickname,
            _email,
            CRYPT(_password, GEN_SALT('bf')),
            'user',
            'public',
            '[{'
                '"profile": {'
                    '"status": "",'
                    '"profile_URL": ""'
                '}'
            '}]'::JSONB,
            '[{'
                '"preferences": {'
                    '"theme": "light"'
                '}'
            '}]'::JSONB,
            'system'
        );
    END;
$$;
