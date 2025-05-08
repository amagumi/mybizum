USE PP_DDBB;
GO

--
EXEC sp_user_register 
    @USERNAME = '',
    @NAME = '',
    @LASTNAME = 'ff',
    @PASSWORD = 'Contraseña#123',
    @EMAIL = 'rr@example.com'

SELECT * FROM USERS;

--
EXEC sp_user_accountvalidate
    @USERNAME = '',
    @REGISTER_CODE = 444;

--
EXEC sp_user_login
    @USERNAME = '',
    @PASSWORD = 'Contraseña#123'

--
SELECT * FROM USER_CONNECTIONS;
EXEC sp_user_logout
    @USERNAME = 'ee';
    
SELECT * FROM USERS;

--
SELECT * FROM USERS
EXEC sp_user_change_password
    @USERNAME = '', 
    @CURRENT_PASSWORD = 'Contraseña#123', 
    @NEW_PASSWORD = 'Contraseña*123'
SELECT * FROM USERS;
SELECT * FROM PWD_HISTORY;
DELETE FROM PWD_HISTORY;

--
EXEC sp_user_get_accountdata 
    @USERNAME = ''

---
EXEC sp_list_connections;


EXEC sp_get_registercode @USERNAME="",@REGISTER_CODE=0