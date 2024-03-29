USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	Stored Procedure [dbo].[prGetServerNames] 
Date: 		2016-02-04
Author: 	Charlton Julius
Notes: 		Requires DBAdmin Database, ServerList table
*/

CREATE PROCEDURE [dbo].[prGetServerNames] 

AS
    BEGIN

	SELECT sl.ServerName 
	FROM dbo.ServerList AS sl;

    END;



GO
