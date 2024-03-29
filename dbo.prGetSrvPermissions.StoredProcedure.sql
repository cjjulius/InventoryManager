USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	Stored Procedure [dbo].[prGetSrvPermissions]
Date: 		2023-03-24
Author: 	Charlton Julius
Notes: 		Requires DBAdmin Database, SrvPermission table
*/

CREATE PROCEDURE [dbo].[prGetSrvPermissions]
AS
	BEGIN

	SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 10)) [Count]
		,[ServerName]
		,[SrvPrincipal]		AS 'Server Principal'
		,[type_desc]		AS 'Type Description'
		,CASE [is_disabled]
			WHEN 1 THEN 'Yes'
			ELSE 'No'
		 END				AS 'Disabled?'
		,[RoleMembership]
		,[DirectPermissions]
	FROM [dbo].[tSrvPermission]
	ORDER BY
		 [ServerName]
		,[SrvPrincipal]

	END;

GO
