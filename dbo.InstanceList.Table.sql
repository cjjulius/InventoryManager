USE [DBAdmin]
GO

EXEC sys.sp_dropextendedproperty @name=N'exp_Table_InstanceList' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InstanceList'
GO

/****** Object:  Table [dbo].[InstanceList]    Script Date: 3/1/2023 2:21:17 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InstanceList]') AND type in (N'U'))
DROP TABLE [dbo].[InstanceList]
GO

/****** Object:  Table [dbo].[InstanceList]    Script Date: 3/1/2023 2:21:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[InstanceList](
	[Id] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[InstanceName] [varchar](max) NOT NULL,
	[ServerListId] [bigint] NOT NULL,
	[MSSQLVersion] [varchar](max) NULL,
	[MSSQLVersionLong] [varchar](max) NULL,
	[MSSQLServicePack] [varchar](20) NULL,
	[MSSQLEdition] [varchar](max) NULL,
	[MSSQLCU] [varchar](max) NULL
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'exp_Table_InstanceList', @value=N'Contains a list of all Instances.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InstanceList'
GO


