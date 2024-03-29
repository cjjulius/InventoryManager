USE [DBAdmin]
GO
/****** Object:  Table [dbo].[tSrvPermissionHist]    Script Date: 4/5/2023 1:19:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tSrvPermissionHist](
	[id] [bigint] NOT NULL,
	[ServerName] [nvarchar](100) NULL,
	[SrvPrincipal] [sysname] NULL,
	[type] [char](5) NULL,
	[type_desc] [nvarchar](100) NULL,
	[is_disabled] [int] NULL,
	[RoleMembership] [sysname] NULL,
	[DirectPermissions] [nvarchar](256) NULL,
	[RowHash] [varbinary](8000) NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'exp_Table_tSrvPermissionHist', @value=N'Contains history of all Server Permissions.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tSrvPermissionHist'
GO