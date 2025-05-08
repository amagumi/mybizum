USE PP_DDBB;
GO

CREATE OR ALTER PROCEDURE sp_xml_error_message
    @RETURN INT,
    @XmlResponse XML OUTPUT
AS
BEGIN
    DECLARE @SERVER_ID NVARCHAR(200) = @@SERVERNAME;
    DECLARE @SERVER_TIME NVARCHAR(20) = CONVERT(NVARCHAR(20), GETDATE(), 120);
    DECLARE @ERROR_CODE INT = @RETURN;
    DECLARE @ERROR_MESSAGE NVARCHAR(200);
    DECLARE @SEVERITY INT = '';
    DECLARE @USER_MESSAGE NVARCHAR(200) = 'user message';

    -- Buscar mensaje de error
    SELECT @ERROR_MESSAGE = ERROR_MESSAGE
    FROM USER_ERRORS
    WHERE ERROR_CODE = @ERROR_CODE;

    -- Construir el bloque <head> incluyendo <Errors>
    DECLARE @XmlHead XML = (
        SELECT
            @SERVER_ID AS 'server_id',
            @SERVER_TIME AS 'server_time',
            (
                SELECT
                    @ERROR_CODE AS 'num_error',
                    @ERROR_MESSAGE AS 'message_error',
                    @SEVERITY AS 'severity',
                    @USER_MESSAGE AS 'user_message'
                FOR XML PATH('Error'), ROOT('Errors'), TYPE
            )
        FOR XML PATH('head'), TYPE
    );


	DECLARE @XmlBody XML = (
        SELECT '' AS 'response_data'
        FOR XML PATH('body'), TYPE
    );

    -- Armar XML final
    SET @XmlResponse = (
        SELECT @XmlHead,
               @XmlBody
        FOR XML PATH('ws_response'), TYPE
    );


END
