-- PROCEDURE FOR EXPORT TO JSON
--/
CREATE OR REPLACE DIRECTORY UTL_DIR AS '/home/oracle/JSON';
--/
--/
GRANT READ, WRITE ON DIRECTORY UTL_DIR TO public;
--/

CREATE OR REPLACE PROCEDURE EXPORT_JSON
IS
  v_file UTL_FILE.FILE_TYPE;
  v_cursor SYS_REFCURSOR;
  v_row SONGS%ROWTYPE;
  v_json CLOB;
BEGIN
  v_file := UTL_FILE.FOPEN('UTL_DIR', 'JSON_ALLEGRO.json', 'W', 32767); -- Increase buffer size
  OPEN v_cursor FOR SELECT * FROM SONGS;
  v_json := '[';

LOOP
  FETCH v_cursor INTO v_row;
  EXIT WHEN v_cursor%NOTFOUND;

  IF v_json != '[' THEN
    v_json := v_json || ',';
  END IF;

  v_json := v_json || '{';
  v_json := v_json || '"SONG_ID":' || v_row.SONG_ID || ',';

  -- Debug information
  DBMS_OUTPUT.PUT_LINE('GENRE_ID: ' || v_row.GENRE_ID);
  DBMS_OUTPUT.PUT_LINE('LISTENING_COUNTER: ' || v_row.LISTENING_COUNTER);
  DBMS_OUTPUT.PUT_LINE('AUTHOR_ID: ' || v_row.AUTHOR_ID);

  v_json := v_json || '"GENRE_ID":' || NVL(TO_CHAR(v_row.GENRE_ID), 'NULL') || ',';
  v_json := v_json || '"SONG":"' || COALESCE(REPLACE(v_row.SONG, '"', '\"'), 'NULL') || '",';
  v_json := v_json || '"SONG_COVER":"' || COALESCE(REPLACE(v_row.SONG_COVER, '"', '\"'), 'NULL') || '",';
  v_json := v_json || '"SONG_NAME":"' || COALESCE(REPLACE(v_row.SONG_NAME, '"', '\"'), 'NULL') || '",';
  v_json := v_json || '"LISTENING_COUNTER":' || NVL(TO_CHAR(v_row.LISTENING_COUNTER), 'NULL') || ',';
  v_json := v_json || '"AUTHOR_ID":' || NVL(TO_CHAR(v_row.AUTHOR_ID), 'NULL') || '';
  v_json := v_json || '}';
END LOOP;


  CLOSE v_cursor;
  v_json := v_json || ']';
  UTL_FILE.PUT_LINE(v_file, v_json);
  UTL_FILE.FCLOSE(v_file);

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
    RAISE;
END;


--/
CREATE OR REPLACE PROCEDURE IMPORT_JSON IS
    TYPE rec_tab_type IS TABLE OF SONGS%ROWTYPE;
    rec_tab rec_tab_type;
BEGIN
    SELECT SONG_ID, GENRE_ID, SONG, SONG_COVER, SONG_NAME, LISTENING_COUNTER, AUTHOR_ID
    BULK COLLECT INTO rec_tab
    FROM JSON_TABLE(
        BFILENAME('UTL_DIR', 'JSON_ALLEGRO.json'),
        '$[*]' COLUMNS (
            SONG_ID NUMBER PATH '$.SONG_ID',
            GENRE_ID NUMBER PATH '$.GENRE_ID',
            SONG VARCHAR2(200) PATH '$.SONG',
            SONG_COVER VARCHAR2(200) PATH '$.SONG_COVER',
            SONG_NAME VARCHAR2(50) PATH '$.SONG_NAME',
            LISTENING_COUNTER NUMBER PATH '$.LISTENING_COUNTER',
            AUTHOR_ID NUMBER PATH '$.AUTHOR_ID'
        )
    );
    -- Bulk insert using FORALL
    FORALL i IN 1..rec_tab.COUNT
        INSERT INTO SONGS (SONG_ID, GENRE_ID, SONG, SONG_COVER, SONG_NAME, LISTENING_COUNTER, AUTHOR_ID)
        VALUES (rec_tab(i).SONG_ID, rec_tab(i).GENRE_ID, rec_tab(i).SONG, rec_tab(i).SONG_COVER, rec_tab(i).SONG_NAME, rec_tab(i).LISTENING_COUNTER, rec_tab(i).AUTHOR_ID);
    COMMIT;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        FOR i IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE('Skipping duplicate record with SONG_ID ' || rec_tab(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX).SONG_ID);
        END LOOP;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
        RAISE;
END;

GRANT EXECUTE ON EXPORT_JSON TO MYADMIN;
begin
    EXPORT_JSON;
end;

begin
    IMPORT_JSON;
end;
begin
    DELETE_ALL_SONG();
end;

SELECT * FROM SONGS;
INSERT INTO SONGS (GENRE_ID, SONG, SONG_COVER, SONG_NAME, LISTENING_COUNTER, AUTHOR_ID) VALUES (1, 'DD', 'DD', 'D', 0, 1);
INSERT INTO SONGS (GENRE_ID, SONG, SONG_COVER, SONG_NAME, LISTENING_COUNTER, AUTHOR_ID) VALUES (2, 'D:\\УНИК\\Семестр 5\\урсач\\TestSearch\\public\\audio\\Gloryhammer - The Land of Unicorns-1.mp3', 'd', 'Song2', 0, 2);
commit ;


DELETE FROM LISTENING_HISTORY WHERE SONG_ID = 2;
DELETE FROM Playlist_Song WHERE SONG_ID = 2;
-- ... выполнить подобные команды для других таблиц

-- Теперь можешь удалить запись из таблицы SONGS
DELETE FROM SONGS WHERE SONG_ID = 22;
DELETE FROM SONGS WHERE SONG_ID = 21;
DELETE FROM SONGS WHERE SONG_ID = 2;



SELECT * FROM all_directories WHERE directory_name = 'UTL_DIR';

--/

--find / -name JSON_ALLEGRO.json 2>/dev/null