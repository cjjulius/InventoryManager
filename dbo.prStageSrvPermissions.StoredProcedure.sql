USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	Stored Procedure [dbo].[prStageSrvPermissions]
Date: 		2023-03-25
Author: 	Charlton Julius
Notes: 		Requires DBAdmin Database and stage.tSrvPermission table
*/

CREATE PROCEDURE [dbo].[prStageSrvPermissions] (
	 @ServerName [nvarchar](100) NULL
	,@SrvPrincipal [sysname] NULL
	,@type [char](5) NULL
	,@type_desc [nvarchar](100) NULL
	,@is_disabled [int] NULL
	,@RoleMembership [sysname] NULL
	,@DirectPermissions [nvarchar](256) NULL
)
AS
	BEGIN

	INSERT INTO [stage].[tSrvPermission]
           ( [ServerName]
		   	,[SrvPrincipal]
		   	,[type]
		   	,[type_desc]
		   	,[is_disabled]
		   	,[RoleMembership]
			,[DirectPermissions])
     VALUES
           (@ServerName
		   ,@SrvPrincipal
		   ,@type
		   ,@type_desc
		   ,@is_disabled
		   ,@RoleMembership
		   ,@DirectPermissions)

	END;
GO
