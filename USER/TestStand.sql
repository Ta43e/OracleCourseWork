--Создать пользователя--
BEGIN
    MYADMIN.create_user('USER', 'Oleg', 'dr.oleg@bgtu.by', '123456');
end;

DECLARE
    V_USER_ID INTEGER;
BEGIN
    V_USER_ID := MYADMIN.GET_USER_ID_BY_NAME('Oleg');
    DBMS_OUTPUT.PUT_LINE('User ID: ' || V_USER_ID);
END;
--=====Создание плейлиста====--
DECLARE
    Result VARCHAR2(200);
BEGIN
    Result := MYADMIN.PLAYLIST_MANAGEMENT_PACKAGE.CREATE_PLAYLIST(185, 'MyOlayList2', 'D:\\TestSearch\\public\\image\\image.png');
    DBMS_OUTPUT.PUT_LINE(Result);
END;

-- Вывод плейлистов --
DECLARE
    V_USER_ID NUMBER := 185;
    V_PLAYLIST_ID NUMBER;
    V_PLAYLIST_NAME VARCHAR2(50);
    V_PLAYLIST_COVER VARCHAR2(50);
    V_CURSOR SYS_REFCURSOR;
BEGIN
    V_CURSOR := MYADMIN.PLAYLIST_MANAGEMENT_PACKAGE.GET_USER_PLAYLISTS(V_USER_ID);

    LOOP
        FETCH V_CURSOR INTO V_PLAYLIST_ID, V_PLAYLIST_NAME, V_PLAYLIST_COVER;
        EXIT WHEN V_CURSOR%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Playlist ID: ' || V_PLAYLIST_ID || ', Playlist Name: ' || V_PLAYLIST_NAME || ', Playlist Cover: ' || V_PLAYLIST_COVER);
    END LOOP;

    CLOSE V_CURSOR;
END;



--=====Добавление песни в playlist====--
DECLARE
    Result VARCHAR2(200);
BEGIN
     Result := MYADMIN.PLAYLIST_MANAGEMENT_PACKAGE.ADD_SONG_TO_PLAYLIST(185, 127, 305000);
     DBMS_OUTPUT.PUT_LINE(Result);
end;



--=====Удаление плейлиста пользователя====--

DECLARE
    Result VARCHAR2(200);
BEGIN
    Result := MYADMIN.PLAYLIST_MANAGEMENT_PACKAGE.DELETE_PLAYLIST(185, 'MYPLayYlistOleg');
    DBMS_OUTPUT.PUT_LINE(Result);
END;

--=====Редактирование плейлиста====--

DECLARE
    V_RESULT VARCHAR2(100);
BEGIN
    V_RESULT := MYADMIN.PLAYLIST_MANAGEMENT_PACKAGE.EDIT_PLAYLIST(
        P_USER_ID => 185,
        P_PLAYLIST_ID => 126,
        P_CHANGES => SYS.ODCIVARCHAR2LIST('COVER', 'qwe')
    );
    DBMS_OUTPUT.PUT_LINE(V_RESULT);
END;

--=====Получать песни из плейлиста--====--

DECLARE
    -- Объявите переменные для хранения параметров и результата
    V_USER_ID NUMBER := 185;
    V_PLAYLIST_ID NUMBER := 127;
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

--=====Добавление песни в favorite====--

DECLARE
    Result VARCHAR2(200);
BEGIN
    Result := MYADMIN.SONG_MANAGEMENT_PACKAGE.ADD_SONG_TO_USERLIST(185, 310000);
    DBMS_OUTPUT.PUT_LINE(Result);
END;
-- Песни из фаворитов
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
    V_CURSOR := MYADMIN.SONG_MANAGEMENT_PACKAGE.GET_USER_SUBSCRIBED_SONGS(185); -- Замените 1 на актуальный ID пользователя

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

--=====Прослушивание песни====--
DECLARE
    Result VARCHAR2(200);
BEGIN
     Result := MYADMIN.SONG_MANAGEMENT_PACKAGE.LISTEN_TO_SONG(124, 277727);
     DBMS_OUTPUT.PUT_LINE(Result);
end;

-- Удаление из избраных
DECLARE
    Result VARCHAR2(200);
BEGIN
    Result := MYADMIN.SONG_MANAGEMENT_PACKAGE.REMOVESONGFROMFAVORIT(124, 277727);
    DBMS_OUTPUT.PUT_LINE(Result);
END;


--================================--
--Пользователь и альбомы
--================================--
-- Все альбомы --
DECLARE
    albums_cursor SYS_REFCURSOR;
    album_id NUMBER;
    album_cover VARCHAR2(100);
    release_date DATE;
    album_name VARCHAR2(50);
BEGIN
    albums_cursor := MYADMIN.get_all_albums;

    LOOP
        FETCH albums_cursor INTO album_id, album_cover, release_date, album_name;
        EXIT WHEN albums_cursor%NOTFOUND;

        -- Здесь можешь использовать полученные данные по своему усмотрению
        DBMS_OUTPUT.PUT_LINE('Album ID: ' || album_id || ', Album Cover: ' || album_cover ||
                             ', Release Date: ' || release_date || ', Album Name: ' || album_name);
    END LOOP;

    CLOSE albums_cursor;
END;
-- Подписаться на альбом

DECLARE
    Result VARCHAR2(200);
BEGIN
     Result :=MYADMIN.USER_ALBUM_PACKAGE.SUBSCRIBE_TO_ALBUM(185, 21);
     DBMS_OUTPUT.PUT_LINE(Result);
end;

-- ПОлучить песни из альбома
DECLARE
    album_id_to_search NUMBER := 1; -- Замени 1 на конкретный идентификатор альбома, для которого хочешь получить песни
    songs_cursor SYS_REFCURSOR;
    song_id NUMBER;
    genre_id NUMBER;
    song_name VARCHAR2(200);
    song_cover VARCHAR2(200);
    listening_counter NUMBER;
    author_id NUMBER;
BEGIN
    songs_cursor := MYADMIN.USER_ALBUM_PACKAGE.GET_SONGS_FROM_ALBUM(album_id_to_search);

        LOOP
            FETCH songs_cursor INTO song_id, genre_id, song_name, song_cover, song_name, listening_counter, author_id;
            EXIT WHEN songs_cursor%NOTFOUND;

            -- Здесь можешь использовать полученные данные по своему усмотрению
            DBMS_OUTPUT.PUT_LINE('Song ID: ' || song_id || ', Genre ID: ' || genre_id || ', Song Name: ' || song_name ||
                                 ', Song Cover: ' || song_cover || ', Listening Counter: ' || listening_counter ||
                                 ', Author ID: ' || author_id);
        END LOOP;
        CLOSE songs_cursor;
END;

-- Отписаться от альбома --
DECLARE
    Result VARCHAR2(200);
BEGIN
     Result :=MYADMIN.USER_ALBUM_PACKAGE.UNSUBSCRIBE_FROM_ALBUM(124, 1);
     DBMS_OUTPUT.PUT_LINE(Result);
end;
---
----=============Действие с аккаунтом==========--
--Обновление данных --
DECLARE
    v_user_name VARCHAR2(50) := 'Balbes';
    v_cursor SYS_REFCURSOR;
    v_user_id INTEGER;
    v_user_role NVARCHAR2(64);
    v_user_name_result VARCHAR2(50);
    v_user_login VARCHAR2(50);
    v_user_pass VARCHAR2(100);
BEGIN
    v_cursor := MYADMIN.GET_USER_BY_NAME(v_user_name);

    FETCH v_cursor INTO v_user_id, v_user_role, v_user_name_result, v_user_login, v_user_pass;

    IF v_user_id IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('User ID: ' || v_user_id);
        DBMS_OUTPUT.PUT_LINE('User Name: ' || v_user_name_result);
        DBMS_OUTPUT.PUT_LINE('User Role: ' || v_user_role);
        DBMS_OUTPUT.PUT_LINE('User Login: ' || v_user_login);
        DBMS_OUTPUT.PUT_LINE('User Password: ' || v_user_pass);
    ELSE
        DBMS_OUTPUT.PUT_LINE('User not found.');
    END IF;
    CLOSE v_cursor;
END;


BEGIN
    MYADMIN.update_user('124', 'USER', 'Balbes', 'Kaif', '12345');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
END;

--Удаление пользователя--
begin
    MYADMIN.delete_user(124);
end;

-- Песни из плейлиста
select * from MYADMIN.GET_MUSIC();

DECLARE
    v_user_info SYS_REFCURSOR;
    v_user_id INTEGER := 12; -- Замените на нужный USER_ID
    v_user_name VARCHAR2(255);
BEGIN
    -- Вызываем функцию GET_USER_INFO_BY_ID и получаем курсор
    v_user_info := MYADMIN.GET_USER_INFO_BY_ID(v_user_id);

    -- Получаем значения из курсора
    FETCH v_user_info INTO v_user_id, v_user_name;

    -- Выводим информацию
    IF v_user_id IS NOT NULL AND v_user_name IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('User ID: ' || v_user_id);
        DBMS_OUTPUT.PUT_LINE('User Name: ' || v_user_name);
    ELSE
        DBMS_OUTPUT.PUT_LINE('User not found.');
    END IF;

    -- Закрываем курсор
    CLOSE v_user_info;
END;
/
