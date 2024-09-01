SELECT * FROM  SONGS;
SELECT * FROM  SONG_USER;
SELECT  * FROM USERS;

DECLARE
    Result VARCHAR2(200);
BEGIN
    Result := MYADMIN.PLAYLIST_MANAGEMENT_PACKAGE.CREATE_PLAYLIST(1, 'Imba', 'ddddd');
    DBMS_OUTPUT.PUT_LINE(Result);
END;
--УДАЛИТЬ ПЛЕЙЛИСТ
DECLARE
    Result VARCHAR2(200);
BEGIN
    Result := MYADMIN.PLAYLIST_MANAGEMENT_PACKAGE.DELETE_PLAYLIST(1, 'Imba');
    DBMS_OUTPUT.PUT_LINE(Result);
END;
--ДОБАВИТЬ ПЕСНЮ
DECLARE
    Result VARCHAR2(200);
BEGIN
    Result := MYADMIN.PLAYLIST_MANAGEMENT_PACKAGE.ADD_SONG_TO_PLAYLIST(1, 1, 22);
    DBMS_OUTPUT.PUT_LINE(Result);
END;
--УДАЛЕНИЕ ПЕСНИ
DECLARE
    Result VARCHAR2(200);
BEGIN
    Result := MYADMIN.PLAYLIST_MANAGEMENT_PACKAGE.REMOVE_SONG_FROM_PLAYLIST(1, 1, 22);
    DBMS_OUTPUT.PUT_LINE(Result);
END;

--РЕДАКТИРОВАНИЕ ПЛЕЙЛИСТА
DECLARE
    V_RESULT VARCHAR2(100);
BEGIN
    V_RESULT := MYADMIN.PLAYLIST_MANAGEMENT_PACKAGE.EDIT_PLAYLIST(
        P_USER_ID => 1,
        P_PLAYLIST_ID => 1,
        P_CHANGES => SYS.ODCIVARCHAR2LIST('COVER', 'FFFF')
    );
    DBMS_OUTPUT.PUT_LINE(V_RESULT);
END;

DECLARE
    V_CURSOR SYS_REFCURSOR;
    V_SONG_ID NUMBER;
    V_GENRE_ID NUMBER;
    V_SONG VARCHAR2(200);
    V_SONG_COVER VARCHAR2(200);
    V_SONG_NAME VARCHAR2(50);
    V_LISTENING_COUNTER NUMBER;
    V_AUTHOR_ID NUMBER;
BEGIN
    V_CURSOR := MYADMIN.SONG_MANAGEMENT_PACKAGE.GET_USER_SONGS(1); -- Замените 1 на актуальный ID пользователя

    -- Ваш код для обработки курсора
    LOOP
        FETCH V_CURSOR INTO V_SONG_ID, V_GENRE_ID, V_SONG, V_SONG_COVER, V_SONG_NAME, V_LISTENING_COUNTER, V_AUTHOR_ID;
        EXIT WHEN V_CURSOR%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('SONG_ID: ' || V_SONG_ID || ', SONG_NAME: ' || V_SONG_NAME);
        -- Дополнительная обработка, если необходимо
    END LOOP;

    -- Закрытие курсора
    CLOSE V_CURSOR;
END;


DECLARE
    Result VARCHAR2(200);
BEGIN
    Result := MYADMIN.PLAYLIST_MANAGEMENT_PACKAGE.GET_SONGS_FROM_PLAYLIST(1, 1, 22);
    DBMS_OUTPUT.PUT_LINE(Result);
END;

--ПЕСНИ ИЗ ПЛЕЙЛИСТА
DECLARE
    -- Объявите переменные для хранения параметров и результата
    V_USER_ID NUMBER := 1;
    V_PLAYLIST_ID NUMBER := 1;
    V_CURSOR SYS_REFCURSOR;
    V_SONG_ID NUMBER;
    V_GENRE_ID NUMBER;
    V_SONG VARCHAR2(200);
    V_SONG_COVER VARCHAR2(200);
    V_SONG_NAME VARCHAR2(50);
    V_LISTENING_COUNTER NUMBER;
    V_AUTHOR_ID NUMBER;
BEGIN
    -- Вызов функции и передача параметров
    V_CURSOR := MYADMIN.PLAYLIST_MANAGEMENT_PACKAGE.GET_SONGS_FROM_PLAYLIST(V_USER_ID, V_PLAYLIST_ID);

    -- Перебор результатов курсора
    LOOP
        FETCH V_CURSOR INTO V_SONG_ID, V_GENRE_ID, V_SONG, V_SONG_COVER, V_SONG_NAME, V_LISTENING_COUNTER, V_AUTHOR_ID;
        EXIT WHEN V_CURSOR%NOTFOUND;

        -- Теперь вы можете использовать переменные V_SONG_ID, V_GENRE_ID и так далее
        DBMS_OUTPUT.PUT_LINE('SONG_ID: ' || V_SONG_ID || ' GENRE_ID ' ||
                             V_GENRE_ID || ' SONG ' || V_SONG || ' SONG_COVER ' ||
                             V_SONG_COVER || ' SONG_NAME ' || V_SONG_NAME || ' LISTENING_COUNTER ' || V_LISTENING_COUNTER ||
                             ' AUTHOR_ID ' || V_AUTHOR_ID);
        -- Добавьте другие поля при необходимости
    END LOOP;

    -- Закрытие курсора
    CLOSE V_CURSOR;
END;

--ПЕСНИ ИЗ АЛЬБОМА
DECLARE
    -- Объявите переменные для хранения параметров и результата
    V_ALBUM_ID NUMBER := 2;
    V_CURSOR SYS_REFCURSOR;
    V_SONG_ID NUMBER;
    V_GENRE_ID NUMBER;
    V_SONG VARCHAR2(200);
    V_SONG_COVER VARCHAR2(200);
    V_SONG_NAME VARCHAR2(50);
    V_LISTENING_COUNTER NUMBER;
    V_AUTHOR_ID NUMBER;
BEGIN
    -- Вызов функции и передача параметров
    V_CURSOR := MYADMIN.USER_ALBUM_PACKAGE.GET_SONGS_FROM_ALBUM(V_ALBUM_ID);

    -- Перебор результатов курсора
    LOOP
        FETCH V_CURSOR INTO V_SONG_ID, V_GENRE_ID, V_SONG, V_SONG_COVER, V_SONG_NAME, V_LISTENING_COUNTER, V_AUTHOR_ID;
        EXIT WHEN V_CURSOR%NOTFOUND;

        -- Теперь вы можете использовать переменные V_SONG_ID, V_GENRE_ID и так далее
        DBMS_OUTPUT.PUT_LINE('SONG_ID: ' || V_SONG_ID || ' GENRE_ID ' ||
                             V_GENRE_ID || ' SONG ' || V_SONG || ' SONG_COVER ' ||
                             V_SONG_COVER || ' SONG_NAME ' || V_SONG_NAME || ' LISTENING_COUNTER ' || V_LISTENING_COUNTER ||
                             ' AUTHOR_ID ' || V_AUTHOR_ID);
        -- Добавьте другие поля при необходимости
    END LOOP;

    -- Закрытие курсора
    CLOSE V_CURSOR;
END;

