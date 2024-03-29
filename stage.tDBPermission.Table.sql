USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [stage].[tDBPermission](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](100) NULL,
	[DBName] [sysname] NULL,
	[DBPrincipal] [sysname] NULL,
	[SrvPrincipal] [sysname] NULL,
	[type] [char](5) NULL,
	[type_desc] [nvarchar](100) NULL,
	[RoleMembership] [nvarchar](max) NULL,
	[DirectPermissions] [nvarchar](max) NULL,
	[RowHash]  AS (hashbytes('SHA2_256',concat([ServerName],[DBName],[DBPrincipal],[SrvPrincipal]))) PERSISTED
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'exp_Table_tDBPermission', @value=N'Stages  DB Permissions.' , @level0type=N'SCHEMA',@level0name=N'stage', @level1type=N'TABLE',@level1name=N'tDBPermission'
GO