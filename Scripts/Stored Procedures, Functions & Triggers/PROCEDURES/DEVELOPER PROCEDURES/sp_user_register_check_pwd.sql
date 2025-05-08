USE [PP_DDBB]
GO
/** Object:  StoredProcedure [dbo].[sp_user_register_check_pwd]    Script Date: 18/02/2025 18:24:36 **/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_user_register_check_pwd](@PASSWORD NVARCHAR(100))
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