-- DROP TABLE ALBUM_USER -1
--/
DECLARE
    table_exists INTEGER;
BEGIN
    -- Поместите оператор SELECT INTO в блок BEGIN...END
    BEGIN
        SELECT count(*) INTO table_exists
        FROM dba_tables WHERE table_name = 'ALBUM_USER';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            table_exists := 0;
    END;

    IF table_exists <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE ALBUM_USER';
    END IF;
END;

--/

-- DROP TABLE SONG_USER -2
--/
DECLARE
    table_exists INTEGER;
BEGIN
	SELECT count(*) INTO table_exists
    FROM dba_tables WHERE table_name = 'SONG_USER';

    IF (table_exists) <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE SONG_USER';
    END IF;
END;
--/
-- DROP TABLE PLAYLIST_SONG -3
--/
DECLARE
    table_exists INTEGER;
BEGIN
	SELECT count(*) INTO table_exists
    FROM dba_tables WHERE table_name = 'PLAYLIST_SONG';

    IF (table_exists) <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE PLAYLIST_SONG';
    END IF;
END;
--/

-- DROP TABLE LISTENINGHISTORY -4
--/
DECLARE
    table_exists INTEGER;
BEGIN
	SELECT count(*) INTO table_exists
    FROM dba_tables WHERE table_name = 'LISTENINGHISTORY';

    IF (table_exists) <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE LISTENINGHISTORY';
    END IF;
END;
--/
-- DROP TABLE  Album_Song -5
--/
DECLARE
    table_exists INTEGER;
BEGIN
	SELECT count(*) INTO table_exists
    FROM dba_tables WHERE table_name = 'Album_Song';

    IF (table_exists) <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE Album_Song';
    END IF;
END;
--/
-- DROP TABLE  GENRES -6
--/
DECLARE
    table_exists INTEGER;
BEGIN
	SELECT count(*) INTO table_exists
    FROM dba_tables WHERE table_name = 'GENRES';

    IF (table_exists) <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE GENRES';
    END IF;
END;
--/
-- DROP TABLE  SONGS -7
--/
DECLARE
    table_exists INTEGER;
BEGIN
	SELECT count(*) INTO table_exists
    FROM dba_tables WHERE table_name = 'SONGS';

    IF (table_exists) <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE SONGS';
    END IF;
END;
--/
-- DROP TABLE  PLAYLIST -7
--/
DECLARE
    table_exists INTEGER;
BEGIN
	SELECT count(*) INTO table_exists
    FROM dba_tables WHERE table_name = 'PLAYLIST';

    IF (table_exists) <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE PLAYLIST';
    END IF;
END;
--/
-- DROP TABLE  USERS -8
--/
DECLARE
    table_exists INTEGER;
BEGIN
	SELECT count(*) INTO table_exists
    FROM dba_tables WHERE table_name = 'USERS';

    IF (table_exists) <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE USERS';
    END IF;
END;
--/
-- DROP TABLE  PLAYLIST -9
--/
DECLARE
    table_exists INTEGER;
BEGIN
	SELECT count(*) INTO table_exists
    FROM dba_tables WHERE table_name = 'PLAYLIST';

    IF (table_exists) <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE PLAYLIST';
    END IF;
END;
--/
-- DROP TABLE  ALBUMS -10
--/
DECLARE
    table_exists INTEGER;
BEGIN
	SELECT count(*) INTO table_exists
    FROM dba_tables WHERE table_name = 'ALBUMS';

    IF (table_exists) <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE ALBUMS';
    END IF;
END;
--/
-- DROP TABLE  ROLES -11
--/
DECLARE
    table_exists INTEGER;
BEGIN
	SELECT count(*) INTO table_exists
    FROM dba_tables WHERE table_name = 'ROLES';

    IF (table_exists) <> 0 THEN
        EXECUTE IMMEDIATE 'DROP TABLE ROLES';
    END IF;
END;
--/