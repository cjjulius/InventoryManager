USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [stage].[tSrvPermission](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](100) NULL,
	[SrvPrincipal] [sysname] NULL,
	[type] [char](5) NULL,
	[type_desc] [nvarchar](100) NULL,
	[is_disabled] [int] NULL,
	[RoleMembership] [sysname] NULL,
	[DirectPermissions] [nvarchar](256) NULL,
	[RowHash]  AS (hashbytes('SHA2_256',concat([ServerName],[SrvPrincipal]))) PERSISTED
) ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'exp_Table_tDBPermission', @value=N'Stages Server Permissions.' , @level0type=N'SCHEMA',@level0name=N'stage', @level1type=N'TABLE',@level1name=N'tSrvPermission'
GO