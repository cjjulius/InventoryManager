USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Reports].[vwGetServers_Instances_SQLVersion_Instance_FullList]
AS

/*
Object:  	View [dbo].[vwGetServers_Instances_SQLVersion_Instance_FullList]
Date: 		2016-11-14
Author: 	Charlton Julius
Notes: 		Reporting - Requires DBAdmin Database, vwGetInstancesGroup_SQLVer view, InstanceList table and ServerList table
*/

	SELECT TOP 1000
			[sl].[ServerName]
		   ,[il].[InstanceName]
		   ,[vwsigsv].[ServerVersion] AS [SQL Server Version]
		   ,[il].[MSSQLVersion]
		   ,[il].[MSSQLEdition]
	FROM	[Reports].[vwGetInstancesGroup_SQLVer] [vwsigsv]
	INNER JOIN [dbo].[InstanceList] AS [il] ( NOLOCK ) ON [il].[Id] = [vwsigsv].[Id]
	INNER JOIN [dbo].[ServerList] AS [sl] ( NOLOCK ) ON [sl].[Id] = [il].[ServerListId]
	ORDER BY [ServerName]
		   ,[il].[InstanceName];
GO
