CREATE OR REPLACE TRIGGER update_release_date_trigger
AFTER INSERT ON ALBUM_SONG
FOR EACH ROW
DECLARE
BEGIN
  UPDATE ALBUMS
  SET RELEASE_DATE = SYSDATE
  WHERE ALBUM_ID = :NEW.ALBUM_ID;
END;

drop trigger update_release_date_trigger;


Create unique index fastSearch
On USERS(USER_NAME);


Create unique index fastSearchSong
On SONGS(SONG_NAME);

drop index fastSearchSong;
