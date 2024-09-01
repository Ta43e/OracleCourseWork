---------------------------------------------------------
--                                                     --
--           ПРОЦЕДУРЫ И ФУНКЦИИ ПОЛЬЗОВАТЕЛЯ          --
--                                                     --
---------------------------------------------------------
CREATE OR REPLACE PACKAGE SONG_MANAGEMENT_PACKAGE AS
    --ДОБАВЛЕНИЕ ПЕСНИ В СВОИ ПЕСНИ--
    FUNCTION ADD_SONG_TO_USERLIST(
        P_USER_ID IN NUMBER,
        P_SONG_ID IN NUMBER
    ) RETURN VARCHAR2;

    --УДАЛЕНИЕ ПЕСНИ ИЗ СВОИХ ПЕСЕН--
    FUNCTION REMOVESONGFROMFAVORIT(
        P_USER_ID IN NUMBER,
        P_SONG_ID IN NUMBER
    ) RETURN VARCHAR2;

     FUNCTION GET_USER_SUBSCRIBED_SONGS(
    P_USER_ID IN NUMBER
) RETURN SYS_REFCURSOR;
    -- Получить песни пользоваетля --
    FUNCTION GET_USER_SONGS(
        P_USER_ID IN NUMBER
    ) RETURN SYS_REFCURSOR;

    --ПРОСЛУШАТЬ ПЕСНЮ
    PROCEDURE LISTEN_TO_SONG(
        P_USER_ID IN NUMBER,
        P_SONG_ID IN NUMBER
    );
END SONG_MANAGEMENT_PACKAGE;

CREATE OR REPLACE PACKAGE BODY SONG_MANAGEMENT_PACKAGE AS
--ДОБАВЛЕНИЕ ПЕСНИ В СВОИ ПЕСНИ--
FUNCTION ADD_SONG_TO_USERLIST(
    P_USER_ID IN NUMBER,
    P_SONG_ID IN NUMBER
) RETURN VARCHAR2
IS
    empty_parameter_ex EXCEPTION;
    V_SONG_EXISTS NUMBER;
    V_SONG_IN_PLAYLIST NUMBER;
BEGIN
    IF P_USER_ID IS NULL OR P_SONG_ID IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;

    -- Проверяем существование пользователя
    IF USER_EXISTS(P_USER_ID) THEN
        -- Проверяем существование песни
        SELECT COUNT(*)
        INTO V_SONG_EXISTS
        FROM SONGS
        WHERE SONG_ID = P_SONG_ID;

        IF V_SONG_EXISTS > 0 THEN
            -- Проверяем, есть ли уже эта песня в избранных пользователя
            SELECT COUNT(*)
            INTO V_SONG_IN_PLAYLIST
            FROM SONG_USER
            WHERE USER_ID = P_USER_ID AND SONG_ID = P_SONG_ID;

            IF V_SONG_IN_PLAYLIST = 0 THEN
                -- Песни нет в избранных, добавляем
                INSERT INTO SONG_USER (USER_ID, SONG_ID)
                VALUES (P_USER_ID, P_SONG_ID);

                COMMIT; -- Фиксируем изменения

                RETURN 'Song added to the favorite successfully.';
            ELSE
                -- Песня уже есть в плейлисте
                RAISE_APPLICATION_ERROR(-20001, 'This song is already in your favorite.');
            END IF;
        ELSE
            -- Песня не найдена
            RAISE_APPLICATION_ERROR(-20002, 'Song not found. Please provide a valid song ID.');
        END IF;
    ELSE
        -- Пользователь не найден
        RAISE_APPLICATION_ERROR(-20000, 'User not found. Please provide a valid user ID.');
    END IF;

EXCEPTION
    WHEN empty_parameter_ex THEN
        RAISE_APPLICATION_ERROR(-20003, 'Empty parameter');
    WHEN OTHERS THEN
        -- Обработка ошибок, возвращение сообщения об ошибке
        RAISE_APPLICATION_ERROR(-20004, 'Error: ' || SQLCODE || ' - ' || SQLERRM);
END ADD_SONG_TO_USERLIST;


--УДАЛЕНИЕ ПЕСНИ ИЗ СВОИХ ИЗБРАННЫХ--

FUNCTION REMOVESONGFROMFAVORIT(
    P_USER_ID IN NUMBER,
    P_SONG_ID IN NUMBER
) RETURN VARCHAR2
IS
    V_SONG_EXISTS NUMBER;
    V_SONG_IN_PLAYLIST NUMBER;
    empty_parameter_ex EXCEPTION;
BEGIN
    -- Проверяем существование пользователя
    IF P_USER_ID IS NULL OR P_SONG_ID IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;

    -- Проверяем существование песни
    IF USER_EXISTS(P_USER_ID) THEN
        SELECT COUNT(*)
        INTO V_SONG_EXISTS
        FROM SONGS
        WHERE SONG_ID = P_SONG_ID;

        IF V_SONG_EXISTS > 0 THEN
            -- Проверяем, есть ли эта песня в favorite пользователя
            SELECT COUNT(*)
            INTO V_SONG_IN_PLAYLIST
            FROM SONG_USER
            WHERE USER_ID = P_USER_ID AND SONG_ID = P_SONG_ID;

            IF V_SONG_IN_PLAYLIST > 0 THEN
                -- Песня найдена в плейлисте, удаляем
                DELETE FROM SONG_USER
                WHERE USER_ID = P_USER_ID AND SONG_ID = P_SONG_ID;

                COMMIT; -- Фиксируем изменения

                RETURN 'Song removed from the favorite successfully.';
            ELSE
                -- Песни нет в плейлисте
                RAISE_APPLICATION_ERROR(-20001, 'This song is not in your favorite.');
            END IF;
        ELSE
            -- Песня не найдена
            RAISE_APPLICATION_ERROR(-20002, 'Song not found. Please provide a valid song ID.');
        END IF;
    ELSE
        -- Пользователь не найден
        RAISE_APPLICATION_ERROR(-20000, 'User not found. Please provide a valid user ID.');
    END IF;

EXCEPTION
    WHEN empty_parameter_ex THEN
        RAISE_APPLICATION_ERROR(-20003, 'Empty parameter');
    WHEN OTHERS THEN
        -- Обработка ошибок, возвращение сообщения об ошибке
        RAISE_APPLICATION_ERROR(-20004, 'Error: ' || SQLCODE || ' - ' || SQLERRM);
END REMOVESONGFROMFAVORIT;




-- Получить песни пользоваетля --

FUNCTION GET_USER_SUBSCRIBED_SONGS(
    P_USER_ID IN NUMBER
) RETURN SYS_REFCURSOR
IS
    V_CURSOR SYS_REFCURSOR;
BEGIN
    -- Проверяем существование пользователя
    IF NOT USER_EXISTS(P_USER_ID) THEN
        RAISE_APPLICATION_ERROR(-20000, 'User not found. Please provide a valid user ID.');
    END IF;

    -- Объявляем обработчик ошибок
    BEGIN
        -- Используем подзапрос для получения песен, на которые подписан пользователь
        OPEN V_CURSOR FOR
            SELECT S.SONG_ID, S.GENRE_ID, S.SONG, S.SONG_COVER, S.SONG_NAME, S.LISTENING_COUNTER, S.AUTHOR_ID
            FROM SONGS S
            WHERE S.SONG_ID IN (
                SELECT US.SONG_ID
                FROM SONG_USER US
                WHERE US.USER_ID = P_USER_ID
            );
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Обработка ошибки, если данных не найдено
            RAISE_APPLICATION_ERROR(-20001, 'User has no subscribed songs.');
            CLOSE V_CURSOR; -- Закрываем курсор
            RETURN NULL;
        WHEN OTHERS THEN
            -- Обработка других ошибок
            RAISE_APPLICATION_ERROR(-20002, 'Error: ' || SQLCODE || ' - ' || SQLERRM);
            CLOSE V_CURSOR; -- Закрываем курсор
            RETURN NULL;
    END;

    RETURN V_CURSOR;

EXCEPTION
    WHEN OTHERS THEN
        -- Обработка ошибок, возвращение сообщения об ошибке
        RAISE_APPLICATION_ERROR(-20003, 'Error: ' || SQLCODE || ' - ' || SQLERRM);
END GET_USER_SUBSCRIBED_SONGS;

-- Песни на которые подписан пользователь
FUNCTION GET_USER_SONGS(
    P_USER_ID IN NUMBER
) RETURN SYS_REFCURSOR
IS
    V_CURSOR SYS_REFCURSOR;
BEGIN
    -- Проверяем существование пользователя
    IF NOT USER_EXISTS(P_USER_ID) THEN
        RAISE_APPLICATION_ERROR(-20000, 'User not found. Please provide a valid user ID.');
    END IF;

    -- Возвращаем курсор с песнями пользователя
    OPEN V_CURSOR FOR
        SELECT S.SONG_ID, S.GENRE_ID, S.SONG, S.SONG_COVER, S.SONG_NAME, S.LISTENING_COUNTER, S.AUTHOR_ID
        FROM SONGS S
        WHERE S.AUTHOR_ID = P_USER_ID;

    RETURN V_CURSOR;

EXCEPTION
    WHEN OTHERS THEN
        -- Обработка ошибок, возвращение сообщения об ошибке
        RAISE_APPLICATION_ERROR(-20001, 'Error: ' || SQLCODE || ' - ' || SQLERRM);
END GET_USER_SONGS;






--ПРОСЛУШАТЬ ПЕСНЮ
PROCEDURE LISTEN_TO_SONG(
   P_USER_ID IN NUMBER,
   P_SONG_ID IN NUMBER
)
IS
   V_MP3_PATH VARCHAR2(255);
   empty_parameter_ex EXCEPTION;
BEGIN
    -- Проверяем существование пользователя
    IF NOT USER_EXISTS(P_USER_ID) THEN
        RAISE_APPLICATION_ERROR(-20000, 'User not found. Please provide a valid user ID.');
    END IF;

    -- Проверяем, переданы ли обязательные параметры
    IF P_USER_ID IS NULL OR P_SONG_ID IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;

    -- Увеличиваем счетчик прослушиваний
    UPDATE SONGS SET LISTENING_COUNTER = LISTENING_COUNTER + 1 WHERE SONG_ID = P_SONG_ID;

    -- Добавляем запись в историю прослушиваний
    INSERT INTO LISTENING_HISTORY (USER_ID, SONG_ID, AUDITION_DATE)
    VALUES (P_USER_ID, P_SONG_ID, SYSDATE);

    COMMIT;

EXCEPTION
    WHEN empty_parameter_ex THEN
        RAISE_APPLICATION_ERROR(-20001, 'Empty parameter');
    WHEN OTHERS THEN
        -- Обработка ошибок, возвращение сообщения об ошибке
        RAISE_APPLICATION_ERROR(-20002, 'Error: ' || SQLCODE || ' - ' || SQLERRM);
END LISTEN_TO_SONG;


END SONG_MANAGEMENT_PACKAGE;
--================================--
--СОЗДАНИЕ ПЛЕЙЛИСТА ПОЛЬЗОВАТЕЛЯ--
--================================--
CREATE OR REPLACE PACKAGE PLAYLIST_MANAGEMENT_PACKAGE AS
    -- Создание плейлиста пользователя
    FUNCTION CREATE_PLAYLIST(
        P_USER_ID IN NUMBER,
        P_PLAYLIST_NAME IN VARCHAR2,
        P_PLAYLIST_COVER IN VARCHAR2
    ) RETURN VARCHAR2;

    -- Удаление плейлиста пользователя
    FUNCTION DELETE_PLAYLIST(
        P_USER_ID IN NUMBER,
        P_PLAYLIST_NAME IN VARCHAR2
    ) RETURN VARCHAR2;

    -- Добавление песни в плейлист
    FUNCTION ADD_SONG_TO_PLAYLIST(
        P_USER_ID IN NUMBER,
        P_PLAYLIST_ID IN NUMBER,
        P_SONG_ID IN NUMBER
    ) RETURN VARCHAR2;

    -- Удаление песни из плейлиста
    FUNCTION REMOVE_SONG_FROM_PLAYLIST(
        P_USER_ID IN NUMBER,
        P_PLAYLIST_ID IN NUMBER,
        P_SONG_ID IN NUMBER
    ) RETURN VARCHAR2;

    -- Редактирование плейлиста
    FUNCTION EDIT_PLAYLIST(
        P_USER_ID IN NUMBER,
        P_PLAYLIST_ID IN NUMBER,
        P_CHANGES SYS.ODCIVARCHAR2LIST
    ) RETURN VARCHAR2;

    -- Получение песен из плейлиста
    FUNCTION GET_SONGS_FROM_PLAYLIST(
        P_USER_ID IN NUMBER,
        P_PLAYLIST_ID IN NUMBER
    ) RETURN SYS_REFCURSOR;

    -- Получение всех плейлистов пользователя
    FUNCTION GET_USER_PLAYLISTS(
        P_USER_ID IN NUMBER
    ) RETURN SYS_REFCURSOR;
END PLAYLIST_MANAGEMENT_PACKAGE;

CREATE OR REPLACE PACKAGE BODY PLAYLIST_MANAGEMENT_PACKAGE AS
FUNCTION CREATE_PLAYLIST(
    P_USER_ID IN NUMBER,
    P_PLAYLIST_NAME IN VARCHAR2,
    P_PLAYLIST_COVER IN VARCHAR2
) RETURN VARCHAR2
IS
    empty_parameter_ex EXCEPTION;
    V_PLAYLIST_COUNT NUMBER;
    V_USER_COUNT NUMBER;
BEGIN
    -- Проверяем существование пользователя
    IF NOT USER_EXISTS(P_USER_ID) THEN
        RAISE_APPLICATION_ERROR(-20000, 'User not found. Please provide a valid user ID.');
    END IF;

    -- Проверяем, переданы ли обязательные параметры
    IF P_USER_ID IS NULL OR TRIM(P_PLAYLIST_NAME) IS NULL OR TRIM(P_PLAYLIST_COVER) IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;

    -- Проверяем, существует ли уже плейлист с таким именем у пользователя
    SELECT COUNT(*)
    INTO V_PLAYLIST_COUNT
    FROM PLAYLIST
    WHERE USER_ID = P_USER_ID AND PLAYLIST_NAME = TRIM(P_PLAYLIST_NAME);

    IF V_PLAYLIST_COUNT = 0 THEN
        -- Плейлист с таким именем не существует, создаем новый
        INSERT INTO PLAYLIST (USER_ID, PLAYLIST_NAME, PLAYLIST_COVER)
        VALUES (P_USER_ID, TRIM(P_PLAYLIST_NAME), TRIM(P_PLAYLIST_COVER));

        COMMIT; -- Фиксируем изменения

        RETURN 'Playlist created successfully.';
    ELSE
        -- Плейлист с таким именем уже существует
        RAISE_APPLICATION_ERROR(-20001, 'Playlist with this name already exists. Please choose a different name.');
    END IF;

EXCEPTION
    WHEN empty_parameter_ex THEN
        RAISE_APPLICATION_ERROR(-20002, 'Empty parameter');
    WHEN OTHERS THEN
        -- Обработка ошибок, возвращение сообщения об ошибке
        RAISE_APPLICATION_ERROR(-20003, 'Error: ' || SQLCODE || ' - ' || SQLERRM);
END CREATE_PLAYLIST;



-- УДАЛЕНИЕ ПЛЕЙЛИСТА ПОЛЬЗОВАТЕЛЯ --

FUNCTION DELETE_PLAYLIST(
    P_USER_ID IN NUMBER,
    P_PLAYLIST_NAME IN VARCHAR2
) RETURN VARCHAR2
IS
    empty_parameter_ex EXCEPTION;
    V_PLAYLIST_COUNT NUMBER;
BEGIN
    -- Проверяем существование пользователя
    IF NOT USER_EXISTS(P_USER_ID) THEN
        RAISE_APPLICATION_ERROR(-20000, 'User not found. Please provide a valid user ID.');
    END IF;

    -- Проверяем, переданы ли обязательные параметры
    IF TRIM(P_USER_ID) IS NULL OR TRIM(P_PLAYLIST_NAME) IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;

    -- Проверяем, существует ли плейлист с таким именем у пользователя
    SELECT COUNT(*)
    INTO V_PLAYLIST_COUNT
    FROM PLAYLIST
    WHERE USER_ID = P_USER_ID AND PLAYLIST_NAME = P_PLAYLIST_NAME;

    IF V_PLAYLIST_COUNT > 0 THEN
        -- Удаляем плейлист
        DELETE FROM PLAYLIST
        WHERE USER_ID = P_USER_ID AND PLAYLIST_NAME = P_PLAYLIST_NAME;

        COMMIT; -- Фиксируем изменения

        RETURN 'Playlist deleted successfully.';
    ELSE
        -- Плейлист с таким именем не найден
        RAISE_APPLICATION_ERROR(-20001, 'Playlist not found. Please provide a valid playlist name.');
    END IF;

EXCEPTION
    WHEN empty_parameter_ex THEN
        RAISE_APPLICATION_ERROR(-20002, 'Empty parameter');
    WHEN OTHERS THEN
        -- Обработка ошибок, возвращение сообщения об ошибке
        RAISE_APPLICATION_ERROR(-20003, 'Error: ' || SQLCODE || ' - ' || SQLERRM);
END DELETE_PLAYLIST;


--Добавление песни в плейлист--

FUNCTION ADD_SONG_TO_PLAYLIST(
    P_USER_ID IN NUMBER,
    P_PLAYLIST_ID IN NUMBER,
    P_SONG_ID IN NUMBER
) RETURN VARCHAR2
IS
    V_PLAYLIST_COUNT NUMBER;
    V_SONG_EXISTS NUMBER;
    empty_parameter_ex EXCEPTION;
BEGIN
    -- Проверяем существование пользователя
    IF NOT USER_EXISTS(P_USER_ID) THEN
        RAISE_APPLICATION_ERROR(-20000, 'User not found. Please provide a valid user ID.');
    END IF;

    -- Проверяем, переданы ли обязательные параметры
    IF TRIM(P_USER_ID) IS NULL OR TRIM(P_PLAYLIST_ID) IS NULL OR TRIM(P_SONG_ID) IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;

    -- Проверяем, существует ли плейлист
    SELECT COUNT(*)
    INTO V_PLAYLIST_COUNT
    FROM PLAYLIST
    WHERE PLAYLIST_ID = P_PLAYLIST_ID AND USER_ID = P_USER_ID;

    IF V_PLAYLIST_COUNT > 0 THEN
        -- Проверяем, существует ли песня
        SELECT COUNT(*)
        INTO V_SONG_EXISTS
        FROM SONGS
        WHERE SONG_ID = P_SONG_ID;

        IF V_SONG_EXISTS > 0 THEN
            -- Проверяем, есть ли уже эта песня в плейлисте
            SELECT COUNT(*)
            INTO V_PLAYLIST_COUNT
            FROM PLAYLIST_SONG
            WHERE PLAYLIST_ID = P_PLAYLIST_ID AND SONG_ID = P_SONG_ID;

            IF V_PLAYLIST_COUNT = 0 THEN
                -- Песни нет в плейлисте, добавляем
                INSERT INTO PLAYLIST_SONG (PLAYLIST_ID, SONG_ID)
                VALUES (P_PLAYLIST_ID, P_SONG_ID);

                COMMIT; -- Фиксируем изменения

                RETURN 'Song added to the playlist successfully.';
            ELSE
                -- Песня уже есть в плейлисте
                RAISE_APPLICATION_ERROR(-20001, 'This song is already in the playlist.');
            END IF;
        ELSE
            -- Песня не найдена
            RAISE_APPLICATION_ERROR(-20002, 'Song not found. Please provide a valid song ID.');
        END IF;
    ELSE
        -- Плейлист не найден
        RAISE_APPLICATION_ERROR(-20003, 'Playlist not found. Please provide a valid playlist ID.');
    END IF;

EXCEPTION
    WHEN empty_parameter_ex THEN
        RAISE_APPLICATION_ERROR(-20004, 'Empty parameter');
    WHEN OTHERS THEN
        -- Обработка ошибок, возвращение сообщения об ошибке
        RAISE_APPLICATION_ERROR(-20005, 'Error: ' || SQLCODE || ' - ' || SQLERRM);
END ADD_SONG_TO_PLAYLIST;


--Удаление песни из плейлиста--

FUNCTION REMOVE_SONG_FROM_PLAYLIST(
    P_USER_ID IN NUMBER,
    P_PLAYLIST_ID IN NUMBER,
    P_SONG_ID IN NUMBER
) RETURN VARCHAR2
IS
    empty_parameter_ex EXCEPTION;
    V_PLAYLIST_COUNT NUMBER;
BEGIN
    -- Проверяем существование пользователя
    IF NOT USER_EXISTS(P_USER_ID) THEN
        RAISE_APPLICATION_ERROR(-20000, 'User not found. Please provide a valid user ID.');
    END IF;

    -- Проверяем, переданы ли обязательные параметры
    IF TRIM(P_USER_ID) IS NULL OR TRIM(P_PLAYLIST_ID) IS NULL OR TRIM(P_SONG_ID) IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;

    -- Проверяем, существует ли плейлист
    SELECT COUNT(*)
    INTO V_PLAYLIST_COUNT
    FROM PLAYLIST
    WHERE PLAYLIST_ID = P_PLAYLIST_ID AND USER_ID = P_USER_ID;

    IF V_PLAYLIST_COUNT > 0 THEN
        -- Проверяем, существует ли песня в плейлисте
        SELECT COUNT(*)
        INTO V_PLAYLIST_COUNT
        FROM PLAYLIST_SONG
        WHERE PLAYLIST_ID = P_PLAYLIST_ID AND SONG_ID = P_SONG_ID;

        IF V_PLAYLIST_COUNT > 0 THEN
            -- Удаляем песню из плейлиста
            DELETE FROM PLAYLIST_SONG
            WHERE PLAYLIST_ID = P_PLAYLIST_ID AND SONG_ID = P_SONG_ID;

            COMMIT; -- Фиксируем изменения

            RETURN 'Song removed from the playlist successfully.';
        ELSE
            -- Песня не найдена в плейлисте
            RAISE_APPLICATION_ERROR(-20001, 'Song not found in the playlist. Please provide a valid song ID.');
        END IF;
    ELSE
        -- Плейлист не найден
        RAISE_APPLICATION_ERROR(-20002, 'Playlist not found. Please provide a valid playlist ID.');
    END IF;

EXCEPTION
    WHEN empty_parameter_ex THEN
        RAISE_APPLICATION_ERROR(-20003, 'Empty parameter');
    WHEN OTHERS THEN
        -- Обработка ошибок, возвращение сообщения об ошибке
        RAISE_APPLICATION_ERROR(-20004, 'Error: ' || SQLCODE || ' - ' || SQLERRM);
END REMOVE_SONG_FROM_PLAYLIST;


-- Редактирование плейлиста --
FUNCTION EDIT_PLAYLIST(
    P_USER_ID IN NUMBER,
    P_PLAYLIST_ID IN NUMBER,
    P_CHANGES SYS.ODCIVARCHAR2LIST
) RETURN VARCHAR2
IS
    V_PLAYLIST_COUNT NUMBER;
    V_NEW_NAME VARCHAR2(50);
    V_NEW_COVER VARCHAR2(100);
    I NUMBER := 1; -- начальное значение индекса
    empty_parameter_ex EXCEPTION;

BEGIN
    -- Проверяем существование пользователя
    IF NOT USER_EXISTS(P_USER_ID) THEN
        RAISE_APPLICATION_ERROR(-20000, 'User not found. Please provide a valid user ID.');
    END IF;

    -- Проверяем, переданы ли обязательные параметры
    IF TRIM(P_PLAYLIST_ID) IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;

    -- Инициализируем переменные значениями по умолчанию
    V_NEW_NAME := NULL;
    V_NEW_COVER := NULL;

    -- Извлекаем значения из ассоциативного массива
    WHILE I <= P_CHANGES.COUNT
    LOOP
        CASE P_CHANGES(I)
            WHEN 'NAME' THEN
                V_NEW_NAME := P_CHANGES(I + 1);
                I := I + 2; -- увеличиваем индекс на 2, чтобы пропустить следующий элемент
            WHEN 'COVER' THEN
                V_NEW_COVER := P_CHANGES(I + 1);
                I := I + 2; -- увеличиваем индекс на 2, чтобы пропустить следующий элемент
        END CASE;
    END LOOP;

    -- Проверяем, существует ли плейлист
    SELECT COUNT(*)
    INTO V_PLAYLIST_COUNT
    FROM PLAYLIST
    WHERE PLAYLIST_ID = P_PLAYLIST_ID AND USER_ID = P_USER_ID;

    IF V_PLAYLIST_COUNT > 0 THEN
        -- Плейлист найден, обновляем информацию
        UPDATE PLAYLIST
        SET
            PLAYLIST_NAME = COALESCE(V_NEW_NAME, PLAYLIST_NAME),
            PLAYLIST_COVER = COALESCE(V_NEW_COVER, PLAYLIST_COVER)
        WHERE PLAYLIST_ID = P_PLAYLIST_ID AND USER_ID = P_USER_ID;

        COMMIT; -- Фиксируем изменения

        RETURN 'Playlist updated successfully.';
    ELSE
        -- Плейлист не найден
        RAISE_APPLICATION_ERROR(-20001, 'Playlist not found. Please provide a valid playlist ID.');
    END IF;

EXCEPTION
    WHEN empty_parameter_ex THEN
        RAISE_APPLICATION_ERROR(-20002, 'Empty parameter');
    WHEN OTHERS THEN
        -- Обработка ошибок, возвращение сообщения об ошибке
        RAISE_APPLICATION_ERROR(-20003, 'Error: ' || SQLCODE || ' - ' || SQLERRM);
END EDIT_PLAYLIST;


--получать песни из плейлиста--
FUNCTION GET_SONGS_FROM_PLAYLIST(
    P_USER_ID IN NUMBER,
    P_PLAYLIST_ID IN NUMBER
) RETURN SYS_REFCURSOR
IS
    V_PLAYLIST_EXISTS NUMBER;
    V_CURSOR SYS_REFCURSOR;
    empty_parameter_ex EXCEPTION;

BEGIN
    -- Проверяем существование пользователя
    IF NOT USER_EXISTS(P_USER_ID) THEN
        RAISE_APPLICATION_ERROR(-20000, 'User not found. Please provide a valid user ID.');
    END IF;

    -- Проверяем, переданы ли обязательные параметры
    IF TRIM(P_PLAYLIST_ID) IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;

    -- Проверяем существование плейлиста у пользователя
    SELECT COUNT(*)
    INTO V_PLAYLIST_EXISTS
    FROM PLAYLIST
    WHERE PLAYLIST_ID = P_PLAYLIST_ID AND USER_ID = P_USER_ID;

    IF V_PLAYLIST_EXISTS = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Playlist not found. Please provide a valid playlist ID.');
    END IF;

    -- Возвращаем курсор с песнями из плейлиста
    OPEN V_CURSOR FOR
        SELECT S.SONG_ID, S.GENRE_ID, S.SONG, S.SONG_COVER, S.SONG_NAME, S.LISTENING_COUNTER, S.AUTHOR_ID
        FROM SONGS S
        JOIN PLAYLIST_SONG PS ON S.SONG_ID = PS.SONG_ID
        WHERE PS.PLAYLIST_ID = P_PLAYLIST_ID;

    RETURN V_CURSOR;
EXCEPTION
    WHEN empty_parameter_ex THEN
        RAISE_APPLICATION_ERROR(-20002, 'Empty parameter');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Error in GET_SONGS_FROM_PLAYLIST FUNCTION: ' || SQLCODE || ' - ' || SQLERRM);
END GET_SONGS_FROM_PLAYLIST;


--получение всех плейлистов --
FUNCTION GET_USER_PLAYLISTS(
    P_USER_ID IN NUMBER
) RETURN SYS_REFCURSOR
IS
    V_CURSOR SYS_REFCURSOR;
    empty_parameter_ex EXCEPTION;

BEGIN
    -- Проверяем существование пользователя
    IF NOT USER_EXISTS(P_USER_ID) THEN
        RAISE_APPLICATION_ERROR(-20000, 'User not found. Please provide a valid user ID.');
    END IF;

    -- Проверяем, передан ли обязательный параметр
    IF P_USER_ID IS NULL THEN
        RAISE empty_parameter_ex;
    END IF;

    OPEN V_CURSOR FOR
        SELECT PLAYLIST_ID, PLAYLIST_NAME, PLAYLIST_COVER
        FROM PLAYLIST
        WHERE USER_ID = P_USER_ID;

    RETURN V_CURSOR;
EXCEPTION
    WHEN empty_parameter_ex THEN
        RAISE_APPLICATION_ERROR(-20001, 'Empty parameter');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Error in GET_USER_PLAYLISTS FUNCTION: ' || SQLCODE || ' - ' || SQLERRM);
END GET_USER_PLAYLISTS;

END PLAYLIST_MANAGEMENT_PACKAGE;
--================================--
--Пользователь и альбомы
--================================--
CREATE OR REPLACE PACKAGE USER_ALBUM_PACKAGE AS
  -- Подписка на альбом
  FUNCTION SUBSCRIBE_TO_ALBUM(P_USER_ID IN NUMBER, P_ALBUM_ID IN NUMBER) RETURN VARCHAR2;
  -- Отписка от альбома
  FUNCTION UNSUBSCRIBE_FROM_ALBUM(P_USER_ID IN NUMBER, P_ALBUM_ID IN NUMBER) RETURN VARCHAR2;
  -- Получить песни альбома
  FUNCTION GET_SONGS_FROM_ALBUM(P_ALBUM_ID IN NUMBER) RETURN SYS_REFCURSOR;
  -- Получить альбомы пользователя
  FUNCTION GET_USER_ALBUMS(P_USER_ID IN NUMBER) RETURN SYS_REFCURSOR;

END USER_ALBUM_PACKAGE;
CREATE OR REPLACE PACKAGE BODY USER_ALBUM_PACKAGE AS
--Подписка на альбом --
FUNCTION SUBSCRIBE_TO_ALBUM(
    P_USER_ID IN NUMBER,
    P_ALBUM_ID IN NUMBER
) RETURN VARCHAR2
IS
    V_USER_EXISTS NUMBER;
    V_ALBUM_EXISTS NUMBER;
    V_ALREADY_SUBSCRIBED NUMBER;
    empty_parameter_ex EXCEPTION;

BEGIN
    -- Проверяем существование пользователя
    SELECT COUNT(*)
    INTO V_USER_EXISTS
    FROM USERS
    WHERE USER_ID = P_USER_ID;

    IF V_USER_EXISTS = 0 THEN
        RAISE_APPLICATION_ERROR(-20000, 'User not found. Please provide a valid user ID.');
    END IF;

    -- Проверяем существование альбома
    SELECT COUNT(*)
    INTO V_ALBUM_EXISTS
    FROM ALBUMS
    WHERE ALBUM_ID = P_ALBUM_ID;

    IF V_ALBUM_EXISTS = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Album not found. Please provide a valid album ID.');
    END IF;

    -- Проверяем, не подписан ли пользователь уже на этот альбом (если нужно)
    SELECT COUNT(*)
    INTO V_ALREADY_SUBSCRIBED
    FROM ALBUM_USER
    WHERE USER_ID = P_USER_ID AND ALBUM_ID = P_ALBUM_ID;

    IF V_ALREADY_SUBSCRIBED > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'User is already subscribed to this album.');
    END IF;

    -- Подписываем пользователя на альбом
    INSERT INTO ALBUM_USER (USER_ID, ALBUM_ID)
    VALUES (P_USER_ID, P_ALBUM_ID);

    COMMIT; -- Фиксируем изменения

    RETURN 'User subscribed to the album successfully.';

EXCEPTION
    WHEN empty_parameter_ex THEN
        RAISE_APPLICATION_ERROR(-20003, 'Empty parameter');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20004, 'Error in SUBSCRIBE_TO_ALBUM function: ' || SQLCODE || ' - ' || SQLERRM);
END SUBSCRIBE_TO_ALBUM;


-- Отписка от Альбома --
FUNCTION UNSUBSCRIBE_FROM_ALBUM(
    P_USER_ID IN NUMBER,
    P_ALBUM_ID IN NUMBER
) RETURN VARCHAR2
IS
    V_USER_EXISTS NUMBER;
    V_ALBUM_EXISTS NUMBER;
    V_SUBSCRIBED NUMBER;
    empty_parameter_ex EXCEPTION;

BEGIN
    -- Проверяем существование пользователя
    SELECT COUNT(*)
    INTO V_USER_EXISTS
    FROM USERS
    WHERE USER_ID = P_USER_ID;

    IF V_USER_EXISTS = 0 THEN
        RAISE_APPLICATION_ERROR(-20000, 'User not found. Please provide a valid user ID.');
    END IF;

    -- Проверяем существование альбома
    SELECT COUNT(*)
    INTO V_ALBUM_EXISTS
    FROM ALBUMS
    WHERE ALBUM_ID = P_ALBUM_ID;

    IF V_ALBUM_EXISTS = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Album not found. Please provide a valid album ID.');
    END IF;

    -- Проверяем, подписан ли пользователь на этот альбом
    SELECT COUNT(*)
    INTO V_SUBSCRIBED
    FROM ALBUM_USER
    WHERE USER_ID = P_USER_ID AND ALBUM_ID = P_ALBUM_ID;

    IF V_SUBSCRIBED = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'User is not subscribed to this album.');
    END IF;

    -- Отписываем пользователя от альбома
    DELETE FROM ALBUM_USER
    WHERE USER_ID = P_USER_ID AND ALBUM_ID = P_ALBUM_ID;

    COMMIT; -- Фиксируем изменения

    RETURN 'User unsubscribed from the album successfully.';

EXCEPTION
    WHEN empty_parameter_ex THEN
        RAISE_APPLICATION_ERROR(-20003, 'Empty parameter');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20004, 'Error in UNSUBSCRIBE_FROM_ALBUM function: ' || SQLCODE || ' - ' || SQLERRM);
END UNSUBSCRIBE_FROM_ALBUM;


-- Получить песни альбома --

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


--Получить альбомы на которые подписан пользователь--
FUNCTION GET_USER_ALBUMS(
    P_USER_ID IN NUMBER
) RETURN SYS_REFCURSOR
IS
    V_CURSOR SYS_REFCURSOR;
    empty_parameter_ex EXCEPTION;

BEGIN
    IF TRIM(P_USER_ID) IS NULL THEN
        RAISE_APPLICATION_ERROR(-20000, 'Empty parameter');
    END IF;

    -- Возвращаем курсор с альбомами пользователя
    OPEN V_CURSOR FOR
        SELECT A.ALBUM_ID, A.ALBUM_COVER, A.RELEASE_DATE, A.ALBUM_NAME
        FROM ALBUMS A
        JOIN ALBUM_USER AU ON A.ALBUM_ID = AU.ALBUM_ID
        WHERE AU.USER_ID = P_USER_ID;

    RETURN V_CURSOR;

EXCEPTION
    WHEN empty_parameter_ex THEN
        RAISE_APPLICATION_ERROR(-20001, 'Empty parameter');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Error in GET_USER_ALBUMS function: ' || SQLCODE || ' - ' || SQLERRM);
END GET_USER_ALBUMS;

END USER_ALBUM_PACKAGE;


