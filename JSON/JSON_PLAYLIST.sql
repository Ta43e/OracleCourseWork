CREATE OR REPLACE DIRECTORY UTL_DIR AS '/home/oracle/JSON';
--/
--/
GRANT READ, WRITE ON DIRECTORY UTL_DIR TO public;


CREATE TABLE PLAYLIST (
    PLAYLIST_ID INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    PLAYLIST_NAME VARCHAR2(50) NOT NULL,
    PLAYLIST_COVER VARCHAR2(50) NOT NULL,
    USER_ID INT NOT NULL,
    FOREIGN KEY (USER_ID) REFERENCES USERS(USER_ID) ON DELETE CASCADE
);

CREATE OR REPLACE PROCEDURE EXPORT_JSON_PLAYLIST
IS
  v_file UTL_FILE.FILE_TYPE;
  v_cursor SYS_REFCURSOR;
  v_row PLAYLIST%ROWTYPE;
  v_json CLOB;
BEGIN
  v_file := UTL_FILE.FOPEN('UTL_DIR', 'JSON_PLAYLIST.json', 'W', 32767); -- Increase buffer size
  OPEN v_cursor FOR SELECT * FROM PLAYLIST;
  v_json := '[';

  LOOP
    FETCH v_cursor INTO v_row;
    EXIT WHEN v_cursor%NOTFOUND;

    IF v_json != '[' THEN
      v_json := v_json || ',';
    END IF;

    v_json := v_json || '{';
    v_json := v_json || '"PLAYLIST_ID":' || v_row.PLAYLIST_ID || ',';
    v_json := v_json || '"PLAYLIST_NAME":"' || COALESCE(REPLACE(v_row.PLAYLIST_NAME, '"', '\"'), 'NULL') || '",';
    v_json := v_json || '"PLAYLIST_COVER":"' || COALESCE(REPLACE(v_row.PLAYLIST_COVER, '"', '\"'), 'NULL') || '",';
    v_json := v_json || '"USER_ID":' || NVL(TO_CHAR(v_row.USER_ID), 'NULL') || '';
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

CREATE OR REPLACE PROCEDURE IMPORT_JSON_PLAYLIST
IS
    TYPE rec_tab_type IS TABLE OF PLAYLIST%ROWTYPE;
    rec_tab rec_tab_type;
    v_user_exists NUMBER;
BEGIN
    SELECT PLAYLIST_ID, PLAYLIST_NAME, PLAYLIST_COVER, USER_ID
    BULK COLLECT INTO rec_tab
    FROM JSON_TABLE(
        BFILENAME('UTL_DIR', 'JSON_PLAYLIST.json'),
        '$[*]' COLUMNS (
            PLAYLIST_ID NUMBER PATH '$.PLAYLIST_ID',
            PLAYLIST_NAME VARCHAR2(50) PATH '$.PLAYLIST_NAME',
            PLAYLIST_COVER VARCHAR2(50) PATH '$.PLAYLIST_COVER',
            USER_ID NUMBER PATH '$.USER_ID'
        )
    );

    -- Loop through the records
    FOR i IN 1..rec_tab.COUNT
    LOOP
        -- Check if the user exists
        SELECT COUNT(*) INTO v_user_exists FROM USERS WHERE USER_ID = rec_tab(i).USER_ID;

        IF v_user_exists > 0 THEN
            -- Insert playlist only if the user exists
            BEGIN
                INSERT INTO PLAYLIST (PLAYLIST_ID, PLAYLIST_NAME, PLAYLIST_COVER, USER_ID)
                VALUES (rec_tab(i).PLAYLIST_ID, rec_tab(i).PLAYLIST_NAME, rec_tab(i).PLAYLIST_COVER, rec_tab(i).USER_ID);
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                    DBMS_OUTPUT.PUT_LINE('Skipping duplicate record with PLAYLIST_ID ' || rec_tab(i).PLAYLIST_ID);
            END;
        ELSE
            DBMS_OUTPUT.PUT_LINE('Skipping playlist with PLAYLIST_ID ' || rec_tab(i).PLAYLIST_ID || ' because the corresponding user does not exist.');
        END IF;
    END LOOP;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLCODE || ' - ' || SQLERRM);
        RAISE;
END;


--========================== Тест работы JSON =======================--
begin
    EXPORT_JSON_PLAYLIST;
end;

select * from PLAYLIST;
select * from PLAYLIST_SONG;


begin
    delete_playlist(127);
end;

begin
    DELETE_USER(127);
end;

begin
    IMPORT_JSON_PLAYLIST;
end;


--======================================================================--