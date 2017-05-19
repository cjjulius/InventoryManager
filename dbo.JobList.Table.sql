USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[JobList](
	[Id] [BIGINT] IDENTITY(1,1) NOT NULL,
	[InstanceListId] [BIGINT] NULL,
	[JobID] [UNIQUEIDENTIFIER] NULL,
	[JobName] [NVARCHAR](128) NULL,
	[JobOwner] [NVARCHAR](128) NULL,
	[JobCategory] [NVARCHAR](128) NULL,
	[JobDescription] [NVARCHAR](512) NULL,
	[JobIsEnabled] [VARCHAR](3) NULL,
	[JobScheduleName] [NVARCHAR](128) NULL,
	[ScheduleIsEnabled] [VARCHAR](3) NULL,
	[ScheduleType] [VARCHAR](48) NULL,
	[Occurrence] [VARCHAR](48) NULL,
	[Recurrence] [VARCHAR](90) NULL,
	[Frequency] [VARCHAR](54) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains Jobs Information for instances.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobList'
GO


