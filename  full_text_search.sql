-- Создание индекса для SONG_NAME
CREATE INDEX SONGS_NAME_IDX ON SONGS(SONG_NAME)
INDEXTYPE IS CTXSYS.CONTEXT;

drop index  SONGS_NAME_IDX;


CREATE OR REPLACE FUNCTION SearchSongs(p_search_term VARCHAR2)
RETURN SYS_REFCURSOR
IS
  RESULT_CURSOR SYS_REFCURSOR;
BEGIN
  OPEN RESULT_CURSOR FOR
    SELECT *
    FROM SONGS
    WHERE CONTAINS(SONG_NAME, '%' || p_search_term || '%', 1) > 0;

  RETURN RESULT_CURSOR;
END SearchSongs;

--------------------------------------------------------

SELECT *
FROM SONGS
WHERE SONG_NAME LIKE 'Song37';

SELECT *
FROM SONGS
WHERE CONTAINS(SONG_NAME, 'Song37') > 0;

select * from SONGS;


DECLARE
  search_result SYS_REFCURSOR;
  song_record SONGS%ROWTYPE;
BEGIN
  search_result := SearchSongs('Song37'); -- No need to use TABLE() here

  DBMS_OUTPUT.PUT_LINE('Song ID | Song Name |');
  DBMS_OUTPUT.PUT_LINE('-------------------------------------');
  LOOP
    FETCH search_result INTO song_record;
    EXIT WHEN search_result%NOTFOUND;

    DBMS_OUTPUT.PUT_LINE(song_record.SONG_ID || ' | ' || song_record.SONG_NAME || ' | ');
  END LOOP;

  CLOSE search_result;
END;

select * from  SONGS;
select * from  USERS;
/



/

