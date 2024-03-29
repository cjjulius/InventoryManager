USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DatabaseList](
	[Id] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[DatabaseName] [varchar](max) NOT NULL,
	[InstanceListId] [bigint] NOT NULL,
	[database_owner] [nvarchar](256) NULL,
	[recovery_model] [nvarchar](60) NULL,
	[compatibility_level] [int] NULL,
	[is_query_store_on] [bit] NULL,
	[is_encrypted] [bit] NULL,
	[is_auto_close_on] [bit] NULL,
	[is_auto_shrink_on] [bit] NULL,
	[state_desc] [nvarchar](60) NULL,
	[snapshot_isolation_state_desc] [nvarchar](60) NULL,
	[is_read_committed_snapshot_on] [bit] NULL,
	[page_verify_option_desc] [nvarchar](60) NULL,
	[is_auto_create_stats_on] [bit] NULL,
	[SizeInMB] [int] NULL,
 CONSTRAINT [PK_dbo_DatabaseList_Id] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'exp_Table_DatabaseList', @value=N'Contains a list of all databases and properties.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DatabaseList'
GO
