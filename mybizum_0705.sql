USE [master]
GO
/****** Object:  Database [PP_DDBB]    Script Date: 07/05/2025 18:23:16 ******/
CREATE DATABASE [PP_DDBB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'PP_DDBB', FILENAME = N'/var/opt/mssql/data/PP_DDBB.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'PP_DDBB_log', FILENAME = N'/var/opt/mssql/data/PP_DDBB_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [PP_DDBB] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [PP_DDBB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [PP_DDBB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [PP_DDBB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [PP_DDBB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [PP_DDBB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [PP_DDBB] SET ARITHABORT OFF 
GO
ALTER DATABASE [PP_DDBB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [PP_DDBB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [PP_DDBB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [PP_DDBB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [PP_DDBB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [PP_DDBB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [PP_DDBB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [PP_DDBB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [PP_DDBB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [PP_DDBB] SET  ENABLE_BROKER 
GO
ALTER DATABASE [PP_DDBB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [PP_DDBB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [PP_DDBB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [PP_DDBB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [PP_DDBB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [PP_DDBB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [PP_DDBB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [PP_DDBB] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [PP_DDBB] SET  MULTI_USER 
GO
ALTER DATABASE [PP_DDBB] SET PAGE_VERIFY NONE  
GO
ALTER DATABASE [PP_DDBB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [PP_DDBB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [PP_DDBB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [PP_DDBB] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [PP_DDBB] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'PP_DDBB', N'ON'
GO
ALTER DATABASE [PP_DDBB] SET QUERY_STORE = OFF
GO
USE [PP_DDBB]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_compare_passwords]    Script Date: 07/05/2025 18:23:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [dbo].[fn_compare_passwords]
(
    @NEW_PASSWORD NVARCHAR(50),
    @USERNAME NVARCHAR(50)
)
RETURNS INT
AS
BEGIN
    DECLARE @pwd NVARCHAR(50);

    IF EXISTS (SELECT 1 FROM USERS WHERE USERNAME = @USERNAME)
    BEGIN
        SELECT @pwd = PASSWORD
        FROM USERS
        WHERE USERNAME = @USERNAME;

        -- Usando CASE para la comparación
        RETURN (
            SELECT CASE
                WHEN @NEW_PASSWORD IS NOT NULL AND @NEW_PASSWORD = @pwd THEN 1
                ELSE 0
            END
        );
    END
    ELSE
    BEGIN
        RETURN 0; -- El usuario no existe, así que asumimos que la contraseña no es igual
    END

    -- Este return es redundante, pero se deja como salvaguarda
    RETURN -1;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_compare_soundex]    Script Date: 07/05/2025 18:23:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [dbo].[fn_compare_soundex] (
    @USERNAME NVARCHAR(25),
    @NEW_PASSWORD NVARCHAR(50)
)
RETURNS BIT
AS
BEGIN
    DECLARE @USER_ID INT;
    DECLARE @RESULT BIT = 1; -- 1 significa que no suena igual a las 3 últimas contraseñas
    
    -- Obtener el ID del usuario
    SELECT @USER_ID = ID
    FROM USERS
    WHERE USERNAME = @USERNAME;

    -- Si el usuario no existe, retornar 1
    IF @USER_ID IS NULL
    BEGIN
        RETURN @RESULT;
    END

    -- Verificar las últimas 3 contraseñas
    IF EXISTS (
        SELECT 1
        FROM (
            SELECT TOP 3 OLD_PASSWORD
            FROM PWD_HISTORY
            WHERE USER_ID = @USER_ID
            ORDER BY DATE_CHANGED DESC
        ) AS LastPasswords
        WHERE SOUNDEX(OLD_PASSWORD) = SOUNDEX(@NEW_PASSWORD)
    )
    BEGIN
        SET @RESULT = 0; -- 0 significa que suena igual a una de las 3 últimas contraseñas
    END

    RETURN @RESULT;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_generate_ssid]    Script Date: 07/05/2025 18:23:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [dbo].[fn_generate_ssid]()
returns UNIQUEIDENTIFIER
AS
BEGIN
    declare @ssid UNIQUEIDENTIFIER;

    set @ssid = (select guid from v_guid)

    return @ssid
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_mail_exists]    Script Date: 07/05/2025 18:23:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_mail_exists] (@EMAIL NVARCHAR(100))
RETURNS BIT
AS
BEGIN
    DECLARE @Exists BIT;
    SET @Exists = (
        SELECT CASE WHEN EXISTS (SELECT 1 FROM USERS WHERE EMAIL = @EMAIL) THEN 1 ELSE 0 END
    );
    RETURN @Exists;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_mail_isvalid]    Script Date: 07/05/2025 18:23:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [dbo].[fn_mail_isvalid] (@EMAIL NVARCHAR(100))
RETURNS BIT
AS
BEGIN
    DECLARE @ValidEmail BIT = 0;
    DECLARE @AtPosition INT, @DotPosition INT;

    -- Verificar si el correo electrónico contiene '@' y al menos un caracter antes y después
    SET @AtPosition = CHARINDEX('@', @EMAIL);
    IF (@AtPosition > 1 AND @AtPosition < LEN(@EMAIL))
    BEGIN
        -- Verificar si el correo electrónico contiene un punto después de '@' y al menos un caracter después del punto
        SET @DotPosition = CHARINDEX('.', @EMAIL, @AtPosition);
        IF (@DotPosition > (@AtPosition + 1) AND @DotPosition < LEN(@EMAIL))
        BEGIN
            SET @ValidEmail = 1;
        END;
    END;

    RETURN @ValidEmail;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_pwd_checkpolicy]    Script Date: 07/05/2025 18:23:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Función para verificar la política de contraseñas
CREATE   FUNCTION [dbo].[fn_pwd_checkpolicy](@PASSWORD NVARCHAR(100))
RETURNS INT
AS
BEGIN
    DECLARE @errorPass BIT;
    SET @errorPass = 1;

    IF len(@PASSWORD) < 10
    BEGIN
        SET @errorPass = 0;
    END

    -- Verifica la existencia de un número en la contraseña
    ELSE IF PATINDEX('%[0-9]%', @PASSWORD) = 0
    BEGIN
        SET @errorPass = 0;
    END

    -- Verifica la existencia de una letra en la contraseña
    ELSE IF PATINDEX('%[a-zA-Z]%', @PASSWORD) = 0
    BEGIN
        SET @errorPass = 0;
    END
    -- Verifica la existencia de un carácter especial en la contraseña
    ELSE IF PATINDEX('%[^a-zA-Z0-9]%', @PASSWORD) = 0
    BEGIN
        SET @errorPass = 0;
    END

    RETURN @errorPass;
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_pwd_isvalid]    Script Date: 07/05/2025 18:23:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Función para verificar la contraseña del usuario
CREATE   FUNCTION [dbo].[fn_pwd_isvalid]
(
    @PASSWORD NVARCHAR(50),
    @USERNAME NVARCHAR(25)
)
RETURNS BIT
AS
BEGIN
    DECLARE @IsValid BIT;

    -- Verificar si la contraseña proporcionada coincide con la almacenada en la base de datos
    SET @IsValid = (
        SELECT CASE WHEN EXISTS (SELECT 1 FROM USERS WHERE USERNAME = @USERNAME AND PASSWORD = @PASSWORD) THEN 1 ELSE 0 END
    );

    RETURN @IsValid;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_user_exists]    Script Date: 07/05/2025 18:23:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_user_exists] (@USERNAME NVARCHAR(25))
RETURNS BIT
AS
BEGIN
    DECLARE @Exists BIT;
    SET @Exists = (
        SELECT CASE WHEN EXISTS (SELECT 1 FROM USERS WHERE USERNAME = @USERNAME) THEN 1 ELSE 0 END
    );
    RETURN @Exists;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_user_state]    Script Date: 07/05/2025 18:23:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [dbo].[fn_user_state] 
(
    @USERNAME NVARCHAR(25)
)
RETURNS INT
AS
BEGIN
    DECLARE @userState INT;

    SELECT @userState = CASE WHEN u.STATUS = 1 THEN 1 ELSE 0 END
    FROM USERS u
    WHERE u.USERNAME = @USERNAME;

    RETURN @userState;
END;
GO
/****** Object:  View [dbo].[v_guid]    Script Date: 07/05/2025 18:23:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[v_guid] 
AS
    select newid() guid
GO
/****** Object:  Table [dbo].[PWD_HISTORY]    Script Date: 07/05/2025 18:23:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PWD_HISTORY](
	[HISTORY_ID] [int] IDENTITY(1,1) NOT NULL,
	[USER_ID] [int] NULL,
	[USERNAME] [nvarchar](25) NULL,
	[OLD_PASSWORD] [nvarchar](50) NULL,
	[DATE_CHANGED] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[HISTORY_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[STATUS]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[STATUS](
	[STATUS] [int] NOT NULL,
	[DESCRIPTION] [varchar](25) NULL,
PRIMARY KEY CLUSTERED 
(
	[STATUS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[USER_CONNECTIONS]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[USER_CONNECTIONS](
	[CONNECTION_ID] [uniqueidentifier] NOT NULL,
	[USER_ID] [int] NULL,
	[USERNAME] [nvarchar](25) NULL,
	[DATE_CONNECTED] [datetime] NULL,
	[DATE_DISCONNECTED] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[CONNECTION_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[USER_CONNECTIONS_HISTORY]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[USER_CONNECTIONS_HISTORY](
	[HISTORY_ID] [int] IDENTITY(1,1) NOT NULL,
	[USER_ID] [int] NULL,
	[USERNAME] [nvarchar](30) NULL,
	[DATE_CONNECTED] [datetime] NULL,
	[DATE_DISCONNECTED] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[HISTORY_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[USER_ERRORS]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[USER_ERRORS](
	[ERROR_ID] [int] IDENTITY(0,1) NOT NULL,
	[ERROR_CODE] [int] NOT NULL,
	[ERROR_MESSAGE] [nvarchar](max) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ERROR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[USERS]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[USERS](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[USERNAME] [nvarchar](25) NULL,
	[NAME] [nvarchar](25) NULL,
	[LASTNAME] [nvarchar](50) NULL,
	[PASSWORD] [nvarchar](50) NULL,
	[EMAIL] [nvarchar](100) NULL,
	[STATUS] [int] NULL,
	[GENDER] [bit] NULL,
	[DEF_LANG] [nvarchar](3) NULL,
	[TIMESTAMP] [datetime] NULL,
	[REGISTER_CODE] [int] NULL,
	[LOGIN_STATUS] [bit] NULL,
	[ROL_USER] [bit] NULL,
	[BALANCE] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[USERNAME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PWD_HISTORY] ADD  DEFAULT (CONVERT([datetime],switchoffset(sysdatetimeoffset(),'+02:00'))) FOR [DATE_CHANGED]
GO
ALTER TABLE [dbo].[USER_CONNECTIONS] ADD  DEFAULT (CONVERT([datetime],switchoffset(sysdatetimeoffset(),'+02:00'))) FOR [DATE_CONNECTED]
GO
ALTER TABLE [dbo].[USER_CONNECTIONS_HISTORY] ADD  DEFAULT (CONVERT([datetime],switchoffset(sysdatetimeoffset(),'+02:00'))) FOR [DATE_CONNECTED]
GO
ALTER TABLE [dbo].[USER_CONNECTIONS_HISTORY] ADD  DEFAULT (CONVERT([datetime],switchoffset(sysdatetimeoffset(),'+02:00'))) FOR [DATE_DISCONNECTED]
GO
ALTER TABLE [dbo].[USERS] ADD  DEFAULT (CONVERT([datetime],switchoffset(sysdatetimeoffset(),'+02:00'))) FOR [TIMESTAMP]
GO
ALTER TABLE [dbo].[PWD_HISTORY]  WITH CHECK ADD FOREIGN KEY([USER_ID])
REFERENCES [dbo].[USERS] ([ID])
GO
ALTER TABLE [dbo].[USER_CONNECTIONS]  WITH CHECK ADD FOREIGN KEY([USER_ID])
REFERENCES [dbo].[USERS] ([ID])
GO
ALTER TABLE [dbo].[USER_CONNECTIONS_HISTORY]  WITH CHECK ADD FOREIGN KEY([USER_ID])
REFERENCES [dbo].[USERS] ([ID])
GO
ALTER TABLE [dbo].[USERS]  WITH CHECK ADD FOREIGN KEY([STATUS])
REFERENCES [dbo].[STATUS] ([STATUS])
GO
/****** Object:  StoredProcedure [dbo].[sp_list_connections]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_list_connections]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ret INT;
    SET @ret = -1;

    DECLARE @XMLFlag XML;

    IF EXISTS (
        SELECT 1 FROM USER_CONNECTIONS -- Verifica la tabla correcta
    )
    BEGIN
        SET @XMLFlag = (
            SELECT * FROM USER_CONNECTIONS
            FOR XML PATH('Connection'), ROOT('Connections'), TYPE
        );
        SET @ret = 0;
    END
    ELSE
    BEGIN
        UPDATE USERS SET LOGIN_STATUS = 0;
        SET @ret = 504;
    END

    IF @ret <> 0
    BEGIN
        ExitProc:
        DECLARE @ResponseXML XML;
        EXEC sp_xml_error_message @RETURN = @ret, @XmlResponse = @ResponseXML OUTPUT;
        SELECT @ResponseXML;
    END
    ELSE
        SELECT @XMLFlag;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_list_errors]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_list_errors]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ret INT;
    SET @ret = -1;

    DECLARE @XMLFlag XML;

    -- Verificar si hay errores
    IF EXISTS (SELECT 1 FROM USER_ERRORS)
    BEGIN
        -- Si hay errores, convertir el conjunto de resultados a XML
        SET @XMLFlag = (
            SELECT * FROM USER_ERRORS
            FOR XML PATH('Errors'), ROOT('Errors'), TYPE
        );
        SET @ret = 0; -- Indicar que hubo resultados
    END
    ELSE
    BEGIN
        SET @ret = 508;
    END

    IF @ret <> 0
    BEGIN
        ExitProc:
        DECLARE @ResponseXML XML;
        EXEC sp_xml_error_message @RETURN = @ret, @XmlResponse = @ResponseXML OUTPUT;
        SELECT @ResponseXML;
    END
    ELSE
        SELECT @XMLFlag;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_list_historic_connections]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_list_historic_connections]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ret INT;
    SET @ret = -1;

    DECLARE @XMLFlag XML;

    -- Verificar si hay datos en el historial de conexiones
    IF EXISTS (SELECT 1 FROM USER_CONNECTIONS_HISTORY)
    BEGIN
        -- Si hay datos, convertir el conjunto de resultados a XML
        SET @XMLFlag = (
            SELECT HISTORY_ID,USERNAME,DATE_CONNECTED,DATE_DISCONNECTED FROM USER_CONNECTIONS_HISTORY
            FOR XML PATH('HistoricConnections'), ROOT('HistoricConnections'), TYPE
        );
        SET @ret = 0; -- Indicar que hubo resultados
    END
    ELSE
    BEGIN
        SET @ret = 505; -- Indicar que hubo resultados
    END
    
    IF @ret <> 0
    BEGIN
        ExitProc:
        DECLARE @ResponseXML XML;
        EXEC sp_xml_error_message @RETURN = @ret, @XmlResponse = @ResponseXML OUTPUT;
        SELECT @ResponseXML;
    END
    ELSE
        SELECT @XMLFlag;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_list_historic_user_connections]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Procedimiento para listar el historial de conexiones del usuario
CREATE PROCEDURE [dbo].[sp_list_historic_user_connections]
    @USERNAME NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ret INT;
    SET @ret = -1;

    DECLARE @XMLFlag XML;

    --veifica estado usuaio
    -- if -- fallito puesto aposta!!
        -- Verificar si hay conexiones para el usuario
        IF EXISTS (
            SELECT 1 
        )
        BEGIN
            -- Si hay conexiones, convertir el conjunto de resultados a XML
            SET @XMLFlag = (
                SELECT HISTORY_ID,USERNAME,DATE_CONNECTED,DATE_DISCONNECTED FROM USER_CONNECTIONS_HISTORY WHERE USERNAME = @USERNAME
                FOR XML PATH('UserConnection'), ROOT('UsersConnections'), TYPE
            );
            SET @ret = 0; -- Indicar que hubo resultados
        END
        ELSE
        BEGIN
            SET @ret = 507;
        END

    IF @ret <> 0
    BEGIN
        ExitProc:
        DECLARE @ResponseXML XML;
        EXEC sp_xml_error_message @RETURN = @ret, @XmlResponse = @ResponseXML OUTPUT;
        SELECT @ResponseXML;
    END
    ELSE
        SELECT @XMLFlag;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_list_system_status]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_list_system_status]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ret INT;
    SET @ret = -1;

    DECLARE @XMLFlag XML;

    -- Verificar si hay usuarios con estado definido
    IF EXISTS (
        SELECT 1 FROM USERS u
        INNER JOIN STATUS s ON u.STATUS = s.STATUS
    )
    BEGIN
        -- Si hay usuarios con estado, convertir el conjunto de resultados a XML
        SET @XMLFlag = (
            SELECT u.ID AS UserID, u.USERNAME, s.STATUS
            FROM USERS u
            INNER JOIN STATUS s ON u.STATUS = s.STATUS
            FOR XML PATH(''), ROOT('SystemStatus'), TYPE
        );
        SET @ret = 0; -- Indicar que hubo resultados
    END
    ELSE
    BEGIN
        SET @ret = 506;
    END

    IF @ret <> 0
    BEGIN
        ExitProc:
        DECLARE @ResponseXML XML;
        EXEC sp_xml_error_message @RETURN = @ret, @XmlResponse = @ResponseXML OUTPUT;
        SELECT @ResponseXML;
    END
    ELSE
        SELECT @XMLFlag;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_list_users]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Procedimiento almacenado para listar usuarios
CREATE PROCEDURE [dbo].[sp_list_users]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ret INT;
    SET @ret = -1;

    DECLARE @XMLFlag XML;

    -- Verificar si hay datos en el historial de conexiones
    IF EXISTS (SELECT 1 FROM USERS)
    BEGIN
        -- Si hay datos, convertir el conjunto de resultados a XML
        SET @XMLFlag = (
            SELECT USERNAME FROM USERS
            FOR XML PATH('Usuarios'), ROOT('Usuarios'), TYPE
        );
    END
    ELSE
    BEGIN
        SET @ret = 505; -- Indicar que hubo resultados
    END
    
    IF @ret <> -1
    BEGIN
        ExitProc:
        DECLARE @ResponseXML XML;
        EXEC sp_xml_error_message @RETURN = @ret, @XmlResponse = @ResponseXML OUTPUT;
        SELECT @ResponseXML;
    END
    ELSE
        SELECT @XMLFlag;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_list_users2]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Procedimiento almacenado para listar usuarios
CREATE PROCEDURE [dbo].[sp_list_users2]
    @ssid NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ret INT;
    SET @ret = -1;

    DECLARE @XMLFlag XML;

    DECLARE @USERNAME NVARCHAR(250);

    DECLARE @ROL_USER BIT;
    
    SELECT @USERNAME=USERNAME
    FROM USER_CONNECTIONS
    WHERE CAST(CONNECTION_ID AS nvarchar(255))=@ssid ;

    SELECT @ROL_USER = ROL_USER
    FROM USERS
    WHERE USERNAME = @USERNAME;

    IF @ROL_USER = 1
    BEGIN
        -- Verificar si hay datos en el historial de conexiones
        IF EXISTS (SELECT 1 FROM USERS)
        BEGIN
            -- Si hay datos, convertir el conjunto de resultados a XML
            SET @XMLFlag = (
                SELECT USERNAME FROM USERS
                FOR XML PATH('Usuarios'), ROOT('Usuarios'), TYPE
            );
        END
        ELSE
        BEGIN
            SET @ret = 505; -- Indicar que hubo resultados
        END
    END
    ELSE
    BEGIN
        SET @ret = 800;
    END
    
    IF @ret <> -1
    BEGIN
        ExitProc:
        DECLARE @ResponseXML XML;
        EXEC sp_xml_error_message @RETURN = @ret, @XmlResponse = @ResponseXML OUTPUT;
        SELECT @ResponseXML;
    END
    ELSE
        SELECT @XMLFlag;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_user_accountvalidate]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_user_accountvalidate]
    @USERNAME NVARCHAR(25),
    @REGISTER_CODE INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ret INT = -1;
    DECLARE @UserID INT;
    DECLARE @UserStatus INT;
    DECLARE @UserRegisterCode INT;

    -- Verificar si el usuario existe
    IF dbo.fn_user_exists(@USERNAME) = 0
    BEGIN
        SET @ret = 501;
        GOTO ExitProc;
    END;

    -- Obtener el ID, estado y register code del usuario
    SELECT @UserID = ID, @UserStatus = STATUS, @UserRegisterCode = REGISTER_CODE
    FROM USERS
    WHERE USERNAME = @USERNAME;

    -- Verificar si el usuario ya está activo
    IF @UserStatus = 1
    BEGIN
        SET @ret = 701;
        GOTO ExitProc;
    END;

    -- Verificar si el código de registro coincide
    IF @REGISTER_CODE <> @UserRegisterCode
    BEGIN
        SET @ret = 702;
        GOTO ExitProc;
    END;

    -- Actualizar el estado del usuario a activo (1)
    UPDATE USERS SET STATUS = 1 WHERE ID = @UserID;

    -- Verificar si se actualizó correctamente
    IF @@ROWCOUNT = 0
    BEGIN
        SET @ret = 703;
        GOTO ExitProc;
    END
    ELSE
    BEGIN
        SET @ret = 0;
        GOTO ExitProc;
    END;

ExitProc:
    DECLARE @ResponseXML XML;
    EXEC sp_xml_error_message @RETURN = @ret, @XmlResponse = @ResponseXML OUTPUT;
    SELECT @ResponseXML;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_user_change_password]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- sp_user_change_password
CREATE PROCEDURE [dbo].[sp_user_change_password]
    @USERNAME NVARCHAR(50), 
    @CURRENT_PASSWORD NVARCHAR(50), 
    @NEW_PASSWORD NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ret INT;
    SET @ret = -1;

    DECLARE @XMLFlag XML;

    -- Verifica que la contraseña actual sea válida
    IF (dbo.fn_pwd_isvalid(@CURRENT_PASSWORD, @USERNAME) = 0)
    BEGIN
        SET @ret = 502;
        GOTO ExitProc;
    END

    -- Verifica que la nueva contraseña cumpla con la política
    IF dbo.fn_pwd_checkpolicy(@NEW_PASSWORD) = 0
    BEGIN
        SET @ret = 503;
        GOTO ExitProc;
    END

    -- Verificar si la nueva contraseña es igual a alguna de las tres últimas contraseñas
    IF dbo.fn_compare_soundex(@USERNAME, @NEW_PASSWORD) = 0
    BEGIN
        SET @ret = 402;
        GOTO ExitProc;
    END

    -- Verificar si la nueva contraseña es igual a la última contraseña
    IF dbo.fn_compare_passwords(@NEW_PASSWORD, @USERNAME) = 1
    BEGIN
        SET @ret = 402;
        GOTO ExitProc;
    END

    -- Llamar a la procedure para actualizar la información de contraseña del usuario
    EXEC sp_wdev_user_update_password_info @USERNAME, @CURRENT_PASSWORD, @NEW_PASSWORD, @ret OUTPUT;

    ExitProc:
    DECLARE @ResponseXML XML;
    EXEC sp_xml_error_message @RETURN = @ret, @XmlResponse = @ResponseXML OUTPUT;
    SELECT @ResponseXML;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_user_get_accountdata]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_user_get_accountdata]
    @USERNAME NVARCHAR(25)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ret INT;
    DECLARE @XMLFlag XML;

    SET @ret = -1;

    -- Llamar al procedimiento para verificar la existencia de datos
    EXEC sp_wdev_user_check_existence @USERNAME, @ret OUTPUT, @XMLFlag OUTPUT;

    IF @ret <> -1
    BEGIN
        DECLARE @ResponseXML XML;
        EXEC sp_xml_error_message @RETURN = @ret, @XmlResponse = @ResponseXML OUTPUT;
        SELECT @ResponseXML;
    END
    ELSE
        SELECT @XMLFlag;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_user_login]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_user_login]
    @USERNAME NVARCHAR(25),
    @PASSWORD NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @XML_RESPONSE XML;
    DECLARE @LOGIN_STATUS BIT;
    DECLARE @ret INT;
    SET @ret = -1;

    -- Verificar si el usuario está actualmente conectado
    EXEC sp_wdev_user_get_login_status @USERNAME, @LOGIN_STATUS OUTPUT, @ret OUTPUT;

    -- Verificar si el usuario existe
    IF (dbo.fn_user_exists(@USERNAME) = 0)
    BEGIN
        SET @ret = 501;
        GOTO ExitProc;
    END
    ELSE
    BEGIN
        -- Verificar el estado del usuario
        IF (dbo.fn_user_state(@USERNAME) = 0)
        BEGIN
            SET @ret = 423;
            GOTO ExitProc;
        END
        ELSE
        BEGIN
            -- Verificar la validez de la contraseña
            IF (dbo.fn_pwd_isvalid(@PASSWORD, @USERNAME) = 0)
            BEGIN
                SET @ret = 502;
                GOTO ExitProc;
            END
            ELSE
            BEGIN
                DECLARE @CONNECTION_ID UNIQUEIDENTIFIER;
                SET @CONNECTION_ID = dbo.fn_generate_ssid();

                -- Crear una nueva conexión para el usuario
                EXEC sp_wdev_user_create_user_connection @USERNAME, @CONNECTION_ID, @ret OUTPUT;
            END
        END
    END

    ExitProc:
    DECLARE @ResponseXML XML;
    EXEC sp_xml_error_message @RETURN = @ret, @XmlResponse = @ResponseXML OUTPUT;
    SELECT @ResponseXML;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_user_logout]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_user_logout]
    @USERNAME NVARCHAR(25) 
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ret INT;
    DECLARE @USER_ID INT;
    DECLARE @DATE_CONNECTED DATETIME;
    DECLARE @DATE_DISCONNECTED DATETIME;

    SET @DATE_DISCONNECTED = GETDATE();

    -- Comprueba si el usuario está conectado
    EXEC sp_wdev_check_user_connection @USERNAME, @USER_ID OUTPUT, @DATE_CONNECTED OUTPUT, @ret OUTPUT;

    IF @ret = 100
    BEGIN
        -- Insertar en USER_CONNECTIONS_HISTORY antes de eliminar
        EXEC sp_wdev_insert_user_connection_history 
            @USER_ID, 
            @USERNAME, 
            @DATE_CONNECTED, 
            @DATE_DISCONNECTED -- fecha de desconexión


        -- Eliminar de USER_CONNECTIONS
        DELETE FROM USER_CONNECTIONS WHERE USERNAME = @USERNAME;

        IF @@ROWCOUNT = 1
        BEGIN
            -- Actualizar estado de conexión en USERS
            EXEC sp_wdev_update_user_login_status_0 @USERNAME;

            SET @ret = 0; -- Éxito
        END
    END

    DECLARE @ResponseXML XML;
    EXEC sp_xml_error_message @RETURN = @ret, @XmlResponse = @ResponseXML OUTPUT;
    SELECT @ResponseXML;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_user_register]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_user_register]
    @USERNAME NVARCHAR(25),
    @NAME NVARCHAR(25),
    @LASTNAME NVARCHAR(50),
    @PASSWORD NVARCHAR(50),
    @EMAIL NVARCHAR(30)
AS 
BEGIN
    SET NOCOUNT ON;

    DECLARE @ret INT;
    SET @ret = -1;

    -- Verificar si el usuario ya existe
    IF dbo.fn_user_exists(@USERNAME) = 1
    BEGIN
        SET @ret = 409;
        GOTO ExitProc;
    END
    ELSE
    BEGIN
        -- Verificar si el correo electrónico ya está registrado
        IF dbo.fn_mail_exists(@EMAIL) = 1
        BEGIN
            SET @ret = 408;
            GOTO ExitProc;
        END
        ELSE
        BEGIN
            -- Verificar si el correo electrónico es válido
            IF dbo.fn_mail_isvalid(@EMAIL) = 0
            BEGIN
                SET @ret = 450;
                GOTO ExitProc;
            END
            ELSE
            BEGIN
                -- Verificar la política de contraseña
                IF dbo.fn_pwd_checkpolicy(@PASSWORD) = 0
                BEGIN
                    SET @ret = 451;
                    GOTO ExitProc;
                END
                ELSE
                BEGIN
                    -- Insertar el nuevo usuario si todas las validaciones son exitosas
                    EXEC @ret = sp_wdev_user_insert @USERNAME, @NAME, @LASTNAME, @PASSWORD, @EMAIL;

                    IF @@ROWCOUNT > 0
                    BEGIN
                        SET @ret = 0  
                        GOTO ExitProc;
                    END
                    ELSE
                    BEGIN
                        SET @ret = -1  
                        GOTO ExitProc;
                    END  
                END
            END
        END
    END

    ExitProc:
    DECLARE @ResponseXML XML;
    EXEC sp_xml_error_message @RETURN = @ret, @XmlResponse = @ResponseXML OUTPUT;
    SELECT @ResponseXML;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_user_register_check_pwd]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_user_register_check_pwd](@PASSWORD NVARCHAR(100))
AS
BEGIN
    DECLARE @ret INT = 0;
    DECLARE @XmlResponse XML;

    -- Validaciones de la contraseña
    IF LEN(@PASSWORD) < 10
        SET @ret = 1001;
    ELSE IF PATINDEX('%[0-9]%', @PASSWORD) = 0
        SET @ret = 1002;
    ELSE IF PATINDEX('%[A-Z]%', @PASSWORD COLLATE Latin1_General_BIN) = 0
        SET @ret = 1003;
    ELSE IF PATINDEX('%[^a-zA-Z0-9]%', @PASSWORD) = 0
        SET @ret = 1004;

    -- Si hubo error, obtener mensaje desde sp_xml_error_message
    IF @ret <> 0
    BEGIN
        EXEC sp_xml_error_message @ret, @XmlResponse OUTPUT;
        SELECT @XmlResponse;
        RETURN @ret;
    END

    -- Si pasa todas las validaciones, devolver éxito (código 0)
    EXEC sp_xml_error_message 0, @XmlResponse OUTPUT;
    SELECT @XmlResponse;
    RETURN 0;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_wdev_check_user_connection]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_wdev_check_user_connection]
    @USERNAME NVARCHAR(25),
    @USER_ID INT OUTPUT,
    @DATE_CONNECTED DATETIME OUTPUT,
    @ret INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @ret = -1;

    -- Comprueba si el usuario está conectado
    IF EXISTS (
        SELECT 1 FROM USER_CONNECTIONS WHERE USERNAME = @USERNAME
    )
    BEGIN
        -- Obtén la información de la conexión
        SELECT 
            @USER_ID = USER_ID, 
            @DATE_CONNECTED = DATE_CONNECTED 
        FROM USER_CONNECTIONS 
        WHERE USERNAME = @USERNAME;

        SET @ret = 100; -- Éxito
    END
    ELSE
    BEGIN
        SET @ret = 405; -- Conexión no encontrada
    END
END
GO
/****** Object:  StoredProcedure [dbo].[sp_wdev_deletealldata]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- sp_wdev_deletealldata
CREATE   PROCEDURE [dbo].[sp_wdev_deletealldata]
    @USERNAME NVARCHAR(25),
    @PASSWORD NVARCHAR(50)


AS
BEGIN
    DECLARE @ret INT;

    SET @ret= -1;

    
END
GO
/****** Object:  StoredProcedure [dbo].[sp_wdev_get_registercode]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_wdev_get_registercode]
    @USERNAME NVARCHAR(25),
    @REGISTER_CODE INT OUTPUT -- Parámetro de salida para el código de registro
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ret INT;
    SET @ret = -1;

    -- Buscar el código de registro para el usuario dado
    SELECT @REGISTER_CODE = REGISTER_CODE
    FROM USERS
    WHERE USERNAME = @USERNAME;

    -- Verificar si se encontró el código de registro
    IF @REGISTER_CODE IS NOT NULL
    BEGIN
        -- Si se encontró, establecer el código de retorno en 0 (éxito)
        SET @ret = 0;
    END
    ELSE
    BEGIN
        -- Si no se encontró, establecer el código de retorno en 404 (no encontrado)
        SET @ret = 404;
    END

    -- Obtener el objeto XML de respuesta para el código de error
    DECLARE @ResponseXML XML;
    EXEC sp_xml_error_message @RETURN = @ret, @XmlResponse = @ResponseXML OUTPUT;

    -- Verificar si se encontró el código de registro
    IF @ret = 0
    BEGIN
        -- Si todo está bien, incluir el código de registro en el XML de respuesta
        SELECT @REGISTER_CODE;
    END

    -- Devolver el objeto XML de respuesta
    -- SELECT @ResponseXML;
END;




-- EXEC sp_get_registercode @USERNAME="pauallende04",@REGISTER_CODE=0
GO
/****** Object:  StoredProcedure [dbo].[sp_wdev_insert_user_connection_history]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_wdev_insert_user_connection_history]
    @USER_ID INT,
    @USERNAME NVARCHAR(25),
    @DATE_CONNECTED DATETIME,
    @DATE_DISCONNECTED DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO USER_CONNECTIONS_HISTORY (USER_ID, USERNAME, DATE_CONNECTED, DATE_DISCONNECTED)
    VALUES (@USER_ID, @USERNAME, @DATE_CONNECTED, @DATE_DISCONNECTED);
END
GO
/****** Object:  StoredProcedure [dbo].[sp_wdev_update_user_login_status_0]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_wdev_update_user_login_status_0]
    @USERNAME NVARCHAR(25)
AS 
BEGIN
    UPDATE USERS SET LOGIN_STATUS = 0 WHERE USERNAME = @USERNAME;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_wdev_user_check_existence]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_wdev_user_check_existence]
    @USERNAME NVARCHAR(25),
    @ret INT OUTPUT,
    @XMLFlag XML OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Verificar si hay datos en el historial de conexiones
    IF EXISTS (SELECT 1 FROM USERS WHERE USERNAME=@USERNAME)
    BEGIN
        -- Si hay datos, convertir el conjunto de resultados a XML
        SET @XMLFlag = (
            SELECT USERNAME, NAME, LASTNAME, EMAIL, GENDER FROM USERS WHERE USERNAME = @USERNAME
            FOR XML PATH('User'), ROOT('Users'), TYPE
        );

        SET @ret=0
    END
    ELSE
    BEGIN
        SET @ret = 505; -- Indicar que hubo resultados
    END
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_wdev_user_create_user_connection]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_wdev_user_create_user_connection]
    @USERNAME NVARCHAR(25),
    @CONNECTION_ID UNIQUEIDENTIFIER,
    @ret INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO USER_CONNECTIONS
        (CONNECTION_ID, USER_ID, USERNAME, DATE_CONNECTED)
    VALUES
        (@CONNECTION_ID, (SELECT ID FROM USERS WHERE USERNAME = @USERNAME), @USERNAME, CONVERT(DATETIME, SWITCHOFFSET(SYSDATETIMEOFFSET(), '+02:00')));

    UPDATE USERS SET LOGIN_STATUS = 1 WHERE USERNAME = @USERNAME;

    IF @@ROWCOUNT = 1
    BEGIN
        SET @ret = 0;
    END
    ELSE
    BEGIN
        SET @ret = -1; -- Algo salió mal durante la creación de la conexión
    END
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_wdev_user_get_login_status]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_wdev_user_get_login_status]
    @USERNAME NVARCHAR(25),
    @LOGIN_STATUS BIT OUTPUT,
    @ret INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @LOGIN_STATUS = LOGIN_STATUS
    FROM USERS
    WHERE USERNAME = @USERNAME;

    IF @LOGIN_STATUS = 1
    BEGIN
        SET @ret = 500;
    END
    ELSE
    BEGIN
        SET @ret = 0;
    END
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_wdev_user_insert]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_wdev_user_insert]
@USERNAME NVARCHAR(25),
@NAME NVARCHAR(25),
@LASTNAME NVARCHAR(50),
@PASSWORD NVARCHAR(50),
@EMAIL NVARCHAR(30)
AS
BEGIN
DECLARE @REGISTER_CODE INT;

    -- Generar código de 5 dígitos aleatorio
    SET @REGISTER_CODE = CAST((RAND() * 90000) + 10000 AS INT);

    -- Insertar datos en la tabla USERS
    INSERT INTO USERS (USERNAME, NAME, LASTNAME, PASSWORD, EMAIL, STATUS, REGISTER_CODE, LOGIN_STATUS)
    VALUES (@USERNAME, @NAME, @LASTNAME, @PASSWORD, @EMAIL, 0, @REGISTER_CODE, 0);

    -- Devolver el código generado
    RETURN @REGISTER_CODE;

END;
GO
/****** Object:  StoredProcedure [dbo].[sp_wdev_user_update_password_info]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_wdev_user_update_password_info]
    @USERNAME NVARCHAR(50),
    @CURRENT_PASSWORD NVARCHAR(50),
    @NEW_PASSWORD NVARCHAR(50),
    @ret INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @USER_ID INT;

    -- Obtener la información del usuario
    SELECT 
        @USER_ID = ID
    FROM USERS 
    WHERE USERNAME = @USERNAME;

    -- Guardar la contraseña anterior en PWD_HISTORY
    INSERT INTO PWD_HISTORY(
        USER_ID,
        USERNAME,
        OLD_PASSWORD, 
        DATE_CHANGED
    ) 
    VALUES (
        @USER_ID,
        @USERNAME, 
        @CURRENT_PASSWORD, 
        GETDATE() -- fecha de cambio de contraseña
    );

    -- Actualizar la contraseña del usuario
    UPDATE USERS 
    SET PASSWORD = @NEW_PASSWORD 
    WHERE USERNAME = @USERNAME;
    
    SET @ret = 0;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_xml_error_message]    Script Date: 07/05/2025 18:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_xml_error_message]
    @RETURN INT,
    @XmlResponse XML OUTPUT
AS
BEGIN
    DECLARE @ERROR_CODE INT;
    SET @ERROR_CODE = @RETURN;

    DECLARE @ERROR_MESSAGE NVARCHAR(200);

    IF @ERROR_CODE = 0
    BEGIN
        -- Cuando @ERROR_CODE no es 200, se recupera el mensaje de error correspondiente
        SELECT @ERROR_MESSAGE = ERROR_MESSAGE FROM USER_ERRORS WHERE ERROR_CODE = @ERROR_CODE;
        
        SET @XmlResponse = (
            SELECT @ERROR_CODE AS 'StatusCode',
                @ERROR_MESSAGE AS 'Message'
            FOR XML PATH('Success'), ROOT('Successes'), TYPE
        );
    END
    ELSE
    BEGIN
        -- Cuando @ERROR_CODE no es 200, se recupera el mensaje de error correspondiente
        SELECT @ERROR_MESSAGE = ERROR_MESSAGE FROM USER_ERRORS WHERE ERROR_CODE = @ERROR_CODE;
        
        SET @XmlResponse = (
            SELECT @ERROR_CODE AS 'StatusCode',
                @ERROR_MESSAGE AS 'Message'
            FOR XML PATH('Error'), ROOT('Errors'), TYPE
        );
    END

END
GO
USE [master]
GO
ALTER DATABASE [PP_DDBB] SET  READ_WRITE 
GO
