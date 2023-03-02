USE [DBAdmin]
GO

/****** Object:  StoredProcedure [dbo].[prGetServersAndInstances]    Script Date: 3/1/2023 2:44:29 PM ******/
DROP PROCEDURE [dbo].[prGetServersAndInstances]
GO

/****** Object:  StoredProcedure [dbo].[prGetServersAndInstances]    Script Date: 3/1/2023 2:44:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*
Object:  	Stored Procedure [dbo].[prGetServersAndInstances]
Date: 		2016-11-14
Author: 	Charlton Julius
Notes: 		Reporting - Requires DBAdmin Database, InstanceList table and ServerList table
*/

CREATE PROCEDURE [dbo].[prGetServersAndInstances]
AS
	BEGIN

		SELECT	[sl].[ServerName]
			   ,[il].[InstanceName]
			   ,[il].[MSSQLVersion]
			   ,[il].[MSSQLEdition]
			   ,[il].[MSSQLServicePack]
			   ,[il].[MSSQLCU]
		FROM	[dbo].[InstanceList] AS [il]
		INNER JOIN [dbo].[ServerList] AS [sl] ( NOLOCK ) ON [sl].[Id] = [il].[ServerListId]
		ORDER BY [sl].[ServerName]
			   ,[il].[InstanceName];
	END;


GO


