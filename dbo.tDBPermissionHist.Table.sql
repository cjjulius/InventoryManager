USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tDBPermissionHist](
	[id] [bigint] NOT NULL,
	[ServerName] [nvarchar](100) NULL,
	[DBName] [sysname] NULL,
	[DBPrincipal] [sysname] NULL,
	[SrvPrincipal] [sysname] NULL,
	[type] [char](5) NULL,
	[type_desc] [nvarchar](100) NULL,
	[RoleMembership] [nvarchar](max) NULL,
	[DirectPermissions] [nvarchar](max) NULL,
	[RowHash] [varbinary](8000) NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'exp_Table_tDBPermissionHist', @value=N'Contains history of all DB Permissions.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tDBPermissionHist'
GO