USE [master]
GO
/****** Object:  Database [PP_DDBB]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  UserDefinedFunction [dbo].[CalculateHash]    Script Date: 26/05/2025 23:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[CalculateHash](@BlockID INT)
RETURNS NVARCHAR(32)
AS
BEGIN
    DECLARE @ConcatString NVARCHAR(MAX);
    DECLARE @Hash NVARCHAR(32);

    SELECT @ConcatString = COALESCE(@ConcatString, '') + 
        CAST(BlockID AS NVARCHAR) + 
        CAST(Timestamp AS NVARCHAR) + 
        ISNULL(PreviousHash, '')
    FROM Blocks
    WHERE BlockID = @BlockID;

    -- Using HASHBYTES (MD5)
    SET @Hash = CONVERT(NVARCHAR(32), HASHBYTES('MD5', @ConcatString), 2);

    RETURN @Hash;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_compare_passwords]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  UserDefinedFunction [dbo].[fn_compare_soundex]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  UserDefinedFunction [dbo].[fn_generate_ssid]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  UserDefinedFunction [dbo].[fn_mail_exists]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  UserDefinedFunction [dbo].[fn_mail_isvalid]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  UserDefinedFunction [dbo].[fn_pwd_checkpolicy]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  UserDefinedFunction [dbo].[fn_pwd_isvalid]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  UserDefinedFunction [dbo].[fn_user_exists]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  UserDefinedFunction [dbo].[fn_user_state]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  View [dbo].[v_guid]    Script Date: 26/05/2025 23:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[v_guid] 
AS
    select newid() guid
GO
/****** Object:  Table [dbo].[Blocks]    Script Date: 26/05/2025 23:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Blocks](
	[BlockID] [int] IDENTITY(1,1) NOT NULL,
	[Timestamp] [datetime] NULL,
	[PreviousHash] [nvarchar](32) NULL,
	[Hash] [nvarchar](32) NULL,
PRIMARY KEY CLUSTERED 
(
	[BlockID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BlockTransactions]    Script Date: 26/05/2025 23:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BlockTransactions](
	[BlockID] [int] NOT NULL,
	[TransactionID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[BlockID] ASC,
	[TransactionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PWD_HISTORY]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  Table [dbo].[STATUS]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  Table [dbo].[Transactions]    Script Date: 26/05/2025 23:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Transactions](
	[TransactionID] [int] IDENTITY(1,1) NOT NULL,
	[Sender] [nvarchar](50) NULL,
	[Receiver] [nvarchar](50) NULL,
	[Amount] [decimal](18, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[TransactionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[USER_CONNECTIONS]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  Table [dbo].[USER_CONNECTIONS_HISTORY]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  Table [dbo].[USER_ERRORS]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  Table [dbo].[USERS]    Script Date: 26/05/2025 23:44:54 ******/
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
	[BALANCE] [decimal](10, 2) NULL,
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
ALTER TABLE [dbo].[Blocks] ADD  DEFAULT (getdate()) FOR [Timestamp]
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
ALTER TABLE [dbo].[USERS] ADD  CONSTRAINT [DF_users_balance]  DEFAULT ((0)) FOR [BALANCE]
GO
ALTER TABLE [dbo].[BlockTransactions]  WITH CHECK ADD FOREIGN KEY([BlockID])
REFERENCES [dbo].[Blocks] ([BlockID])
GO
ALTER TABLE [dbo].[BlockTransactions]  WITH CHECK ADD FOREIGN KEY([TransactionID])
REFERENCES [dbo].[Transactions] ([TransactionID])
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
/****** Object:  StoredProcedure [dbo].[AddBlock]    Script Date: 26/05/2025 23:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddBlock]
    @PreviousHash NVARCHAR(32),
    @Hash NVARCHAR(32)
AS
BEGIN
    SET NOCOUNT ON;  -- <----- Añadir esta línea
    
    INSERT INTO Blocks (PreviousHash)
    VALUES (@PreviousHash);

    DECLARE @BlockID INT = SCOPE_IDENTITY();

    UPDATE Blocks
    SET Hash = @Hash
    WHERE BlockID = @BlockID;

    SELECT @BlockID AS BlockID;
END;
GO
/****** Object:  StoredProcedure [dbo].[AddTransaction]    Script Date: 26/05/2025 23:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddTransaction]
    @Sender NVARCHAR(50),
    @Receiver NVARCHAR(50),
    @Amount DECIMAL(18, 2),
    @BlockID INT
AS
BEGIN
    SET NOCOUNT ON;  -- ✅ Esto evita que se devuelva "N rows affected"

    INSERT INTO Transactions (Sender, Receiver, Amount)
    VALUES (@Sender, @Receiver, @Amount);

    DECLARE @TransactionID INT = SCOPE_IDENTITY();

    INSERT INTO BlockTransactions (BlockID, TransactionID)
    VALUES (@BlockID, @TransactionID);

    -- ✅ Opcional: si esperas recibir el ID en PHP, añade este SELECT
    SELECT @TransactionID AS TransactionID;
END;
GO
/****** Object:  StoredProcedure [dbo].[AddTransaction2]    Script Date: 26/05/2025 23:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[AddTransaction2]
    @ssid NVARCHAR(100),
    @Receiver NVARCHAR(50),
    @Amount DECIMAL(18, 2),
    @BlockID INT
AS
BEGIN
    SET NOCOUNT ON;  -- ✅ Esto evita que se devuelva "N rows affected"
	DECLARE @Sender NVARCHAR(100);
	SELECT @Sender = username FROM USER_CONNECTIONS WHERE CONNECTION_ID = @ssid;

    INSERT INTO Transactions (Sender, Receiver, Amount)
    VALUES (@Sender, @Receiver, @Amount);

    DECLARE @TransactionID INT = SCOPE_IDENTITY();

    INSERT INTO BlockTransactions (BlockID, TransactionID)
    VALUES (@BlockID, @TransactionID);

    -- ✅ Opcional: si esperas recibir el ID en PHP, añade este SELECT
    SELECT @TransactionID AS TransactionID;
END;
GO
/****** Object:  StoredProcedure [dbo].[GetLastBlock]    Script Date: 26/05/2025 23:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[GetLastBlock]
AS
BEGIN
    SELECT MAX(BlockID) AS LastBlockID FROM dbo.Blocks;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_check_balance]    Script Date: 26/05/2025 23:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_check_balance]
    @USERNAME NVARCHAR(25),
    @AMOUNT DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ret INT = -1;
    DECLARE @BALANCE DECIMAL(20,2);
    DECLARE @ResponseXML XML;

    IF (dbo.fn_user_exists(@USERNAME) = 0)
    BEGIN
        SET @ret = 501;
        GOTO ExitProc;
    END

    SELECT @BALANCE = balance
    FROM USERS
    WHERE username = @USERNAME;

    IF (@BALANCE IS NULL OR @BALANCE < @AMOUNT)
    BEGIN
        SET @ret = 201;
        GOTO ExitProc;
    END

    SET @ret = 0;

ExitProc:
    EXEC sp_xml_error_message @RETURN = @ret, @XmlResponse = @ResponseXML OUTPUT;

    -- En lugar de devolver el XML, solo devuelve el num_error
    SELECT @ResponseXML.value('(/ws_response/head/errors/errors/error/num_error)[1]', 'INT') AS num_error;
END



/*

EXEC sp_check_balance 
    @USERNAME = 'umi', 
    @AMOUNT = 1000000000;

*/
GO
/****** Object:  StoredProcedure [dbo].[sp_check_balance2]    Script Date: 26/05/2025 23:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec sp_check_balance2 'ca528645-69f3-448d-8cd3-466f27a83fd8',10
-- Procedimiento almacenado corregido
CREATE PROCEDURE [dbo].[sp_check_balance2]
    @SSID UNIQUEIDENTIFIER,
    @AMOUNT DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ret INT = -1;
    DECLARE @BALANCE DECIMAL(20,2);
    DECLARE @ResponseXML XML;
    DECLARE @USERNAME NVARCHAR(100);

    -- Buscar el nombre de usuario asociado al SSID (GUID)
    SELECT @USERNAME = USERNAME 
    FROM USER_CONNECTIONS 
    WHERE CONNECTION_ID = @SSID;

    -- Verificar si el usuario existe usando una función
    IF (dbo.fn_user_exists(@USERNAME) = 0)
    BEGIN
        SET @ret = 501;
        GOTO ExitProc;
    END

    -- Obtener el balance del usuario
    SELECT @BALANCE = BALANCE
    FROM USERS
    WHERE USERNAME = @USERNAME;

    -- Verificar si el balance es suficiente
    IF (@BALANCE IS NULL OR @BALANCE < @AMOUNT)
    BEGIN
        SET @ret = 201;
        GOTO ExitProc;
    END

    -- Éxito
    SET @ret = 0;

ExitProc:
    -- Llama al procedimiento que devuelve el XML de error y luego extrae el código de error
    EXEC sp_xml_error_message @RETURN = @ret, @XmlResponse = @ResponseXML OUTPUT;

    -- Devuelve solo el número de error como resultado final
    SELECT @ResponseXML;
	--.value('(/ws_response/head/errors/errors/error/num_error)[1]', 'INT') AS num_error;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_create_bizum]    Script Date: 26/05/2025 23:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_create_bizum]
    @SENDER NVARCHAR(25),
    @RECEIVER NVARCHAR(25),
    @AMOUNT DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ret INT = 0;
    DECLARE @XML_RESPONSE XML;

    -- 1. Validación básica
    IF NOT EXISTS (SELECT 1 FROM USERS WHERE USERNAME = @SENDER)
    BEGIN
        SET @ret = 501; -- Usuario emisor no existe
        GOTO ExitProc;
    END

    IF NOT EXISTS (SELECT 1 FROM USERS WHERE USERNAME = @RECEIVER)
    BEGIN
        SET @ret = 501; -- Usuario receptor no existe
        GOTO ExitProc;
    END

    -- 2. Verificar saldo
	/*
    DECLARE @BALANCE DECIMAL(10,2);
    SELECT @BALANCE = balance FROM USERS WHERE USERNAME = @SENDER;

    IF @BALANCE < @AMOUNT
    BEGIN
        SET @ret = 400; -- Saldo insuficiente
        GOTO ExitProc;
    END
	*/
    -- 3. Transacción atómica
    BEGIN TRANSACTION;

    BEGIN TRY
        -- 4. Descontar saldo emisor
        UPDATE USERS
        SET balance = balance - @AMOUNT
        WHERE USERNAME = @SENDER;

        -- 5. Aumentar saldo receptor
        UPDATE USERS
        SET balance = balance + @AMOUNT
        WHERE USERNAME = @RECEIVER;

        -- 6. Registrar en tabla de transacciones
        --INSERT INTO Transactions(sender, receiver, amount)
        --VALUES (@SENDER, @RECEIVER, @AMOUNT);

        COMMIT;
        SET @ret = 0; -- OK
    END TRY
    BEGIN CATCH
        ROLLBACK;
        SET @ret = -1; -- Error desconocido
    END CATCH

ExitProc:
	DECLARE @bizumData XML = NULL;

	IF (@ret = 0)
	BEGIN
		SELECT @bizumData = (
			SELECT 
				@SENDER AS sender,
				@RECEIVER AS receiver,
				balance
			FROM Users
			WHERE username = @SENDER
			FOR XML PATH('user'), TYPE
		);
	END

	EXEC sp_xml_error_message @RETURN = @ret, @XmlResponse = @XML_RESPONSE OUTPUT, @UserData = @bizumData;
	SELECT @XML_RESPONSE;

END;





/*
exec sp_create_bizum
    @SENDER = 'umi', 
	@RECEIVER = 'asier',
    @AMOUNT = 1;
	*/
GO
/****** Object:  StoredProcedure [dbo].[sp_create_bizum2]    Script Date: 26/05/2025 23:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec sp_create_bizum2 'ca528645-69f3-448d-8cd3-466f27a83fd8','lily',1

CREATE  PROCEDURE [dbo].[sp_create_bizum2]
    @ssid NVARCHAR(100),
    @RECEIVER NVARCHAR(25),
    @AMOUNT DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ret INT = 0;
    DECLARE @XML_RESPONSE XML;
	DECLARE @SENDER NVARCHAR(100);

	SELECT @SENDER = username FROM USER_CONNECTIONS WHERE CONNECTION_ID = @ssid;
	print @sender;
    -- 1. Validación básica
    IF NOT EXISTS (SELECT 1 FROM USERS WHERE USERNAME = @SENDER)
    BEGIN
        SET @ret = 501; -- Usuario emisor no existe
        GOTO ExitProc;
    END

    IF NOT EXISTS (SELECT 1 FROM USERS WHERE USERNAME = @RECEIVER)
    BEGIN
        SET @ret = 501; -- Usuario receptor no existe
        GOTO ExitProc;
    END

    -- 2. Verificar saldo
	
    DECLARE @BALANCE DECIMAL(10,2);
    SELECT @BALANCE = balance FROM USERS WHERE USERNAME = @SENDER;

    IF @BALANCE < @AMOUNT
    BEGIN
        SET @ret = 400; -- Saldo insuficiente
        GOTO ExitProc;
    END
	
    -- 3. Transacción atómica
    BEGIN TRANSACTION;

    BEGIN TRY
        -- 4. Descontar saldo emisor
        UPDATE USERS
        SET balance = balance - @AMOUNT
        WHERE USERNAME = @SENDER;

        -- 5. Aumentar saldo receptor
        UPDATE USERS
        SET balance = balance + @AMOUNT
        WHERE USERNAME = @RECEIVER;

        -- 6. Registrar en tabla de transacciones
        --INSERT INTO Transactions(sender, receiver, amount)
        --VALUES (@SENDER, @RECEIVER, @AMOUNT);

        COMMIT;
        SET @ret = 0; -- OK
    END TRY
    BEGIN CATCH
        ROLLBACK;
        SET @ret = -1; -- Error desconocido
    END CATCH

ExitProc:
	DECLARE @bizumData XML = NULL;

	IF (@ret = 0)
	BEGIN
		SELECT @bizumData = (
			SELECT 
				@SENDER AS sender,
				@RECEIVER AS receiver,
				balance
			FROM Users
			WHERE username = @SENDER
			FOR XML PATH('user'), TYPE
		);
	END

	EXEC sp_xml_error_message @RETURN = @ret, @XmlResponse = @XML_RESPONSE OUTPUT, @UserData = @bizumData;
	SELECT @XML_RESPONSE;

END;



/*
exec sp_create_bizum
    @SENDER = 'umi', 
	@RECEIVER = 'asier',
    @AMOUNT = 1;
	*/
GO
/****** Object:  StoredProcedure [dbo].[sp_create_xml_from_url]    Script Date: 26/05/2025 23:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_create_xml_from_url]
    @URL NVARCHAR(MAX),
	@createURL XML OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Crear el XML a partir de la URL proporcionada

    SET @createURL =
    (
        SELECT @URL
        FOR XML PATH(''), TYPE
    );

END;
GO
/****** Object:  StoredProcedure [dbo].[sp_get_balance]    Script Date: 26/05/2025 23:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_get_balance]
    @USERNAME NVARCHAR(25)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT BALANCE
    FROM USERS
    WHERE USERNAME = @USERNAME;
END


/*

EXEC sp_get_balance 
    @USERNAME = 'umi';

*/
GO
/****** Object:  StoredProcedure [dbo].[sp_get_procedure_params_JSON]    Script Date: 26/05/2025 23:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_get_procedure_params_JSON]
    @jsonParams NVARCHAR(MAX),  -- Parámetro JSON con los nombres y valores
	@ResultXML XML OUTPUT
AS
BEGIN
    -- Tabla temporal para almacenar los parámetros y sus valores
    DECLARE @Params TABLE (
        name NVARCHAR(255),
        value NVARCHAR(MAX)
    );

    -- Insertar los parámetros desde el JSON
    INSERT INTO @Params (name, value)
    SELECT 
        JSON_VALUE(valor.value, '$.ParamName') AS ParamName,
        JSON_VALUE(valor.value, '$.ParamValue') AS ParamValue
    FROM OPENJSON(@jsonParams) AS valor;

    -- Generar el XML dinámicamente

    SET @ResultXML = (
		SELECT 
			name ,
			value
		FROM @Params
		FOR XML PATH('parameter')

    );

END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_transactions]    Script Date: 26/05/2025 23:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_get_transactions]
    @username NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @XML_RESPONSE XML;
    DECLARE @ret INT = -1;
    DECLARE @transactionsData XML = NULL;

    IF EXISTS (
        SELECT 1 
        FROM transactions 
        WHERE sender = @username OR receiver = @username
    )
    BEGIN
        SELECT @transactionsData = (
            SELECT 
                sender,
                receiver,
                amount
            FROM transactions
            WHERE sender = @username OR receiver = @username
            FOR XML PATH('transaction'), ROOT('transactions'), TYPE
        );
        SET @ret = 0;
    END
    ELSE
    BEGIN
        SET @ret = 404;
    END

    EXEC sp_xml_error_message 
        @RETURN = @ret, 
        @XmlResponse = @XML_RESPONSE OUTPUT, 
        @UserData = @transactionsData;

    SELECT @XML_RESPONSE;
END;

-- exec sp_get_transactions
GO
/****** Object:  StoredProcedure [dbo].[sp_get_transactions2]    Script Date: 26/05/2025 23:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_get_transactions2]
    @ssid UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ret INT = -1;
    DECLARE @USERNAME NVARCHAR(100);
    DECLARE @ResponseXML XML;

    -- Obtener el username desde USER_CONNECTIONS
    SELECT @USERNAME = USERNAME FROM USER_CONNECTIONS WHERE CONNECTION_ID = @ssid;

    IF @USERNAME IS NULL OR dbo.fn_user_exists(@USERNAME) = 0
    BEGIN
        SET @ret = 501; -- Usuario no válido
        GOTO ExitProc;
    END

    DECLARE @TransactionsXML XML;

    -- Obtener transacciones donde el usuario es emisor o receptor
    SELECT @TransactionsXML = (
        SELECT
            sender,
            receiver,
            amount
        FROM TRANSACTIONS
        WHERE sender = @USERNAME OR receiver = @USERNAME
        FOR XML PATH('transaction'), ROOT('transactions'), TYPE
    );

    SET @ret = 0;

ExitProc:
    EXEC sp_xml_error_message
        @RETURN = @ret,
        @XmlResponse = @ResponseXML OUTPUT,
        @UserData = @TransactionsXML;

    SELECT @ResponseXML;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_list_connections]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  StoredProcedure [dbo].[sp_list_errors]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  StoredProcedure [dbo].[sp_list_historic_connections]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  StoredProcedure [dbo].[sp_list_historic_user_connections]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  StoredProcedure [dbo].[sp_list_system_status]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  StoredProcedure [dbo].[sp_list_transactions]    Script Date: 26/05/2025 23:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_list_transactions]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @XML_RESPONSE XML;
    DECLARE @ret INT = -1;
    DECLARE @transactionsData XML = NULL;

    IF EXISTS (SELECT 1 FROM transactions)
    BEGIN
        SELECT @transactionsData = (
            SELECT 
                sender,
                receiver,
                amount
            FROM transactions
            FOR XML PATH('transaction'), ROOT('transactions'), TYPE
        );
        SET @ret = 0; -- Éxito
    END
    ELSE
    BEGIN
        SET @ret = 404; -- Sin transacciones
    END

    EXEC sp_xml_error_message 
        @RETURN = @ret, 
        @XmlResponse = @XML_RESPONSE OUTPUT, 
        @UserData = @transactionsData;

    SELECT @XML_RESPONSE;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_list_transactions2]    Script Date: 26/05/2025 23:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_list_transactions2]
    @SSID UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @XML_RESPONSE XML;
    DECLARE @ret INT = -1;
    DECLARE @transactionsData XML = NULL;
	DECLARE @SENDER NVARCHAR(100);
	SELECT @SENDER = username FROM USER_CONNECTIONS WHERE CONNECTION_ID = @ssid;

    IF EXISTS (SELECT 1 FROM transactions)
    BEGIN
        SELECT @transactionsData = (
            SELECT 
                @SENDER AS sender,
                receiver,
                amount
            FROM transactions
            FOR XML PATH('transaction'), ROOT('transactions'), TYPE
        );
        SET @ret = 0; -- Éxito
    END
    ELSE
    BEGIN
        SET @ret = 404; -- Sin transacciones
    END

    EXEC sp_xml_error_message 
        @RETURN = @ret, 
        @XmlResponse = @XML_RESPONSE OUTPUT, 
        @UserData = @transactionsData;

    SELECT @XML_RESPONSE;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_list_users]    Script Date: 26/05/2025 23:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_list_users]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @XML_RESPONSE XML;
    DECLARE @ret INT = -1;
    DECLARE @contactsData XML = NULL;

    IF EXISTS (SELECT 1 FROM USERS)
    BEGIN
        SELECT @contactsData = (
            SELECT 
                username,
                name
            FROM USERS
            FOR XML PATH('user'), ROOT('users'), TYPE
        );
        SET @ret = 0; -- Éxito
    END
    ELSE
    BEGIN
        SET @ret = 404; -- Sin usuarios
    END

    EXEC sp_xml_error_message 
        @RETURN = @ret, 
        @XmlResponse = @XML_RESPONSE OUTPUT, 
        @UserData = @contactsData;

    SELECT @XML_RESPONSE;
END;

exec sp_list_users
GO
/****** Object:  StoredProcedure [dbo].[sp_list_users2]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  StoredProcedure [dbo].[sp_user_accountvalidate]    Script Date: 26/05/2025 23:44:54 ******/
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


-- exec sp_user_accountvalidate @USERNAME = 'catetiya', @REGISTER_CODE = 68116
GO
/****** Object:  StoredProcedure [dbo].[sp_user_change_password]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  StoredProcedure [dbo].[sp_user_get_accountdata]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  StoredProcedure [dbo].[sp_user_login]    Script Date: 26/05/2025 23:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_user_login]
    @USERNAME NVARCHAR(25),
    @PASSWORD NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @XML_RESPONSE XML;
    DECLARE @LOGIN_STATUS BIT;
    DECLARE @ret INT;
	DECLARE @ID NVARCHAR(100);

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
				SELECT @ID = CONNECTION_ID FROM USER_CONNECTIONS;
	

            END
        END
    END

    ExitProc:
	DECLARE @userData XML = NULL;

	IF (@ret = 0)
	BEGIN
		SELECT @userData = (
			SELECT 
				@USERNAME AS username,
				name,
				lastname,
				password,
				email,
				status,
				gender,
				def_lang,
				timestamp,
				register_code,
				login_status,
				rol_user,
				balance,
				@ID AS ssid
			FROM Users
			WHERE username = @USERNAME
			FOR XML PATH('user'), TYPE
		);
	END

	EXEC sp_xml_error_message @RETURN = @ret, @XmlResponse = @XML_RESPONSE OUTPUT, @UserData = @userData;
	SELECT @XML_RESPONSE;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_user_logout]    Script Date: 26/05/2025 23:44:54 ******/
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

    IF @ret = 0
    BEGIN
        -- Insertar en USER_CONNECTIONS_HISTORY antes de eliminar
        EXEC sp_wdev_insert_user_connection_history 
            @USER_ID, 
            @USERNAME, 
            @DATE_CONNECTED, 
            @DATE_DISCONNECTED -- fecha de desconexión

        -- Eliminar de USER_CONNECTIONS
        DELETE FROM USER_CONNECTIONS WHERE USERNAME = @USERNAME;

        --
        BEGIN
            -- Actualizar estado de conexión en USERS
            EXEC sp_wdev_update_user_login_status_0 @USERNAME;

            SET @ret = 100; -- Éxito
        END
    END

    DECLARE @ResponseXML XML;
    EXEC sp_xml_error_message @RETURN = @ret, @XmlResponse = @ResponseXML OUTPUT;
    SELECT @ResponseXML;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_user_register]    Script Date: 26/05/2025 23:44:54 ******/
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
	DECLARE @REGISTER_CODE INT;
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
                        SET @ret = 0;
						EXEC @REGISTER_CODE = sp_wdev_get_registercode @USERNAME
                        GOTO ExitProc;
                    END
                    ELSE
                    BEGIN
                        SET @ret = -1;
                        GOTO ExitProc;
                    END  
                END
            END
        END
    END

    ExitProc:
    DECLARE @ResponseXML XML;
    DECLARE @UserData XML = NULL;

    -- Incluir datos del usuario si se registró correctamente
    IF (@ret = 0)
    BEGIN
        SET @UserData = (
            SELECT 
                @USERNAME AS username,
                @NAME AS name,
                @LASTNAME AS lastname,
                @PASSWORD AS password,
                @EMAIL AS email,
				@REGISTER_CODE AS register_code
            FOR XML PATH('user'), TYPE
        );
    END

    EXEC sp_xml_error_message @RETURN = @ret, @XmlResponse = @ResponseXML OUTPUT, @UserData = @UserData;
    SELECT @ResponseXML;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_user_register_check_pwd]    Script Date: 26/05/2025 23:44:54 ******/
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

    -- Si pasa todas las validaciones, devolver éxito con código 1000
    EXEC sp_xml_error_message 1000, @XmlResponse OUTPUT;
    SELECT @XmlResponse;
    RETURN 1000;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_wdev_check_user_connection]    Script Date: 26/05/2025 23:44:54 ******/
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

        SET @ret = 0; -- Éxito
    END
    ELSE
    BEGIN
        SET @ret = 405; -- Conexión no encontrada
    END
END
GO
/****** Object:  StoredProcedure [dbo].[sp_wdev_deletealldata]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  StoredProcedure [dbo].[sp_wdev_get_registercode]    Script Date: 26/05/2025 23:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_wdev_get_registercode]
    @USERNAME NVARCHAR(25)
AS
BEGIN
	DECLARE @REGISTER_CODE INT;

    SET NOCOUNT ON;

    DECLARE @ret INT;
    SET @ret = -1;

    -- Buscar el código de registro para el usuario dado
	SELECT @REGISTER_CODE = register_code FROM USERS
	WHERE USERNAME = @USERNAME;



RETURN @REGISTER_CODE;
END;


-- EXEC sp_wdev_get_registercode @USERNAME="asier"
GO
/****** Object:  StoredProcedure [dbo].[sp_wdev_insert_user_connection_history]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  StoredProcedure [dbo].[sp_wdev_update_user_login_status_0]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  StoredProcedure [dbo].[sp_wdev_user_check_existence]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  StoredProcedure [dbo].[sp_wdev_user_create_user_connection]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  StoredProcedure [dbo].[sp_wdev_user_get_login_status]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  StoredProcedure [dbo].[sp_wdev_user_insert]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  StoredProcedure [dbo].[sp_wdev_user_update_password_info]    Script Date: 26/05/2025 23:44:54 ******/
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
/****** Object:  StoredProcedure [dbo].[sp_xml_error_message]    Script Date: 26/05/2025 23:44:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_xml_error_message]
    @RETURN INT,
    @XmlResponse XML OUTPUT,
	@UserData XML = NULL
AS
BEGIN
    DECLARE @SERVER_ID NVARCHAR(200) = @@SERVERNAME;
    DECLARE @SERVER_TIME NVARCHAR(20) = CONVERT(NVARCHAR(20), GETDATE(), 120);
    DECLARE @EXECUTION_TIME NVARCHAR(20) = '0.00'; 
    DECLARE @URL NVARCHAR(200) = 'http://ws.mybizum.com/'; 
    DECLARE @WEBMETHOD_NAME NVARCHAR(100) = 'MyWebMethod'; 
    DECLARE @PARAM_NAME NVARCHAR(100) = 'param';
    DECLARE @PARAM_VALUE NVARCHAR(100) = 'value';

    DECLARE @ERROR_CODE INT = @RETURN;
    DECLARE @ERROR_MESSAGE NVARCHAR(200);
    DECLARE @SEVERITY INT = 1; -- Ajustar si tienes severidades reales
    DECLARE @USER_MESSAGE NVARCHAR(200) = 'user message';

    -- Buscar mensaje de error
    SELECT @ERROR_MESSAGE = ERROR_MESSAGE
    FROM USER_ERRORS
    WHERE ERROR_CODE = @ERROR_CODE;

    -- Construir XML final con estructura solicitada
    SET @XmlResponse = (
    SELECT
        @SERVER_ID AS 'head/server_id',
        @SERVER_TIME AS 'head/server_time',
        @EXECUTION_TIME AS 'head/execution_time',
        @URL AS 'head/url',
        @WEBMETHOD_NAME AS 'head/webmethod/name',
        (
            SELECT
                @PARAM_NAME AS 'name',
                @PARAM_VALUE AS 'value'
            FOR XML PATH('parameter'), TYPE
        ) AS 'head/webmethod/parameters',
        (
            SELECT
                @ERROR_CODE AS 'num_error',
                @ERROR_MESSAGE AS 'message_error',
                @SEVERITY AS 'severity',
                @USER_MESSAGE AS 'user_message'
            FOR XML PATH('error'), TYPE
        ) AS 'head/errors',
        (
            SELECT
                ISNULL(@UserData.query('.'), '') AS '*'
            FOR XML PATH('response_data'), TYPE
        )
    FOR XML PATH('ws_response'), TYPE
);
END
GO
USE [master]
GO
ALTER DATABASE [PP_DDBB] SET  READ_WRITE 
GO
