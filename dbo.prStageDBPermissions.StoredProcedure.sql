USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	Stored Procedure [dbo].[prStageDBPermissions]
Date: 		2023-03-25
Author: 	Charlton Julius
Notes: 		Requires DBAdmin Database and stage.tDBPermission table
*/

CREATE PROCEDURE [dbo].[prStageDBPermissions] (
	@ServerName [nvarchar](100) NULL,
	@DBName [sysname] NULL,
	@DBPrincipal [sysname] NULL,
	@SrvPrincipal [sysname] NULL,
	@type [char](5) NULL,
	@type_desc [nvarchar](100) NULL,
	@RoleMembership [nvarchar](max) NULL,
	@DirectPermissions [nvarchar](max) NULL
)
AS
	BEGIN

	INSERT INTO [stage].[tDBPermission]
           ([ServerName]
           ,[DBName]
           ,[DBPrincipal]
           ,[SrvPrincipal]
           ,[type]
           ,[type_desc]
           ,[RoleMembership]
           ,[DirectPermissions])
     VALUES
           (@ServerName
           ,@DBName 
           ,@DBPrincipal
           ,@SrvPrincipal
           ,@type
           ,@type_desc
           ,@RoleMembership
           ,@DirectPermissions)

	END;
GO
