alter session set "_ORACLE_SCRIPT" = true;
/*
alter pluggable database AllegroPDB open;
connect myadmin/12345@//0.0.0.0:1521/AllegroPDB.localdomain;
Oracle_db1*/


SELECT  * FROM  ALBUMS;



BEGIN
    USERS_tapi.create_user('user', 'oLEG', 'dr.oleg-kozak2019@yandex.by', 123);
    END;