CREATE OR REPLACE FUNCTION hash_password(f_password IN VARCHAR2)
    RETURN RAW
AS
BEGIN
    IF f_password IS NULL
    THEN
        RETURN NULL;
    ELSE
        RETURN dbms_crypto.hash(utl_raw.cast_to_raw(f_password), dbms_crypto.hash_sh256);
    END IF;
END;

CREATE OR REPLACE FUNCTION compare_passwords
(
    user_id_p IN USERS.USER_ID%TYPE,
    password IN VARCHAR2
)
RETURN NUMBER
IS
    hash RAW(32);
    user_password RAW(32);
BEGIN
    SELECT USER_PASS INTO user_password FROM USERS WHERE USER_ID = user_id_p;

    -- Обработка NULL и установка пароля по умолчанию
    hash := hash_password(COALESCE(TRIM(password), ''));
    -- Простое сравнение значений
    IF hash = user_password THEN
        RETURN 1; -- Пароли совпадают
    ELSE
        RETURN 0; -- Пароли не совпадают
    END IF;
END;

--/