USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	Stored Procedure [dbo].[prGetJobs]
Date: 		2017-05-20
Author: 	Charlton Julius
Notes: 		Requires DBAdmin Database, InstanceList and ServerList table
*/

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
