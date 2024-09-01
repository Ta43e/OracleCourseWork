CREATE OR REPLACE PROCEDURE FILL_SONGS_TABLE AS
BEGIN
    FOR i IN 1..100000
    LOOP
        DECLARE
            v_song_name VARCHAR2(100);
            v_song_file VARCHAR2(200);
            v_song_cover VARCHAR2(200);
        BEGIN
            v_song_name := 'Song' || i;
            v_song_file := 'D:\\УНИК\\Семестр 5\\урсач\\TestSearch\\public\\audio\\Dreamtale - Intro.mp3';
            v_song_cover := 'D:\\УНИК\\Семестр 5\\урсач\\TestSearch\\public\\audio\\image.jpg';

           INSERT INTO SONGS (GENRE_ID, SONG, SONG_COVER, SONG_NAME, LISTENING_COUNTER, AUTHOR_ID)
                VALUES (1, v_song_file, v_song_cover, v_song_name, 0, 53);
            END;
    END LOOP;
    COMMIT;
END FILL_SONGS_TABLE;
alter session set "_ORACLE_SCRIPT" = true;


BEGIN
    FILL_SONGS_TABLE();
end;

select * from SONGS;

select * from SONGS;

begin
    FILL_SONGS_TABLE();
end;

BEGIN
    ADD_SONG('POP', 'D:\\УНИК\\Семестр 5\\урсач\\TestSearch\\public\\audio\\David Bowie - Starman (2012 Remaster) (2012 Remaster).mp3', 'ddd', 'D:\\УНИК\\Семестр 5\\урсач\\TestSearch\\public\\audio\\image.jpg', 'Author1');
end;

SELECT * FROM SONGS;
SELECT * FROM USERS;
SELECT * FROM GENRES;