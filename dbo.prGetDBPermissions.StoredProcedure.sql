USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	Stored Procedure [dbo].[prGetDBPermissions]
Date: 		2023-03-24
Author: 	Charlton Julius
Notes: 		Requires DBAdmin Database, DBPermissions table
*/

CREATE PROCEDURE [dbo].[prGetDBPermissions]
AS
	BEGIN

		SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 10)) [Count]
			,[ServerName]
			,[DBName]
			,[DBPrincipal] AS 'Database Principal'
			,[SrvPrincipal] AS 'Server Principal'
			,[type_desc] AS 'Type Description'
			,[RoleMembership]
			,[DirectPermissions]
		FROM [dbo].[tDBPermission]
		ORDER BY 
			 [ServerName]
			,[DBName]
			,[DBPrincipal]

	END;

GO
