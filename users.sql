-- HEAD ADMIN
CREATE TABLESPACE Alegro_PDB
DATAFILE 'ALEGRO_PDB.dbf'
SIZE 100M
AUTOEXTEND ON NEXT 5M
BLOCKSIZE 8192
EXTENT MANAGEMENT LOCAL;

CREATE TEMPORARY TABLESPACE  TS_Alegro_TEMP
TEMPFILE 'TS_Alegro_TEMP.dbf'
SIZE 100M
AUTOEXTEND ON NEXT 5M
BLOCKSIZE 8192
EXTENT MANAGEMENT LOCAL;

CREATE PROFILE MAIN_ADMIN_PROFILE LIMIT
    PASSWORD_LIFE_TIME 120
    SESSIONS_PER_USER 15
    FAILED_LOGIN_ATTEMPTS 10
    PASSWORD_LOCK_TIME 1
    PASSWORD_REUSE_TIME 10
    PASSWORD_GRACE_TIME DEFAULT
    CONNECT_TIME 180
    IDLE_TIME 30;

ALTER USER MYADMIN PROFILE MAIN_ADMIN_PROFILE;
ALTER USER MYADMIN DEFAULT TABLESPACE Alegro_PDB QUOTA UNLIMITED ON Alegro_PDB;
ALTER USER MYADMIN TEMPORARY TABLESPACE TS_Alegro_TEMP;


-- Пользовательский профиль

CREATE PROFILE USERS_PROFILE LIMIT
    PASSWORD_LIFE_TIME 180
    SESSIONS_PER_USER 20
    FAILED_LOGIN_ATTEMPTS 3
    PASSWORD_LOCK_TIME 3
    PASSWORD_REUSE_TIME 10
    CONNECT_TIME 180
    IDLE_TIME 60;

-- Роль - базовый доступ к представлениям
CREATE ROLE BASE_ROLE;

GRANT EXECUTE ON MYADMIN.SONG_MANAGEMENT_PACKAGE TO BASE_ROLE;
GRANT EXECUTE ON MYADMIN.PLAYLIST_MANAGEMENT_PACKAGE TO BASE_ROLE;
GRANT EXECUTE ON MYADMIN.USER_ALBUM_PACKAGE TO BASE_ROLE;
GRANT EXECUTE ON MYADMIN.SearchSongs TO BASE_ROLE;
GRANT EXECUTE ON MYADMIN.create_user TO BASE_ROLE;
GRANT EXECUTE ON MYADMIN.DELETE_USER TO BASE_ROLE;
GRANT EXECUTE ON MYADMIN.update_user TO BASE_ROLE;
GRANT EXECUTE ON MYADMIN.ADD_LISTENING_HISTORY TO BASE_ROLE;
GRANT EXECUTE ON MYADMIN.AUTHENTICATE_USER TO BASE_ROLE;
GRANT EXECUTE ON MYADMIN.GET_USER_ID_BY_NAME TO BASE_ROLE;
GRANT EXECUTE ON MYADMIN.GET_USER_BY_NAME TO BASE_ROLE;
GRANT EXECUTE ON MYADMIN.GET_MUSIC TO BASE_ROLE;
GRANT EXECUTE ON MYADMIN.get_all_albums TO BASE_ROLE;
GRANT EXECUTE ON MYADMIN.GET_USER_INFO_BY_ID TO BASE_ROLE;
GRANT EXECUTE ON MYADMIN.GET_USER_INFO_BY_NAME TO BASE_ROLE;
GRANT EXECUTE ON MYADMIN.GET_SONG_INFO_BY_NAME TO BASE_ROLE;

COMMIT ;
-- Роль - ПОЛЬЗОВАТЕЛЯ

CREATE USER BASE_USER
    IDENTIFIED BY 123456
    PROFILE USERS_PROFILE;

GRANT CREATE SESSION TO BASE_USER;
GRANT BASE_ROLE TO BASE_USER;
COMMIT ;
-- Роль - АВТОР
CREATE ROLE SONGWRITER_ROLE;
GRANT CREATE SESSION TO SONGWRITER_ROLE;
GRANT EXECUTE ON MYADMIN.SONG_MANAGEMENT_PACKAGE TO SONGWRITER_ROLE;
GRANT EXECUTE ON MYADMIN.PLAYLIST_MANAGEMENT_PACKAGE TO SONGWRITER_ROLE;
GRANT EXECUTE ON MYADMIN.USER_ALBUM_PACKAGE TO SONGWRITER_ROLE;
GRANT EXECUTE ON MYADMIN.SONGWRITER_ALBUM_PACKAGE TO SONGWRITER_ROLE;
GRANT EXECUTE ON MYADMIN.SearchSongs TO SONGWRITER_ROLE;
GRANT EXECUTE ON MYADMIN.create_user TO SONGWRITER_ROLE;
GRANT EXECUTE ON MYADMIN.DELETE_USER TO SONGWRITER_ROLE;
GRANT EXECUTE ON MYADMIN.UPDATE_ALBUM TO SONGWRITER_ROLE;
GRANT EXECUTE ON MYADMIN.ADD_LISTENING_HISTORY TO SONGWRITER_ROLE;
GRANT EXECUTE ON MYADMIN.AUTHENTICATE_USER TO SONGWRITER_ROLE;
GRANT EXECUTE ON MYADMIN.GET_USER_ID_BY_NAME TO SONGWRITER_ROLE;
GRANT EXECUTE ON MYADMIN.GET_USER_BY_NAME TO BASE_ROLE;
GRANT EXECUTE ON MYADMIN.GET_MUSIC TO SONGWRITER_ROLE;
GRANT EXECUTE ON MYADMIN.get_all_albums TO SONGWRITER_ROLE;
GRANT EXECUTE ON MYADMIN.update_user TO SONGWRITER_ROLE;
GRANT EXECUTE ON MYADMIN.GET_USER_INFO_BY_ID TO SONGWRITER_ROLE;
GRANT EXECUTE ON MYADMIN.ADD_SONG TO SONGWRITER_ROLE;
GRANT EXECUTE ON MYADMIN.GET_USER_INFO_BY_NAME TO SONGWRITER_ROLE;
GRANT EXECUTE ON MYADMIN.GET_SONG_INFO_BY_NAME TO SONGWRITER_ROLE;
COMMIT ;
CREATE USER SONG_WRITER
    IDENTIFIED BY 123456
    PROFILE USERS_PROFILE;

GRANT SONGWRITER_ROLE TO SONG_WRITER;
COMMIT ;

SELECT * FROM all_objects WHERE object_name = 'DBMS_CRYPTO';
GRANT EXECUTE ON SYS.DBMS_CRYPTO TO MYADMIN;


