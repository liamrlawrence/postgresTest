CREATE OR REPLACE PROCEDURE SP_Insert_User(
    _username   TEXT,
    _nickname   TEXT,
    _email      TEXT,
    _password   TEXT
)
LANGUAGE PLPGSQL
AS $$
    DECLARE
        new_id BIGINT := next_id();
    BEGIN
        -- Constraints
        IF LENGTH(_password) < 8 THEN
            RAISE EXCEPTION 'password length must be at least 8 characters';
        ELSIF LENGTH(_password) > 500 THEN
            RAISE EXCEPTION 'password length cannot exceed 500 characters';
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


CREATE OR REPLACE PROCEDURE SP_Ban_User(
    _user_id BIGINT
)
LANGUAGE PLPGSQL
AS $$
    BEGIN
        IF EXISTS(SELECT user_id FROM users WHERE user_id = _user_id AND role = 'banned') THEN
            RAISE EXCEPTION 'user is already banned';
        END IF;

        -- Update profile role and visibility
        UPDATE users
        SET
            is_active = FALSE,
            role = 'banned',
            visibility = 'hidden',
            modified_date = CLOCK_TIMESTAMP(),
            modified_by = 'system'
        WHERE
            user_id = _user_id;

        -- Delete all posts
        UPDATE posts
        SET
            deleted = TRUE,
            modified_date = CLOCK_TIMESTAMP(),
            modified_by = 'system'
        WHERE
            poster_user_id = _user_id;

        -- Remove all following / followers
        UPDATE followers
        SET
            following = FALSE,
            unfollowed_date = CLOCK_TIMESTAMP()
        WHERE
            followed_user_id = _user_id
            OR follower_user_id = _user_id;
    END;
$$;
