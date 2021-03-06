USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[InstanceList](
	[Id] [BIGINT] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[InstanceName] [VARCHAR](MAX) NOT NULL,
	[ServerListId] [BIGINT] NOT NULL,
	[MSSQLVersion] [VARCHAR](MAX) NULL,
	[MSSQLVersionLong] [VARCHAR](MAX) NULL,
	[MSSQLServicePack] [VARCHAR](20) NULL,
	[MSSQLEdition] [VARCHAR](MAX) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

EXEC sys.sp_addextendedproperty @name=N'exp_Table_InstanceList', @value=N'Contains a list of all Instances.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InstanceList'
GO
