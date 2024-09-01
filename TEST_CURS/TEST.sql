BEGIN
    CREATE_USER('USER', 'OLEG', 'Ta4e', '123456');
end;

DECLARE
    user_result SYS_REFCURSOR;
    user_id USERS.USER_ID%TYPE;
    user_login USERS.USER_LOGIN%TYPE;
    user_role USERS.USER_ROLE%TYPE;
    user_name USERS.USER_NAME%TYPE;
    user_pass USERS.USER_PASS%TYPE;
BEGIN
    user_result := AUTHENTICATE_USER('123', '123');

    LOOP
        FETCH user_result INTO user_id, user_role, user_name, user_login, user_pass;
        EXIT WHEN user_result%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('User ID: ' || user_id || ', User Role: ' || user_role || ', User Name: ' || user_name || ', User Login: ' || user_login || ', User Pass: ' || user_pass);
    END LOOP;

    CLOSE user_result;
END;
/

/


begin
    DELETE_SONG_BY_ID(305000);
end;


select * from USERS;