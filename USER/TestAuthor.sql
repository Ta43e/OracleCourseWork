BEGIN
    MYADMIN.create_user('AUTHOR', 'DRAGOONS', 'FE@R.BY', '123');
end;

DECLARE
    V_USER_ID INTEGER;
BEGIN
    V_USER_ID := MYADMIN.GET_USER_ID_BY_NAME('DRAGOONS');
    DBMS_OUTPUT.PUT_LINE('User ID: ' || V_USER_ID);
END;
--====

begin
    MYADMIN.SONGWRITER_ALBUM_PACKAGE.CREATE_ALBUM(165, 'Imba_navalivaet', 'D:/DD/DD/D.jpg');
end;

DECLARE
    V_ALBUM_CURSOR SYS_REFCURSOR;
    V_ALBUM_ID NUMBER;
    V_ALBUM_NAME VARCHAR2(100);
    V_ALBUM_COVER VARCHAR2(200);
    V_RELEASE_DATE DATE;
BEGIN
    -- Замените 1 на актуальный AUTHOR_ID
    V_ALBUM_CURSOR := MYADMIN.SONGWRITER_ALBUM_PACKAGE.GET_AUTHOR_ALBUMS(165);

    -- Получаем данные из курсора
    LOOP
        FETCH V_ALBUM_CURSOR INTO V_ALBUM_ID, V_ALBUM_NAME, V_ALBUM_COVER, V_RELEASE_DATE;
        EXIT WHEN V_ALBUM_CURSOR%NOTFOUND;

        -- Используем полученные данные (можете изменить вывод по своему усмотрению)
        DBMS_OUTPUT.PUT_LINE('Album ID: ' || V_ALBUM_ID);
        DBMS_OUTPUT.PUT_LINE('Album Name: ' || V_ALBUM_NAME);
        DBMS_OUTPUT.PUT_LINE('Album Cover: ' || V_ALBUM_COVER);
        DBMS_OUTPUT.PUT_LINE('Release Date: ' || TO_CHAR(V_RELEASE_DATE, 'YYYY-MM-DD'));
        DBMS_OUTPUT.PUT_LINE('--------------------');
    END LOOP;

    -- Закрываем курсор после использования
    CLOSE V_ALBUM_CURSOR;
END;


begin
    MYADMIN.ADD_SONG('Rock', 'D:\\УНИК\\Семестр 5\\урсач\\TestSearch\\public\\audio\\David Bowie - Starman (2012 Remaster) (2012 Remaster).mp3', 'Dadad', 'd', 'DRAGOONS');
end;


DECLARE
    V_SONG_ID INTEGER;
    V_GENRE_ID INTEGER;
    V_SONG VARCHAR2(255);
    V_SONG_COVER VARCHAR2(255);
    V_SONG_NAME VARCHAR2(255);
    V_LISTENING_COUNTER INTEGER;
    V_AUTHOR_ID INTEGER;
    V_SONG_CURSOR SYS_REFCURSOR;
BEGIN
    -- Замените 'SongName' на актуальное название песни
    V_SONG_CURSOR := MYADMIN.GET_SONG_INFO_BY_NAME('Dadad');

    -- Получаем данные из курсора
    LOOP
        FETCH V_SONG_CURSOR INTO V_SONG_ID, V_GENRE_ID, V_SONG, V_SONG_COVER, V_SONG_NAME, V_LISTENING_COUNTER, V_AUTHOR_ID;
        EXIT WHEN V_SONG_CURSOR%NOTFOUND;

        -- Используем полученные данные (можете изменить вывод по своему усмотрению)
        DBMS_OUTPUT.PUT_LINE('Song ID: ' || V_SONG_ID);
        DBMS_OUTPUT.PUT_LINE('Genre ID: ' || V_GENRE_ID);
        DBMS_OUTPUT.PUT_LINE('Song: ' || V_SONG);
        DBMS_OUTPUT.PUT_LINE('Song Cover: ' || V_SONG_COVER);
        DBMS_OUTPUT.PUT_LINE('Song Name: ' || V_SONG_NAME);
        DBMS_OUTPUT.PUT_LINE('Listening Counter: ' || V_LISTENING_COUNTER);
        DBMS_OUTPUT.PUT_LINE('Author ID: ' || V_AUTHOR_ID);
        DBMS_OUTPUT.PUT_LINE('--------------------');
    END LOOP;

    -- Закрываем курсор после использования
    CLOSE V_SONG_CURSOR;
END;
-- Добавить песню в альбом
begin
    MYADMIN.SONGWRITER_ALBUM_PACKAGE.ADD_SONG_TO_ALBUM(165,21, 380175);
end;
-- Песни автора
DECLARE
    v_user_id NUMBER := 165;
    v_result_cursor SYS_REFCURSOR;
    v_song_id NUMBER;
    v_genre_id NUMBER;
    v_song_name VARCHAR2(255);
    v_song VARCHAR2(255);
    v_song_cover VARCHAR2(255);
    v_listening_counter NUMBER;
    v_author_id NUMBER;
BEGIN
    -- Вызываем функцию GET_USER_SONGS и передаем ей ID пользователя
    v_result_cursor := MYADMIN.SONGWRITER_ALBUM_PACKAGE.GET_USER_SONGS(v_user_id);

    -- Используем курсор для обработки результатов запроса
    LOOP
        FETCH v_result_cursor INTO
            v_song_id, v_genre_id, v_song, v_song_cover, v_song_name,  v_listening_counter, v_author_id;
        EXIT WHEN v_result_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Song ID: ' || TO_CHAR(v_song_id) ||
                             ', Genre ID: ' || TO_CHAR(v_genre_id) ||
                             ', Song Name: ' || v_song_name ||
                             ', Song Cover: ' || v_song_cover ||
                             ', Listening Counter: ' || TO_CHAR(v_listening_counter) ||
                             ', Author ID: ' || TO_CHAR(v_author_id));
    END LOOP;

    -- Закрываем курсор после использования
    CLOSE v_result_cursor;
EXCEPTION
    WHEN OTHERS THEN
        -- Обработка ошибок
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
END;


DECLARE
    v_user_id NUMBER := 165;
    v_result_cursor SYS_REFCURSOR;
    v_song_id NUMBER;
    v_genre_id NUMBER;
    v_song_name VARCHAR2(255);
    v_song VARCHAR2(255);
    v_song_cover VARCHAR2(255);
    v_listening_counter NUMBER;
    v_author_id NUMBER;
BEGIN
    -- Вызываем функцию GET_USER_SONGS и передаем ей ID пользователя
    v_result_cursor := MYADMIN.SONGWRITER_ALBUM_PACKAGE.GET_SONGS_FROM_ALBUM(21);

    -- Используем курсор для обработки результатов запроса
    LOOP
        FETCH v_result_cursor INTO
            v_song_id, v_genre_id, v_song, v_song_cover, v_song_name,  v_listening_counter, v_author_id;
        EXIT WHEN v_result_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Song ID: ' || TO_CHAR(v_song_id) ||
                             ', Genre ID: ' || TO_CHAR(v_genre_id) ||
                             ', Song Name: ' || v_song_name ||
                             ', Song Cover: ' || v_song_cover ||
                             ', Listening Counter: ' || TO_CHAR(v_listening_counter) ||
                             ', Author ID: ' || TO_CHAR(v_author_id));
    END LOOP;

    -- Закрываем курсор после использования
    CLOSE v_result_cursor;
EXCEPTION
    WHEN OTHERS THEN
        -- Обработка ошибок
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
END;

-- Все песни
select * from MYADMIN.GET_MUSIC();




/

