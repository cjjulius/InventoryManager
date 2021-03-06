/*

Upgrade to 2.1 from 2.3 - May error on first run but can run multiple times afterwards.

*/


USE [DBAdmin]
GO
EXEC sys.sp_dropextendedproperty @name=N'MS_Description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobList'

GO
EXEC sys.sp_dropextendedproperty @name=N'exp_Table_InstanceList' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InstanceList'

GO
/****** Object:  StoredProcedure [dbo].[prUpdateInstanceList]    Script Date: 2017-05-19 14:44:26 ******/
DROP PROCEDURE [dbo].[prUpdateInstanceList]
GO
/****** Object:  StoredProcedure [dbo].[prInsertJobList]    Script Date: 2017-05-19 14:44:26 ******/
DROP PROCEDURE [dbo].[prInsertJobList]
GO
/****** Object:  StoredProcedure [dbo].[prGetServersAndInstances]    Script Date: 2017-05-19 14:44:26 ******/
DROP PROCEDURE [dbo].[prGetServersAndInstances]
GO
/****** Object:  StoredProcedure [dbo].[prGetJobsExt]    Script Date: 2017-05-19 14:44:26 ******/
DROP PROCEDURE [dbo].[prGetJobsExt]
GO
/****** Object:  StoredProcedure [dbo].[prGetJobs]    Script Date: 2017-05-19 14:44:26 ******/
DROP PROCEDURE [dbo].[prGetJobs]
GO
/****** Object:  StoredProcedure [dbo].[prGetInventory]    Script Date: 2017-05-19 14:44:26 ******/
DROP PROCEDURE [dbo].[prGetInventory]
GO
/****** Object:  StoredProcedure [dbo].[prGetInstances]    Script Date: 2017-05-19 14:44:26 ******/
DROP PROCEDURE [dbo].[prGetInstances]
GO
/****** Object:  Table [dbo].[JobList]    Script Date: 2017-05-19 14:44:26 ******/
DROP TABLE [dbo].[JobList]
GO
/****** Object:  Table [dbo].[InstanceList]    Script Date: 2017-05-19 14:44:26 ******/
DROP TABLE [dbo].[InstanceList]
GO
/****** Object:  Table [dbo].[InstanceList]    Script Date: 2017-05-19 14:44:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InstanceList](
	[Id] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[InstanceName] [varchar](max) NOT NULL,
	[ServerListId] [bigint] NOT NULL,
	[MSSQLVersion] [varchar](max) NULL,
	[MSSQLVersionLong] [varchar](max) NULL,
	[MSSQLServicePack] [varchar](20) NULL,
	[MSSQLEdition] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[JobList]    Script Date: 2017-05-19 14:44:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  StoredProcedure [dbo].[prGetInstances]    Script Date: 2017-05-19 14:44:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	Stored Procedure [dbo].[prGetInstances]
Date: 		2016-02-04
Author: 	Charlton Julius
Notes: 		Requires DBAdmin Database, InstanceList table
*/

CREATE PROCEDURE [dbo].[prGetInstances]
AS
    BEGIN

        SELECT  ROW_NUMBER() OVER (ORDER BY (SELECT 10)) AS [InstanceCount]
				,il.InstanceName
               ,il.MSSQLVersion
               ,il.MSSQLServicePack
               ,il.MSSQLEdition
               ,il.MSSQLVersionLong
        FROM    dbo.InstanceList AS il
        ORDER BY il.InstanceName;
    END;



GO
/****** Object:  StoredProcedure [dbo].[prGetInventory]    Script Date: 2017-05-19 14:44:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	Stored Procedure [dbo].[prGetInventory]
Date: 		2016-02-04
Author: 	Charlton Julius
Notes: 		Requires DBAdmin Database, DatabaseList, ServerList and InstanceList tables
*/

CREATE PROCEDURE [dbo].[prGetInventory]
AS
	BEGIN

		SELECT	[sl].[ServerName]
			  ,[sl].[IPAddress]
			  ,[sl].[OSName]
			  ,[sl].[OSServicePack]
			  ,[il].[InstanceName]
			  ,[il].[MSSQLVersion]
			  ,[il].[MSSQLServicePack]
			  ,[il].[MSSQLEdition]
			  ,[il].[MSSQLVersionLong]
			  ,[jl].[JobID]
		      ,[jl].[JobName]
		      ,[jl].[JobOwner]
		      ,[jl].[JobCategory]
		      ,[jl].[JobDescription]
		      ,[jl].[JobIsEnabled]
		      ,[jl].[JobScheduleName]
		      ,[jl].[ScheduleIsEnabled]
		      ,[jl].[ScheduleType]
		      ,[jl].[Occurrence]
		      ,[jl].[Recurrence]
		      ,[jl].[Frequency]
			  ,[dl].[DatabaseName]
			  ,( CASE WHEN [dl].[SizeInMB] > 1000
					   THEN CAST(ROUND(CEILING(CAST([dl].[SizeInMB] AS FLOAT)
											   / 1000), 0) AS INT)
					   ELSE 0
				  END ) AS [SizeInGB]
			  ,[dl].[SizeInMB]
		FROM	[dbo].[ServerList] AS [sl]
		INNER JOIN [dbo].[InstanceList] AS [il] ( NOLOCK ) ON [il].[ServerListId] = [sl].[Id]
		LEFT JOIN [dbo].[DatabaseList] AS [dl] ( NOLOCK ) ON [dl].[InstanceListId] = [il].[Id]
		INNER JOIN [dbo].[JobList] AS [jl] ( NOLOCK ) ON [jl].[InstanceListId] = [il].[Id]
		ORDER BY [sl].[Id]
			   ,[il].[Id]
			   ,[dl].[Id];
	END;



GO
/****** Object:  StoredProcedure [dbo].[prGetJobs]    Script Date: 2017-05-19 14:44:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[prGetJobs]
AS
	BEGIN

		SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 10)) [Count]
				,[sl].[ServerName]
			  ,[il].[InstanceName]
		      ,[JobName]
		      ,[JobIsEnabled]
		      ,[JobScheduleName]
		      ,[ScheduleIsEnabled]
		      ,[ScheduleType]
		      ,[Occurrence]
		      ,[Recurrence]
		      ,[Frequency]
		FROM [dbo].[JobList] [jl]
		INNER JOIN dbo.[InstanceList] AS [il] (NOLOCK) ON [il].[Id] = [jl].[InstanceListId]
		INNER JOIN dbo.[ServerList] AS [sl] ON [sl].[Id] = [il].[ServerListId]
		ORDER BY [sl].[ServerName]

	END;



GO
/****** Object:  StoredProcedure [dbo].[prGetJobsExt]    Script Date: 2017-05-19 14:44:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[prGetJobsExt]
AS
	BEGIN

		SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 10)) [Count]
				,[sl].[ServerName]
			  ,[il].[InstanceName]
		      ,[jl].[JobName]
			  ,[jl].[JobIsEnabled]
		      ,[jl].[ScheduleIsEnabled]
		      ,[jl].[JobDescription]
			  
		FROM [dbo].[JobList] [jl]
		INNER JOIN dbo.[InstanceList] AS [il] (NOLOCK) ON [il].[Id] = [jl].[InstanceListId]
		INNER JOIN dbo.[ServerList] AS [sl] ON [sl].[Id] = [il].[ServerListId]
		ORDER BY [sl].[ServerName]

	END;



GO
/****** Object:  StoredProcedure [dbo].[prGetServersAndInstances]    Script Date: 2017-05-19 14:44:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	Stored Procedure [dbo].[prGetServersAndInstances]
Date: 		2016-11-14
Author: 	Charlton Julius
Notes: 		Reporting - Requires DBAdmin Database, InstanceList table and ServerList table
*/

CREATE PROCEDURE [dbo].[prGetServersAndInstances]
AS
	BEGIN

		SELECT	[sl].[ServerName]
			   ,[il].[InstanceName]
			   ,[il].[MSSQLVersion]
			   ,[il].[MSSQLEdition]
			   ,[il].[MSSQLServicePack]
		FROM	[dbo].[InstanceList] AS [il]
		INNER JOIN [dbo].[ServerList] AS [sl] ( NOLOCK ) ON [sl].[Id] = [il].[ServerListId]
		ORDER BY [sl].[ServerName]
			   ,[il].[InstanceName];
	END;




GO
/****** Object:  StoredProcedure [dbo].[prInsertJobList]    Script Date: 2017-05-19 14:44:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[prInsertJobList] (
	@InstanceListId BIGINT
	,@JobID UNIQUEIDENTIFIER
	,@JobName NVARCHAR(128)
	,@JobOwner NVARCHAR(128)
	,@JobCategory NVARCHAR(128)
	,@JobDescription NVARCHAR(512)
	,@JobIsEnabled VARCHAR(3)
	--,@JobCreatedOn DATETIME
	--,@JobLastModifiedOn DATETIME
	--,@JobStartStepNo INT
	--,@JobStartStepName NVARCHAR(128)
	--,@IsScheduled VARCHAR(3)
	,@JobScheduleName NVARCHAR(128)
	,@ScheduleIsEnabled VARCHAR(3)
	,@ScheduleType VARCHAR(48)
	,@Occurrence VARCHAR(48)
	,@Recurrence VARCHAR(90)
	,@Frequency VARCHAR(54)
	--,@ScheduleUsageStartDate VARCHAR(10)
	--,@ScheduleUsageEndDate VARCHAR(10)
)
AS
    BEGIN

INSERT INTO [dbo].[JobList]
		(
		 [InstanceListId]
		,[JobID]
		,[JobName]
		,[JobOwner]
		,[JobCategory]
		,[JobDescription]
		,[JobIsEnabled]
		--,[JobCreatedOn]
		--,[JobLastModifiedOn]
		--,[JobStartStepNo]
		--,[JobStartStepName]
		--,[IsScheduled]
		,[JobScheduleName]
		,[ScheduleIsEnabled]
		,[ScheduleType]
		,[Occurrence]
		,[Recurrence]
		,[Frequency]
		--,[ScheduleUsageStartDate]
		--,[ScheduleUsageEndDate]
		)
		VALUES
		(
		@InstanceListId 
		,@JobID 
		,@JobName 
		,@JobOwner 
		,@JobCategory 
		,@JobDescription 
		,@JobIsEnabled 
		--,@JobCreatedOn 
		--,@JobLastModifiedOn 
		--,@JobStartStepNo 
		--,@JobStartStepName 
		--,@IsScheduled 
		,@JobScheduleName 
		,@ScheduleIsEnabled 
		,@ScheduleType 
		,@Occurrence 
		,@Recurrence 
		,@Frequency 
		--,@ScheduleUsageStartDate 
		--,@ScheduleUsageEndDate 
		)
    END;





GO
/****** Object:  StoredProcedure [dbo].[prUpdateInstanceList]    Script Date: 2017-05-19 14:44:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	Stored Procedure [dbo].[prUpdateInstanceList]
Date: 		2016-02-04
Author: 	Charlton Julius
Notes: 		Requires DBAdmin Database, InstanceList table
*/

CREATE PROCEDURE [dbo].[prUpdateInstanceList](

	 @MSSQLVersionLong VARCHAR(MAX)
	,@MSSQLVersion VARCHAR(MAX)
	,@MSSQLEdition VARCHAR(MAX)
	,@MSSQLServicePack VARCHAR(20)
	,@InstanceId BIGINT
)
AS
    BEGIN

        UPDATE dbo.InstanceList
		SET MSSQLVersionLong = @MSSQLVersionLong
			,MSSQLVersion = @MSSQLVersion
			,MSSQLEdition = @MSSQLEdition
			,MSSQLServicePack = @MSSQLServicePack
		WHERE Id = @InstanceID	
    END;



GO
EXEC sys.sp_addextendedproperty @name=N'exp_Table_InstanceList', @value=N'Contains a list of all Instances.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InstanceList'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains Jobs Information for instances.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'JobList'
GO
