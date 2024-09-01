-- USERS create or replace PROCEDURES 1
--/

CREATE OR REPLACE FUNCTION GET_USER_ID_BY_NAME(
    P_USER_NAME IN VARCHAR2
) RETURN INTEGER
IS
        empty_parameter_ex EXCEPTION;
    V_USER_ID INTEGER;
BEGIN
    IF TRIM(P_USER_NAME) IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;
    BEGIN
        SELECT USER_ID INTO V_USER_ID
        FROM USERS
        WHERE USER_NAME = P_USER_NAME;

        RETURN V_USER_ID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Обработка ситуации, когда пользователя с таким именем не найдено
            DBMS_OUTPUT.PUT_LINE('User with name ' || P_USER_NAME || ' not found.');
            RETURN NULL;
            WHEN empty_parameter_ex THEN
        dbms_output.put_line('Empty parameter');
        RETURN NULL;
            WHEN OTHERS THEN
            -- Обработка других ошибок
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
            RAISE;
    END;
END GET_USER_ID_BY_NAME;

CREATE OR REPLACE PROCEDURE create_user
(
    p_user_role IN USERS.USER_ROLE%TYPE,
    p_name IN USERS.USER_NAME%TYPE,
    p_login IN USERS.USER_LOGIN%TYPE,
    p_password IN VARCHAR2
)
IS
    empty_parameter_ex EXCEPTION;
    duplicate_name_login_ex EXCEPTION;
    PRAGMA EXCEPTION_INIT(duplicate_name_login_ex, -1); -- Код ошибки для дублирования

BEGIN
    IF TRIM(p_name) IS NULL OR TRIM(p_login) IS NULL OR TRIM(p_password) IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;

    -- Проверяем уникальность имени и логина
    BEGIN
        INSERT INTO USERS(USER_ROLE, USER_NAME, USER_LOGIN, USER_PASS)
        VALUES (p_user_role, TRIM(p_name), TRIM(p_login), (SELECT hash_password(TRIM(p_password)) FROM DUAL));
        COMMIT;
    EXCEPTION
        WHEN duplicate_name_login_ex THEN
            dbms_output.put_line('Name or login is not unique');
        WHEN OTHERS THEN
            dbms_output.put_line('Unexpected error');
    END;

EXCEPTION
    WHEN empty_parameter_ex THEN
        dbms_output.put_line('Empty parameter');
    WHEN OTHERS THEN
        dbms_output.put_line('Error in create_user procedure');
END;

CREATE OR REPLACE PROCEDURE update_user
(
    p_id IN USERS.USER_ID%TYPE,
    p_user_role IN USERS.USER_ROLE%TYPE DEFAULT NULL,
    p_name IN USERS.USER_NAME%TYPE DEFAULT NULL,
    p_login IN USERS.USER_LOGIN%TYPE DEFAULT NULL,
    p_password IN VARCHAR2 DEFAULT NULL
)
IS
    v_hashed_password VARCHAR2(256); -- Используйте размер, подходящий для вашей функции hash_password
    v_name_exists NUMBER;
    v_login_exists NUMBER;
    v_user_exists NUMBER;
    empty_parameter_ex EXCEPTION;
BEGIN
    IF TRIM(p_id) IS NULL OR TRIM(p_user_role) IS NULL OR TRIM(p_name) IS NULL OR TRIM(p_login) IS NULL OR TRIM(p_password) IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;
    -- Проверка существования пользователя по ID
    SELECT COUNT(*)
    INTO v_user_exists
    FROM USERS
    WHERE USER_ID = p_id;

    IF v_user_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20000, 'Пользователь с указанным ID не найден');
    END IF;

    -- Проверка на изменение значений перед выполнением UPDATE
    IF p_user_role IS NOT NULL OR p_login IS NOT NULL OR p_name IS NOT NULL OR p_password IS NOT NULL THEN

        -- Проверка уникальности имени пользователя
        IF p_name IS NOT NULL THEN
            SELECT COUNT(*)
            INTO v_name_exists
            FROM USERS
            WHERE USER_NAME = TRIM(p_name) AND USER_ID != p_id;

            IF v_name_exists > 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Имя пользователя уже используется');
            END IF;
        END IF;

        -- Проверка уникальности логина
        IF p_login IS NOT NULL THEN
            SELECT COUNT(*)
            INTO v_login_exists
            FROM USERS
            WHERE USER_LOGIN = TRIM(p_login) AND USER_ID != p_id;

            IF v_login_exists > 0 THEN
                RAISE_APPLICATION_ERROR(-20002, 'Логин уже используется');
            END IF;
        END IF;

        -- Обработка хешированного пароля
        IF p_password IS NOT NULL THEN
            v_hashed_password := hash_password(TRIM(p_password));
        END IF;

        -- Выполнение UPDATE
        UPDATE USERS
        SET USER_ROLE = CASE WHEN p_user_role IS NOT NULL THEN TRIM(p_user_role) ELSE USER_ROLE END,
            USER_LOGIN = CASE WHEN p_login IS NOT NULL THEN TRIM(p_login) ELSE USER_LOGIN END,
            USER_NAME = CASE WHEN p_name IS NOT NULL THEN TRIM(p_name) ELSE USER_NAME END,
            USER_PASS = CASE WHEN v_hashed_password IS NOT NULL THEN v_hashed_password ELSE USER_PASS END
        WHERE USER_ID = p_id;

        DBMS_OUTPUT.PUT_LINE('Пользователь успешно обновлен');

    ELSE
        DBMS_OUTPUT.PUT_LINE('Нет изменений для обновления');
    END IF;
EXCEPTION
    WHEN empty_parameter_ex THEN
        dbms_output.put_line('Empty parameter');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка в процедуре update_user: ' || SQLCODE || ' - ' || SQLERRM);
        RAISE;
END;
/

/

CREATE OR REPLACE PROCEDURE delete_user (
    p_id IN USERS.USER_ID%TYPE
)
IS
    v_user_count NUMBER;
    empty_parameter_ex EXCEPTION;

BEGIN
    -- Проверка на пустой параметр
    IF p_id IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;

    -- Проверка на существование пользователя
    SELECT COUNT(*)
    INTO v_user_count
    FROM USERS
    WHERE USER_ID = p_id;

    IF v_user_count = 0 THEN
        -- Пользователь не найден, вызываем исключение
        RAISE_APPLICATION_ERROR(-20000, 'User not found. Please provide a valid user ID.');
    END IF;

    -- Удаление из таблицы SONG_USER
    DELETE FROM SONG_USER WHERE USER_ID = p_id;

    -- Удаление из таблицы PLAYLIST_SONG
    DELETE FROM PLAYLIST_SONG WHERE PLAYLIST_ID IN (SELECT PLAYLIST_ID FROM PLAYLIST WHERE USER_ID = p_id);

    -- Удаление из таблицы PLAYLIST
    DELETE FROM PLAYLIST WHERE USER_ID = p_id;

    -- Удаление из таблицы ALBUM_USER
    DELETE FROM ALBUM_USER WHERE USER_ID = p_id;

    -- Удаление из таблицы USERS
    DELETE FROM USERS WHERE USER_ID = p_id;

    COMMIT;
EXCEPTION
    WHEN empty_parameter_ex THEN
        RAISE_APPLICATION_ERROR(-20001, 'Empty parameter');
    WHEN OTHERS THEN
        -- Обработка ошибок, возвращение сообщения об ошибке
        RAISE_APPLICATION_ERROR(-20002, 'Error in delete_user procedure: ' || SQLCODE || ' - ' || SQLERRM);
END delete_user;

-- Авторизация пользователя
CREATE OR REPLACE FUNCTION AUTHENTICATE_USER
(
    p_login IN USERS.USER_LOGIN%TYPE,
    p_password IN VARCHAR2
)
RETURN SYS_REFCURSOR
IS
    user_cursor SYS_REFCURSOR;
    empty_parameter_ex EXCEPTION;
BEGIN
        IF TRIM(p_login) IS NULL OR TRIM(p_password) IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;
    OPEN user_cursor FOR
        SELECT USER_ID, USER_ROLE, USER_NAME, USER_LOGIN, USER_PASS
        FROM USERS
        WHERE USER_LOGIN = p_login
        AND USER_PASS = hash_password(p_password);

    RETURN user_cursor;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL; -- Пользователь с данным логином и паролем не найден
    WHEN empty_parameter_ex THEN
        dbms_output.put_line('Empty parameter');
        RETURN NULL;
    WHEN OTHERS THEN
        RETURN NULL; -- Обработка других ошибок
END;

-- Информация о пользователе
CREATE OR REPLACE FUNCTION GET_USER_BY_NAME(
    P_USER_NAME IN VARCHAR2
) RETURN SYS_REFCURSOR
IS
    empty_parameter_ex EXCEPTION;
    V_CURSOR SYS_REFCURSOR;
BEGIN
    IF TRIM(P_USER_NAME) IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;
    OPEN V_CURSOR FOR
        SELECT USER_ID, USER_ROLE, USER_NAME, USER_LOGIN, USER_PASS
        FROM USERS
        WHERE USER_NAME = P_USER_NAME;

    RETURN V_CURSOR;

    EXCEPTION
        WHEN  NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('User with name ' || P_USER_NAME || ' not found.');
            RETURN NULL;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
            RAISE;
END GET_USER_BY_NAME;
--/
-- Song_User create or replace PROCEDURES 2
--/

    create or replace PROCEDURE create_song_user (
        p_song_id SONG_USER.SONG_ID%TYPE,
        p_user_id SONG_USER.USER_ID%TYPE
    )
    IS
            empty_parameter_ex EXCEPTION;
    BEGIN
        IF TRIM(p_song_id) IS NULL OR TRIM(p_user_id) IS NULL THEN
            RAISE empty_parameter_ex;
         END IF;

        INSERT INTO Song_User (SONG_ID, USER_ID) VALUES (p_song_id, p_user_id);
        COMMIT;
    EXCEPTION
        WHEN empty_parameter_ex THEN
        dbms_output.put_line('Empty parameter');
        WHEN OTHERS THEN
            dbms_output.put_line('Error occurred: ' || SQLERRM);
            RAISE;
    END create_song_user;

    create or replace PROCEDURE delete_song_user (
        p_song_id SONG_USER.SONG_ID%TYPE,
        p_user_id SONG_USER.USER_ID%TYPE
    )
    IS
    BEGIN
        DELETE FROM Song_User WHERE SONG_ID = p_song_id AND USER_ID = p_user_id;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Error occurred: ' || SQLERRM);
            RAISE;
    END delete_song_user;

--/
-- Albums create or replace PROCEDURES 3
--/


--/
-- Album_User create or replace PROCEDURES 4


--/
-- Album_Song create or replace PROCEDURES 5
--/


--/
-- PlayList create or replace PROCEDURES 6
--/


--/
-- Playlist_Song create or replace PROCEDURES 7
--/

--//

-- Songs create or replace PROCEDURES 8
--//

CREATE OR REPLACE PROCEDURE ADD_SONG (
    P_GENRE_NAME VARCHAR2,
    P_SONG VARCHAR2,
    P_SONG_NAME VARCHAR2,
    P_SONG_COVER VARCHAR2,
    P_AUTHOR_NAME VARCHAR2
)
IS
    V_GENRE_ID INT;
    V_AUTHOR_ID INT;
    V_EXISTING_SONG_ID INT;
BEGIN
    -- Проверяем, существует ли автор с заданным именем
    SELECT USER_ID INTO V_AUTHOR_ID
    FROM USERS
    WHERE UPPER(USER_NAME) = UPPER(P_AUTHOR_NAME) AND USER_ROLE = 'AUTHOR';

    -- Если автор существует, проверяем, существует ли жанр с заданным именем
    SELECT GENRE_ID INTO V_GENRE_ID
    FROM GENRES
    WHERE UPPER(GENRE_NAME) = UPPER(P_GENRE_NAME);

    -- Проверяем, существует ли песня с заданным названием
SELECT COUNT(*) INTO V_EXISTING_SONG_ID
FROM SONGS
WHERE UPPER(SONG_NAME) = UPPER(P_SONG_NAME);

    -- Если песня не существует, выполняем вставку
    IF V_EXISTING_SONG_ID = 0 THEN
        INSERT INTO SONGS (GENRE_ID, SONG, SONG_COVER, SONG_NAME, LISTENING_COUNTER, AUTHOR_ID)
        VALUES (V_GENRE_ID, P_SONG, P_SONG_COVER, P_SONG_NAME, 0, V_AUTHOR_ID);
        DBMS_OUTPUT.PUT_LINE('Добавил песню');
        COMMIT;
    ELSE
        -- Песня с таким названием уже существует
        RAISE_APPLICATION_ERROR(-20003, 'Песня с названием ' || P_SONG_NAME || ' уже существует.');
    END IF;

EXCEPTION
    -- Обрабатываем исключение, если автор или жанр не найдены
    WHEN NO_DATA_FOUND THEN
        IF V_AUTHOR_ID IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Автор с именем ' || P_AUTHOR_NAME || ' не найден.');
            RAISE_APPLICATION_ERROR(-20001, 'Автор с именем ' || P_AUTHOR_NAME || ' не найден.');
        ELSIF V_GENRE_ID IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Жанр с именем ' || P_GENRE_NAME || ' не найден.');
            RAISE_APPLICATION_ERROR(-20002, 'Жанр с именем ' || P_GENRE_NAME || ' не найден.');
        END IF;
    WHEN OTHERS THEN
        -- Обрабатываем другие исключения
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        RAISE;
END ADD_SONG;

CREATE OR REPLACE PROCEDURE update_song (
    p_id SONGS.SONG_ID%type,
    p_genre_id SONGS.GENRE_ID%type,
    p_song SONGS.SONG%type,
    p_song_name SONGS.SONG_NAME%type,
    p_song_cover SONGS.SONG_COVER%type,
    p_listening_counter SONGS.LISTENING_COUNTER%type,
    p_author_id SONGS.AUTHOR_ID%type
)
IS
BEGIN
    IF p_id IS NULL OR p_genre_id IS NULL OR TRIM(p_song) IS NULL OR TRIM(p_song_name) IS NULL OR TRIM(p_song_cover) IS NULL
        OR p_listening_counter IS NULL OR p_author_id IS NULL THEN
        dbms_output.put_line('Error: One or more input parameters are empty or null.');
        RETURN;
    END IF;

    UPDATE Songs
    SET GENRE_ID = p_genre_id,
        SONG = p_song,
        SONG_NAME = p_song_name,
        SONG_COVER = p_song_cover,
        LISTENING_COUNTER = p_listening_counter,
        AUTHOR_ID = p_author_id
    WHERE SONG_ID = p_id;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error occurred: ' || SQLERRM);
        RAISE;
END update_song;


CREATE OR REPLACE PROCEDURE DELETE_ALL_SONG AS
BEGIN

       FOR d IN (SELECT SONG_ID FROM SONGS)
   LOOP
    DELETE FROM PLAYLIST_SONG WHERE SONG_ID = d.SONG_ID;

    -- Удаление из таблицы SONG_USER
    DELETE FROM SONG_USER WHERE SONG_ID = d.SONG_ID;

    -- Удаление из таблицы ALBUM_SONG
    DELETE FROM ALBUM_SONG WHERE SONG_ID = d.SONG_ID;

    -- Удаление из таблицы LISTENING_HISTORY
    DELETE FROM LISTENING_HISTORY WHERE SONG_ID = d.SONG_ID;

    -- Удаление из таблицы SONGS
    DELETE FROM SONGS WHERE SONG_ID = d.SONG_ID;
   END LOOP;
    -- Удаление из таблицы PLAYLIST_SONG
    -- COMMIT для фиксации изменений
    COMMIT;
END DELETE_ALL_SONG;

CREATE OR REPLACE PROCEDURE DELETE_SONG_BY_ID (P_SONG_ID INT)
AS
BEGIN
    -- Удаление из таблицы PLAYLIST_SONG
    DELETE FROM PLAYLIST_SONG WHERE SONG_ID = P_SONG_ID;

    -- Удаление из таблицы SONG_USER
    DELETE FROM SONG_USER WHERE SONG_ID = P_SONG_ID;

    -- Удаление из таблицы ALBUM_SONG
    DELETE FROM ALBUM_SONG WHERE SONG_ID = P_SONG_ID;

    -- Удаление из таблицы LISTENING_HISTORY
    DELETE FROM LISTENING_HISTORY WHERE SONG_ID = P_SONG_ID;

    -- Удаление из таблицы SONGS
    DELETE FROM SONGS WHERE SONG_ID = P_SONG_ID;

    -- COMMIT для фиксации изменений
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
            dbms_output.put_line('Error occurred: ' || SQLERRM);
        RAISE;
END DELETE_SONG_BY_ID;
/


--//
-- Genres create or replace PROCEDURES 9
--/

CREATE OR REPLACE PROCEDURE create_genre (
    p_genre_name IN VARCHAR2
)
IS
BEGIN
    IF TRIM(p_genre_name) IS NULL THEN
        dbms_output.put_line('Error: Genre name cannot be empty.');
        RETURN;
    END IF;

    INSERT INTO Genres (GENRE_NAME) VALUES (p_genre_name);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error occurred: ' || SQLERRM);
        RAISE;
END create_genre;

CREATE OR REPLACE PROCEDURE update_genre (
    p_id GENRES.GENRE_ID%type,
    p_genre_name GENRES.GENRE_NAME%type
)
IS
BEGIN
    IF TRIM(p_genre_name) IS NULL THEN
        dbms_output.put_line('Error: Genre name cannot be empty.');
        RETURN;
    END IF;

    UPDATE Genres
    SET GENRE_NAME = p_genre_name
    WHERE GENRE_ID = p_id;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error occurred: ' || SQLERRM);
        RAISE;
END update_genre;

CREATE OR REPLACE PROCEDURE delete_genre (
    p_id IN INT
)
IS
BEGIN
    DELETE FROM Genres WHERE GENRE_ID = p_id;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error occurred: ' || SQLERRM);
        RAISE;
END delete_genre;


--//


--==============---
--ТЕСТЫ
select * from SONGS;

begin
    DELETE_SONG();
end;

SELECT * FROM USERS;
SELECT * FROM GENRES;
SELECT * FROM SONGS;

BEGIN
    ADD_SONG('D', 'FFFF', 'FFF', 'FFF', 'Автор1');
end;



-------------
CREATE OR REPLACE PROCEDURE ADD_LISTENING_HISTORY
(
    P_SONG_ID INT,
    P_USER_ID INT
)
AS
BEGIN
    -- Увеличиваем счетчик прослушиваний у песни
    UPDATE SONGS
    SET LISTENING_COUNTER = LISTENING_COUNTER + 1
    WHERE SONG_ID = P_SONG_ID;

    -- Добавляем запись в LISTENING_HISTORY
    INSERT INTO LISTENING_HISTORY (USER_ID, SONG_ID, AUDITION_DATE)
    VALUES (P_USER_ID, P_SONG_ID, SYSDATE);

    COMMIT;
END ADD_LISTENING_HISTORY;

begin
    DELETE_ALL_SONG();
end;

create or replace FUNCTION USER_EXISTS(P_USER_ID IN NUMBER) RETURN BOOLEAN
IS
    V_USER_COUNT NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO V_USER_COUNT
    FROM USERS
    WHERE USER_ID = P_USER_ID;

    RETURN V_USER_COUNT > 0;
END USER_EXISTS;


CREATE OR REPLACE FUNCTION GET_USER_INFO_BY_ID(
    P_USER_ID IN INTEGER
) RETURN SYS_REFCURSOR
IS
    v_cursor SYS_REFCURSOR;
    v_temp_user_id INTEGER;  -- Добавленная переменная для хранения значения
BEGIN
    -- Проверка наличия пользователя с заданным идентификатором
    SELECT USER_ID INTO v_temp_user_id
    FROM USERS
    WHERE USER_ID = P_USER_ID;

    -- Если пользователь существует, открываем курсор
    OPEN v_cursor FOR
        SELECT USER_ID, USER_NAME
        FROM USERS
        WHERE USER_ID = P_USER_ID;

    -- Возвращаем курсор
    RETURN v_cursor;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Обработка ситуации, когда пользователь не найден
        DBMS_OUTPUT.PUT_LINE('User with ID ' || P_USER_ID || ' not found.');
        RETURN NULL;
    WHEN OTHERS THEN
        -- Обработка других ошибок
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
        RETURN NULL;
END GET_USER_INFO_BY_ID;


CREATE OR REPLACE FUNCTION GET_USER_INFO_BY_NAME(
    P_USER_NAME IN VARCHAR2
) RETURN SYS_REFCURSOR
IS
    v_cursor SYS_REFCURSOR;
    v_temp_user_id INTEGER;
BEGIN
    -- Проверка наличия пользователя с заданным именем
    SELECT USER_ID INTO v_temp_user_id
    FROM USERS
    WHERE USER_NAME = P_USER_NAME;

    -- Если пользователь существует, открываем курсор
    OPEN v_cursor FOR
        SELECT USER_ID, USER_NAME
        FROM USERS
        WHERE USER_NAME = P_USER_NAME;

    -- Возвращаем курсор
    RETURN v_cursor;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Обработка ситуации, когда пользователь не найден
        DBMS_OUTPUT.PUT_LINE('User with name ' || P_USER_NAME || ' not found.');
        RETURN NULL;
    WHEN OTHERS THEN
        -- Обработка других ошибок
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
        RETURN NULL;
END GET_USER_INFO_BY_NAME;

CREATE OR REPLACE FUNCTION GET_SONG_INFO_BY_NAME(
    P_SONG_NAME IN VARCHAR2
) RETURN SYS_REFCURSOR
IS
    v_cursor SYS_REFCURSOR;
    v_temp_song_id INTEGER;
    empty_parameter_ex EXCEPTION;
BEGIN
    -- Проверка на пустой параметр
    IF TRIM(P_SONG_NAME) IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;

    -- Проверка наличия песни с заданным названием
    SELECT SONG_ID INTO v_temp_song_id
    FROM SONGS
    WHERE SONG_NAME = P_SONG_NAME;

    -- Если песня существует, открываем курсор
    OPEN v_cursor FOR
        SELECT SONG_ID, GENRE_ID, SONG, SONG_COVER, SONG_NAME, LISTENING_COUNTER, AUTHOR_ID
        FROM SONGS
        WHERE SONG_NAME = P_SONG_NAME;

    -- Возвращаем курсор
    RETURN v_cursor;
EXCEPTION
    WHEN empty_parameter_ex THEN
        -- Обработка ситуации, когда параметр пуст
        DBMS_OUTPUT.PUT_LINE('Empty parameter');
        RETURN NULL;
    WHEN NO_DATA_FOUND THEN
        -- Обработка ситуации, когда песня не найдена
        DBMS_OUTPUT.PUT_LINE('Song with name ' || P_SONG_NAME || ' not found.');
        RETURN NULL;
    WHEN OTHERS THEN
        -- Обработка других ошибок
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
        RETURN NULL;
END GET_SONG_INFO_BY_NAME;


