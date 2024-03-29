USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	View [dbo].[vwGetInstancesGroup_SQLVer]
Date: 		2016-11-14
Author: 	Charlton Julius
Notes: 		Reporting - Requires DBAdmin Database and InstanceList table
*/

CREATE VIEW [Reports].[vwGetInstancesGroup_SQLVer]
AS
	( SELECT	[il].[Id]
			   ,REPLACE(REPLACE(LEFT([il].[MSSQLVersionLong], 28), ' - ', ''),
						' (S', '') AS [ServerVersion]
		FROM	[dbo].[InstanceList] AS [il]
	);

GO
