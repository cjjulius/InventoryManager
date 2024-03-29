USE [DBAdmin]
GO
/****** Object:  Table [dbo].[tDBPermission]    Script Date: 4/5/2023 1:19:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tDBPermission](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](100) NULL,
	[DBName] [sysname] NULL,
	[DBPrincipal] [sysname] NULL,
	[SrvPrincipal] [sysname] NULL,
	[type] [char](5) NULL,
	[type_desc] [nvarchar](100) NULL,
	[RoleMembership] [nvarchar](max) NULL,
	[DirectPermissions] [nvarchar](max) NULL,
	[RowHash] [varbinary](8000) NOT NULL,
	[ValidFrom] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[ValidTo] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_dbo_tDBPermission_Id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[tDBPermissionHist])
)
GO

EXEC sys.sp_addextendedproperty @name=N'exp_Table_tDBPermission', @value=N'Contains a list of all DB Permissions.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tDBPermission'
GO