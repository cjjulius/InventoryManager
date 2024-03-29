USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Object:  	Stored Procedure [dbo].[prGetServersGroup_OS_SP]
Date: 		2016-11-14
Author: 	Charlton Julius
Notes: 		Reporting - Requires DBAdmin Database and ServerList table
*/

CREATE PROCEDURE [dbo].[prGetServersGroup_OS_SP]
AS
	SET NOCOUNT ON;

	BEGIN

		SELECT	[sl].[OSName]
			   ,[sl].[OSServicePack]
			   ,COUNT(*) AS [NumberOfServers]
		FROM	[dbo].[ServerList] AS [sl]
		WHERE	[sl].[OSServicePack] IS NOT NULL
		GROUP BY [sl].[OSName]
			   ,[sl].[OSServicePack]
		ORDER BY [sl].[OSName];
	END;

GO
