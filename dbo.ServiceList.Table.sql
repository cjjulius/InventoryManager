USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServiceList](
	[Id] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ServerListId] [bigint] NOT NULL,
	[ServerName] [varchar](max) NOT NULL,
	[ServiceDisplayName] [varchar](max) NOT NULL,
	[ServiceName] [varchar](max) NOT NULL,
	[ServiceState] [varchar](max) NOT NULL,
	[ServiceStartMode] [varchar](max) NOT NULL,
	[ServiceStartName] [varchar](max) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'exp_Table_ServiceList', @value=N'Contains a list of all Services.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ServiceList'
GO
