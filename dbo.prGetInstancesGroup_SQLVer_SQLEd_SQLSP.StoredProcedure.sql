USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	Stored Procedure [dbo].[prGetInstancesGroup_SQLVer_SQLEd_SQLSP]
Date: 		2023-03-01
Author: 	Charlton Julius
Notes: 		Reporting - Requires DBAdmin Database, InstanceList table and Reporting View
*/

CREATE PROCEDURE [dbo].[prGetInstancesGroup_SQLVer_SQLEd_SQLSP]
AS
	SET NOCOUNT ON;

	BEGIN

		SELECT	[v].[ServerVersion]
			   ,[il].[MSSQLEdition]
			   ,[il].[MSSQLServicePack]
			   ,[il].[MSSQLCU]
			   ,COUNT(*) AS [NumberOfInstances]
		FROM	[dbo].[InstanceList] AS [il]
		INNER JOIN [Reports].[vwGetInstancesGroup_SQLVer] AS [v] ( NOLOCK ) ON [v].[Id] = [il].[Id]
		GROUP BY [v].[ServerVersion]
			   ,[il].[MSSQLEdition]
			   ,[il].[MSSQLServicePack]
			   ,[il].[MSSQLCU]
		ORDER BY [v].[ServerVersion]
			   ,[il].[MSSQLEdition]
			   ,[il].[MSSQLServicePack]
			   ,[il].[MSSQLCU];
	END;




GO


