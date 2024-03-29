USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[JobList](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[InstanceListId] [bigint] NULL,
	[JobID] [uniqueidentifier] NULL,
	[JobName] [nvarchar](128) NULL,
	[JobOwner] [nvarchar](128) NULL,
	[JobCategory] [nvarchar](128) NULL,
	[JobDescription] [nvarchar](512) NULL,
	[JobIsEnabled] [varchar](3) NULL,
	[JobScheduleName] [nvarchar](128) NULL,
	[ScheduleIsEnabled] [varchar](3) NULL,
	[ScheduleType] [varchar](48) NULL,
	[Occurrence] [varchar](48) NULL,
	[Recurrence] [varchar](90) NULL,
	[Frequency] [varchar](54) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains Jobs Information for instances.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobList'
GO
