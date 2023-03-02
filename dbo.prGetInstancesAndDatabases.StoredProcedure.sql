USE [DBAdmin]
GO

/****** Object:  StoredProcedure [dbo].[prGetInstancesAndDatabases]    Script Date: 3/1/2023 2:52:19 PM ******/
DROP PROCEDURE [dbo].[prGetInstancesAndDatabases]
GO

/****** Object:  StoredProcedure [dbo].[prGetInstancesAndDatabases]    Script Date: 3/1/2023 2:52:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*
Object:  	Stored Procedure [dbo].[prGetInstancesAndDatabases]
Date: 		2016-11-14
Author: 	Charlton Julius
Notes: 		Reporting - Requires DBAdmin Database, DatabaseList table, InstanceList table and ServerList table
*/

CREATE PROCEDURE [dbo].[prGetInstancesAndDatabases]
AS
	BEGIN

		SELECT [sl].[ServerName]
				,[il].[InstanceName]
			   ,[il].[MSSQLVersion]
			   ,[il].[MSSQLEdition]
			   ,[il].[MSSQLServicePack]
			   ,[il].[MSSQLCU]
			   ,[dl].[DatabaseName]
			   ,(CASE WHEN dl.SizeinMB > 1000
					THEN
					CAST(ROUND(CEILING(CAST(dl.SizeInMB AS FLOAT) / 1000), 0) AS INT)
					ELSE
					0
					END) AS [SizeInGB]
				,dl.SizeInMB
		FROM	[dbo].[InstanceList] AS [il]
		INNER JOIN [dbo].[DatabaseList] AS [dl] (NOLOCK) ON dl.[InstanceListId] = [il].[Id]
		INNER JOIN [dbo].[ServerList] AS [sl] (NOLOCK) ON [sl].[Id] = [il].[ServerListId]
		ORDER BY [sl].[ServerName] 
				,[il].[InstanceName]
				,[dl].[DatabaseName];
	END;


GO


