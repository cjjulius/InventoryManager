USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	Stored Procedure [dbo].[prGetServers]
Date: 		2016-02-04
Author: 	Charlton Julius
Notes: 		Requires DBAdmin Database, ServerList table
*/

CREATE PROCEDURE [dbo].[prGetServers]
AS
    BEGIN
        SELECT   ROW_NUMBER() OVER (ORDER BY (SELECT 10)) AS [ServerCount]
				,sl.ServerName
				,sl.OSName
				,sl.OSServicePack
        FROM    dbo.ServerList AS sl
        ORDER BY sl.ServerName;
    END;


GO
