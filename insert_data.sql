-- Заполнение таблицы ROLES


-- Заполнение таблицы ROLES
INSERT INTO ROLES (ROLE_NAME) VALUES ('USER');
INSERT INTO ROLES (ROLE_NAME) VALUES ('ADMIN');
INSERT INTO ROLES (ROLE_NAME) VALUES ('AUTHOR');

-- Заполнение таблицы USERS
INSERT INTO USERS (USER_ROLE, USER_NAME, USER_LOGIN, USER_PASS) VALUES ('USER', 'User1', 'user1_login', 'password1');
INSERT INTO USERS (USER_ROLE, USER_NAME, USER_LOGIN, USER_PASS) VALUES ('USER', 'User2', 'user2_login', 'password2');
INSERT INTO USERS (USER_ROLE, USER_NAME, USER_LOGIN, USER_PASS) VALUES ('ADMIN', 'Admin1', 'admin1_login', 'admin_password');
INSERT INTO USERS (USER_ROLE, USER_NAME, USER_LOGIN, USER_PASS) VALUES ('AUTHOR', 'Author1', 'author1_login', 'author_password');

-- Заполнение таблицы PLAYLIST
INSERT INTO PLAYLIST (PLAYLIST_NAME, PLAYLIST_COVER, USER_ID) VALUES ('Playlist1', 'cover1.jpg', 1);
INSERT INTO PLAYLIST (PLAYLIST_NAME, PLAYLIST_COVER, USER_ID) VALUES ('Playlist2', 'cover2.jpg', 1);
INSERT INTO PLAYLIST (PLAYLIST_NAME, PLAYLIST_COVER, USER_ID) VALUES ('Playlist3', 'cover3.jpg', 2);

-- Заполнение таблицы SONGS
INSERT INTO SONGS (GENRE_ID, SONG, SONG_COVER, SONG_NAME, LISTENING_COUNTER, AUTHOR_ID) VALUES (2, 'D:\УНИК\Семестр 5\урсач\TestSearch\public\audio\Gloryhammer - The Land of Unicorns-1.mp3', 'Cover2.jpg', 'Song2', 0, 3);
INSERT INTO SONGS (GENRE_ID, SONG, SONG_COVER, SONG_NAME, LISTENING_COUNTER, AUTHOR_ID) VALUES (2, 'D:\УНИК\Семестр 5\урсач\TestSearch\public\audio\Nirvana - Smels Like Teen Spirit.mp3', 'C:\Users\Ta4e\Desktop\msg1030981363-73427.jpg', 'Song2', 0, 2);
INSERT INTO SONGS (GENRE_ID, SONG, SONG_COVER, SONG_NAME, LISTENING_COUNTER, AUTHOR_ID) VALUES (2, 'D:\УНИК\Семестр 5\урсач\TestSearch\public\audio\Gloryhammer - Gloryhammer.mp3', 'C:\Users\Ta4e\Desktop\msg1030981363-73427.jpg', 'Song2', 0, 2);
INSERT INTO SONGS (GENRE_ID, SONG, SONG_COVER, SONG_NAME, LISTENING_COUNTER, AUTHOR_ID) VALUES (2, 'D:\УНИК\Семестр 5\урсач\TestSearch\public\audio\Powerwolf - Higher Than Heaven.mp3', 'C:\Users\Ta4e\Desktop\msg1030981363-73427.jpg', 'Song2', 0, 2);
INSERT INTO SONGS (GENRE_ID, SONG, SONG_COVER, SONG_NAME, LISTENING_COUNTER, AUTHOR_ID) VALUES (2, 'D:\УНИК\Семестр 5\урсач\TestSearch\public\audio\Nirvana - Smels Like Teen Spirit.mp3', 'C:\Users\Ta4e\Desktop\msg1030981363-73427.jpg', 'Song2', 0, 2);
INSERT INTO SONGS (GENRE_ID, SONG, SONG_COVER, SONG_NAME, LISTENING_COUNTER, AUTHOR_ID) VALUES (2, 'D:\УНИК\Семестр 5\урсач\TestSearch\public\audio\Nirvana - Smels Like Teen Spirit.mp3', 'C:\Users\Ta4e\Desktop\msg1030981363-73427.jpg', 'Song2', 0, 2);
INSERT INTO SONGS (GENRE_ID, SONG, SONG_COVER, SONG_NAME, LISTENING_COUNTER, AUTHOR_ID) VALUES (2, 'D:\УНИК\Семестр 5\урсач\TestSearch\public\audio\Nirvana - Smels Like Teen Spirit.mp3', 'C:\Users\Ta4e\Desktop\msg1030981363-73427.jpg', 'Song2', 0, 2);

select * from SONGS;
select * from SONG_USER;
select * from USERS;
select * from PLAYLIST;

-- Заполнение таблицы SONG_USER
INSERT INTO SONG_USER (SONG_ID, USER_ID) VALUES (81, 51);
INSERT INTO SONG_USER (SONG_ID, USER_ID) VALUES (82, 51);
INSERT INTO SONG_USER (SONG_ID, USER_ID) VALUES (83, 53);

-- Заполнение таблицы PLAYLIST_SONG
INSERT INTO PLAYLIST_SONG (PLAYLIST_ID, SONG_ID) VALUES (1, 81);
INSERT INTO PLAYLIST_SONG (PLAYLIST_ID, SONG_ID) VALUES (2, 82);
INSERT INTO PLAYLIST_SONG (PLAYLIST_ID, SONG_ID) VALUES (24, 83);

-- Заполнение таблицы LISTENING_HISTORY
INSERT INTO LISTENING_HISTORY (USER_ID, SONG_ID, AUDITION_DATE) VALUES (1, 1, SYSDATE - 5);
INSERT INTO LISTENING_HISTORY (USER_ID, SONG_ID, AUDITION_DATE) VALUES (1, 2, SYSDATE - 3);
INSERT INTO LISTENING_HISTORY (USER_ID, SONG_ID, AUDITION_DATE) VALUES (2, 3, SYSDATE - 2);

-- Заполнение таблицы ALBUMS
INSERT INTO ALBUMS (ALBUM_COVER, RELEASE_DATE, ALBUM_NAME) VALUES ('album_cover1.jpg', SYSDATE - 10, 'Album One');
INSERT INTO ALBUMS (ALBUM_COVER, RELEASE_DATE, ALBUM_NAME) VALUES ('album_cover2.jpg', SYSDATE - 7, 'Album Two');

-- Заполнение таблицы ALBUM_USER
INSERT INTO ALBUM_USER (ALBUM_ID, USER_ID) VALUES (1, 1);
INSERT INTO ALBUM_USER (ALBUM_ID, USER_ID) VALUES (2, 2);

-- Заполнение таблицы ALBUM_SONG
INSERT INTO ALBUM_SONG (ALBUM_ID, SONG_ID) VALUES (1, 1);
INSERT INTO ALBUM_SONG (ALBUM_ID, SONG_ID) VALUES (2, 2);




commit ;

select * from SONGS;

commit ;
