USE [DBAdmin]
GO
/****** Object:  Table [dbo].[TableList]    Script Date: 4/5/2023 1:19:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TableList](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) NULL,
	[InstanceName] [nvarchar](128) NULL,
	[DatabaseName] [nvarchar](128) NULL,
	[SchemaName] [sysname] NULL,
	[TableName] [sysname] NOT NULL,
	[TableRows] [bigint] NULL,
	[TotalSpaceKB] [bigint] NULL,
	[TotalSpaceMB] [numeric](36, 2) NULL,
	[UsedSpaceKB] [bigint] NULL,
	[UsedSpaceMB] [numeric](36, 2) NULL,
	[UnusedSpaceKB] [bigint] NULL,
	[UnusedSpaceMB] [numeric](36, 2) NULL,
 CONSTRAINT [PK_dbo_TableList_Id] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'exp_Table_TableList', @value=N'Contains a list of all Tables.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TableList'
GO