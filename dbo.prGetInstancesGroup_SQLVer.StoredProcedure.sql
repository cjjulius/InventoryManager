USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	Stored Procedure [dbo].[prGetInstancesGroup_SQLVer]
Date: 		2016-11-14
Author: 	Charlton Julius
Notes: 		Reporting - Requires DBAdmin Database, vwGetInstancesGroup_SQLVer view and InstanceList table
*/

CREATE PROCEDURE [dbo].[prGetInstancesGroup_SQLVer]
AS
	SET NOCOUNT ON;

	BEGIN

		SELECT	[v].[ServerVersion]
			   ,COUNT(*) AS [NumberOfInstances]
		FROM	[dbo].[InstanceList] AS [il]
		INNER JOIN [Reports].[vwGetInstancesGroup_SQLVer] AS [v] ( NOLOCK ) ON [v].[Id] = [il].[Id]
		GROUP BY [v].[ServerVersion]
		ORDER BY [v].[ServerVersion];
	END;




GO
