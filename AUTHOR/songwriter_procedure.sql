CREATE OR REPLACE PACKAGE SONGWRITER_ALBUM_PACKAGE AS
    -- ==================================
    -- Создание альбома
    -- ==================================
    PROCEDURE CREATE_ALBUM(
        P_USER_ID IN NUMBER,
        P_ALBUM_NAME IN VARCHAR2,
        P_ALBUM_COVER IN VARCHAR2
    );
    -- ==================================
    -- Удаление альбома
    -- ==================================
    PROCEDURE DELETE_ALBUM(
        P_USER_ID IN NUMBER,
        P_ALBUM_ID IN NUMBER
    );
    -- ==================================
    -- Добавление песни в альбом
    -- ==================================
    PROCEDURE ADD_SONG_TO_ALBUM(
        P_USER_ID IN NUMBER,
        P_ALBUM_ID IN NUMBER,
        P_SONG_ID IN NUMBER
    );
    -- ==================================
    -- Удаление песни из альбома
    -- ==================================
    PROCEDURE REMOVE_SONG_FROM_ALBUM(
        P_SONG_ID IN NUMBER,
        P_ALBUM_ID IN NUMBER,
        P_USER_ID IN NUMBER
    );
        -- ==================================
        -- Все альбомы автора
        -- ==================================
FUNCTION GET_AUTHOR_ALBUMS(
    P_AUTHOR_ID IN NUMBER
) RETURN SYS_REFCURSOR;
    -- ==================================
    -- Проверка принадлежности альбома пользователю
    -- ==================================
    FUNCTION ALBUM_BELONGS_TO_USER(
        P_ALBUM_ID IN NUMBER,
        P_USER_ID IN NUMBER
    ) RETURN BOOLEAN;
    --==========================
    -- Получить песни из альбома --
    --==========================

    FUNCTION GET_SONGS_FROM_ALBUM(
    P_ALBUM_ID IN NUMBER ) RETURN SYS_REFCURSOR;
    --==========================
    -- Получить песни автора --
    --==========================
    FUNCTION GET_USER_SONGS(
        P_USER_ID IN NUMBER
    )   RETURN SYS_REFCURSOR;
    --==========================
    -- Обновление альбома --
    --==========================
    PROCEDURE UPDATE_ALBUM(
    P_USER_ID IN NUMBER,
    P_ALBUM_ID IN NUMBER,
    P_NEW_ALBUM_NAME IN VARCHAR2,
    P_NEW_ALBUM_COVER IN VARCHAR2);
   END SONGWRITER_ALBUM_PACKAGE;
CREATE OR REPLACE PACKAGE BODY SONGWRITER_ALBUM_PACKAGE AS
PROCEDURE CREATE_ALBUM(
    P_USER_ID IN NUMBER,
    P_ALBUM_NAME IN VARCHAR2,
    P_ALBUM_COVER IN VARCHAR2
)
AS
    empty_parameter_ex EXCEPTION;
    V_ALBUM_COUNT NUMBER;
    V_ALBUM_ID NUMBER;

BEGIN
    -- Проверяем, существует ли уже альбом с таким именем у пользователя
    SELECT COUNT(*)
    INTO V_ALBUM_COUNT
    FROM ALBUMS
    WHERE ALBUM_NAME = P_ALBUM_NAME;

    -- Проверяем наличие всех обязательных параметров
    IF TRIM(P_USER_ID) IS NULL OR TRIM(P_ALBUM_NAME) IS NULL OR TRIM(P_ALBUM_COVER) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Empty parameter');
    END IF;

    IF V_ALBUM_COUNT = 0 THEN
        -- Альбом с таким именем не существует, создаем новый
        INSERT INTO ALBUMS (ALBUM_COVER, RELEASE_DATE, ALBUM_NAME)
        VALUES (P_ALBUM_COVER, SYSDATE, P_ALBUM_NAME)
        RETURNING ALBUM_ID INTO V_ALBUM_ID;

        -- Создаем связь с пользователем
        INSERT INTO ALBUM_USER (USER_ID, ALBUM_ID)
        VALUES (P_USER_ID, V_ALBUM_ID);

        COMMIT; -- Фиксируем изменения
    ELSE
        -- Альбом с таким именем уже существует
        RAISE_APPLICATION_ERROR(-20002, 'Album with this name already exists. Please choose a different name.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Error in CREATE_ALBUM procedure: ' || SQLCODE || ' - ' || SQLERRM);
END CREATE_ALBUM;

PROCEDURE DELETE_ALBUM(
    P_USER_ID IN NUMBER,
    P_ALBUM_ID IN NUMBER
)
AS
    V_ALBUM_COUNT NUMBER;
    empty_parameter_ex EXCEPTION;
BEGIN
    -- Проверяем, существует ли альбом
    IF TRIM(P_USER_ID) IS NULL OR TRIM(P_ALBUM_ID) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Empty parameter');
    END IF;

    -- Проверяем, существует ли альбом
    SELECT COUNT(*)
    INTO V_ALBUM_COUNT
    FROM ALBUMS
    WHERE ALBUM_ID = P_ALBUM_ID;

    IF V_ALBUM_COUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Album not found. Please provide a valid album ID.');
    END IF;

    -- Проверяем, принадлежит ли альбом пользователю
    IF NOT ALBUM_BELONGS_TO_USER(P_ALBUM_ID, P_USER_ID) THEN
        RAISE_APPLICATION_ERROR(-20003, 'Album does not belong to the user.');
    END IF;

    -- Удаляем альбом
    DELETE FROM ALBUMS
    WHERE ALBUM_ID = P_ALBUM_ID;

    COMMIT; -- Фиксируем изменения

EXCEPTION
    WHEN empty_parameter_ex THEN
        RAISE_APPLICATION_ERROR(-20004, 'Empty parameter');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20005, 'Error in DELETE_ALBUM procedure: ' || SQLCODE || ' - ' || SQLERRM);
END DELETE_ALBUM;

-- ==================================
-- Добавление песни в альбом
-- ==================================
PROCEDURE ADD_SONG_TO_ALBUM(
    P_USER_ID IN NUMBER,
    P_ALBUM_ID IN NUMBER,
    P_SONG_ID IN NUMBER
)
AS
    V_ALBUM_COUNT NUMBER;
    V_SONG_EXISTS NUMBER;
    empty_parameter_ex EXCEPTION;
BEGIN
    -- Проверяем, существует ли альбом у пользователя
    IF TRIM(P_USER_ID) IS NULL OR TRIM(P_ALBUM_ID) IS NULL OR TRIM(P_SONG_ID) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Empty parameter');
    END IF;

    SELECT COUNT(*)
    INTO V_ALBUM_COUNT
    FROM ALBUMS
    WHERE ALBUM_ID = P_ALBUM_ID;

    IF V_ALBUM_COUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Album not found. Please provide a valid album ID.');
    END IF;

    -- Проверяем, принадлежит ли альбом пользователю
    IF NOT ALBUM_BELONGS_TO_USER(P_ALBUM_ID, P_USER_ID) THEN
        RAISE_APPLICATION_ERROR(-20003, 'Album does not belong to the user.');
    END IF;

    -- Проверяем, существует ли песня
    SELECT COUNT(*)
    INTO V_SONG_EXISTS
    FROM SONGS
    WHERE SONG_ID = P_SONG_ID;

    IF V_SONG_EXISTS > 0 THEN
        -- Песни нет в альбоме, добавляем
        INSERT INTO ALBUM_SONG (ALBUM_ID, SONG_ID)
        VALUES (P_ALBUM_ID, P_SONG_ID);

        COMMIT; -- Фиксируем изменения
    ELSE
        -- Песня не найдена
        RAISE_APPLICATION_ERROR(-20004, 'Song not found. Please provide a valid song ID.');
    END IF;
EXCEPTION
    WHEN empty_parameter_ex THEN
        RAISE_APPLICATION_ERROR(-20005, 'Empty parameter');
    WHEN OTHERS THEN
        -- Обработка ошибок, возвращение сообщения об ошибке
        RAISE_APPLICATION_ERROR(-20006, 'Error in ADD_SONG_TO_ALBUM procedure: ' || SQLCODE || ' - ' || SQLERRM);
END ADD_SONG_TO_ALBUM;

-- ==================================
-- Все альбомы автора
-- ==================================
FUNCTION GET_AUTHOR_ALBUMS(
    P_AUTHOR_ID IN NUMBER
) RETURN SYS_REFCURSOR
AS
    V_CURSOR SYS_REFCURSOR;
    empty_parameter_ex EXCEPTION;
BEGIN
    -- Проверяем, является ли параметр пустым
    IF TRIM(TO_CHAR(P_AUTHOR_ID)) IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;

    -- Возвращаем курсор с альбомами автора
    OPEN V_CURSOR FOR
        SELECT A.ALBUM_ID, A.ALBUM_NAME, A.ALBUM_COVER, A.RELEASE_DATE
        FROM ALBUMS A
        WHERE A.ALBUM_ID IN (SELECT ALBUM_ID FROM ALBUM_USER WHERE USER_ID = P_AUTHOR_ID);

    RETURN V_CURSOR;

EXCEPTION
    WHEN empty_parameter_ex THEN
        RAISE_APPLICATION_ERROR(-20001, 'Empty parameter');
    WHEN OTHERS THEN
        -- Обработка других ошибок
        RAISE_APPLICATION_ERROR(-20002, 'Error in GET_AUTHOR_ALBUMS function: ' || SQLCODE || ' - ' || SQLERRM);
END GET_AUTHOR_ALBUMS;

-- ==================================
-- Удаление песни из альбома
-- ==================================
PROCEDURE REMOVE_SONG_FROM_ALBUM(
    P_SONG_ID IN NUMBER,
    P_ALBUM_ID IN NUMBER,
    P_USER_ID IN NUMBER
)
AS
    V_ALBUM_EXISTS NUMBER;
    empty_parameter_ex EXCEPTION;
BEGIN
    -- Проверяем, существует ли альбом
    IF TRIM(P_SONG_ID) IS NULL OR TRIM(P_ALBUM_ID) IS NULL OR TRIM(P_USER_ID) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Empty parameter');
    END IF;

    SELECT COUNT(*)
    INTO V_ALBUM_EXISTS
    FROM ALBUMS
    WHERE ALBUM_ID = P_ALBUM_ID;

    IF V_ALBUM_EXISTS = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Album not found. Please provide a valid album ID.');
    END IF;

    -- Проверяем, принадлежит ли альбом пользователю
    IF NOT ALBUM_BELONGS_TO_USER(P_ALBUM_ID, P_USER_ID) THEN
        RAISE_APPLICATION_ERROR(-20003, 'Album does not belong to the user.');
    END IF;

    -- Удаляем песню из альбома
    DELETE FROM ALBUM_SONG
    WHERE SONG_ID = P_SONG_ID AND ALBUM_ID = P_ALBUM_ID;

    COMMIT; -- Фиксируем изменения

EXCEPTION
    WHEN empty_parameter_ex THEN
        RAISE_APPLICATION_ERROR(-20004, 'Empty parameter');
    WHEN OTHERS THEN
        -- Обработка ошибок, возвращение сообщения об ошибке
        RAISE_APPLICATION_ERROR(-20005, 'Error in REMOVE_SONG_FROM_ALBUM procedure: ' || SQLCODE || ' - ' || SQLERRM);
END REMOVE_SONG_FROM_ALBUM;

-- ==================================
-- Проверка принадлежности альбома пользователю
-- ==================================
FUNCTION ALBUM_BELONGS_TO_USER(
    P_ALBUM_ID IN NUMBER,
    P_USER_ID IN NUMBER
) RETURN BOOLEAN
AS
    V_ALBUM_COUNT NUMBER;
    empty_parameter_ex EXCEPTION;
BEGIN
    -- Проверяем, существует ли альбом
    IF TRIM(P_ALBUM_ID) IS NULL OR TRIM(P_USER_ID) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Empty parameter');
    END IF;

    -- Проверяем, принадлежит ли альбом пользователю
    SELECT COUNT(*)
    INTO V_ALBUM_COUNT
    FROM ALBUM_USER
    WHERE ALBUM_ID = P_ALBUM_ID AND USER_ID = P_USER_ID;

    RETURN V_ALBUM_COUNT > 0;

EXCEPTION
    WHEN empty_parameter_ex THEN
        RAISE_APPLICATION_ERROR(-20002, 'Empty parameter');
    WHEN OTHERS THEN
        -- Обработка других ошибок
        RAISE_APPLICATION_ERROR(-20003, 'Error in ALBUM_BELONGS_TO_USER function: ' || SQLCODE || ' - ' || SQLERRM);
END ALBUM_BELONGS_TO_USER;

    FUNCTION GET_SONGS_FROM_ALBUM(
    P_ALBUM_ID IN NUMBER
) RETURN SYS_REFCURSOR
IS
    V_ALBUM_EXISTS NUMBER;
    V_CURSOR SYS_REFCURSOR;
    empty_parameter_ex EXCEPTION;

BEGIN
    -- Проверяем существование альбома
    SELECT COUNT(*)
    INTO V_ALBUM_EXISTS
    FROM ALBUMS
    WHERE ALBUM_ID = P_ALBUM_ID;

    IF V_ALBUM_EXISTS = 0 THEN
        RAISE_APPLICATION_ERROR(-20000, 'Album not found. Please provide a valid album ID.');
    END IF;

    -- Возвращаем курсор с песнями из альбома
    OPEN V_CURSOR FOR
        SELECT S.SONG_ID, S.GENRE_ID, S.SONG, S.SONG_COVER, S.SONG_NAME, S.LISTENING_COUNTER, S.AUTHOR_ID
        FROM SONGS S
        JOIN ALBUM_SONG ASG ON S.SONG_ID = ASG.SONG_ID
        WHERE ASG.ALBUM_ID = P_ALBUM_ID;

    RETURN V_CURSOR;

EXCEPTION
    WHEN empty_parameter_ex THEN
        RAISE_APPLICATION_ERROR(-20001, 'Empty parameter');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Error in GET_SONGS_FROM_ALBUM function: ' || SQLCODE || ' - ' || SQLERRM);
END GET_SONGS_FROM_ALBUM;

FUNCTION GET_USER_SONGS(
    P_USER_ID IN NUMBER
) RETURN SYS_REFCURSOR
AS
    V_CURSOR SYS_REFCURSOR;
    empty_parameter_ex EXCEPTION;
BEGIN
    -- Проверяем, является ли P_USER_ID пустым параметром
    IF TRIM(TO_CHAR(P_USER_ID)) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Empty parameter');
    END IF;

    -- Возвращаем курсор с песнями пользователя
    OPEN V_CURSOR FOR
        SELECT S.SONG_ID, S.GENRE_ID, S.SONG, S.SONG_COVER, S.SONG_NAME, S.LISTENING_COUNTER, S.AUTHOR_ID
        FROM SONGS S
        WHERE S.AUTHOR_ID = P_USER_ID;

    RETURN V_CURSOR;

EXCEPTION
    WHEN empty_parameter_ex THEN
        RAISE_APPLICATION_ERROR(-20002, 'Empty parameter');
    WHEN OTHERS THEN
        -- Обработка других ошибок
        RAISE_APPLICATION_ERROR(-20003, 'Error in GET_USER_SONGS function: ' || SQLCODE || ' - ' || SQLERRM);
END GET_USER_SONGS;



PROCEDURE UPDATE_ALBUM(
    P_USER_ID IN NUMBER,
    P_ALBUM_ID IN NUMBER,
    P_NEW_ALBUM_NAME IN VARCHAR2,
    P_NEW_ALBUM_COVER IN VARCHAR2
)
AS
    V_ALBUM_COUNT NUMBER;
    empty_parameter_ex EXCEPTION;
BEGIN
    -- Проверяем, являются ли параметры пустыми
    IF TRIM(TO_CHAR(P_USER_ID)) IS NULL OR
       TRIM(TO_CHAR(P_ALBUM_ID)) IS NULL OR
       TRIM(P_NEW_ALBUM_NAME) IS NULL OR
       TRIM(P_NEW_ALBUM_COVER) IS NULL
    THEN
        RAISE_APPLICATION_ERROR(-20001, 'Empty parameter');
    END IF;

    -- Проверяем, существует ли альбом у пользователя
    SELECT COUNT(*)
    INTO V_ALBUM_COUNT
    FROM ALBUM_USER
    WHERE ALBUM_ID = P_ALBUM_ID AND USER_ID = P_USER_ID;

    IF V_ALBUM_COUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Album not found or does not belong to the user.');
    END IF;

    -- Обновляем данные альбома
    UPDATE ALBUMS
    SET ALBUM_NAME = P_NEW_ALBUM_NAME, ALBUM_COVER = P_NEW_ALBUM_COVER
    WHERE ALBUM_ID = P_ALBUM_ID;

    COMMIT; -- Фиксируем изменения
    DBMS_OUTPUT.PUT_LINE('Album updated successfully.');

EXCEPTION
    WHEN empty_parameter_ex THEN
        RAISE_APPLICATION_ERROR(-20003, 'Empty parameter');
    WHEN OTHERS THEN
        -- Обработка других ошибок
        RAISE_APPLICATION_ERROR(-20004, 'Error in UPDATE_ALBUM procedure: ' || SQLCODE || ' - ' || SQLERRM);
END UPDATE_ALBUM;


END SONGWRITER_ALBUM_PACKAGE;
