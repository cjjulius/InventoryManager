USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tSrvPermission](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](100) NULL,
	[SrvPrincipal] [sysname] NULL,
	[type] [char](5) NULL,
	[type_desc] [nvarchar](100) NULL,
	[is_disabled] [int] NULL,
	[RoleMembership] [sysname] NULL,
	[DirectPermissions] [nvarchar](256) NULL,
	[RowHash] [varbinary](8000) NOT NULL,
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_dbo_tSrvPermission_Id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[tSrvPermissionHist])
)
GO

EXEC sys.sp_addextendedproperty @name=N'exp_Table_tSrvPermission', @value=N'Contains list of all Server Permissions.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tSrvPermission'
GO