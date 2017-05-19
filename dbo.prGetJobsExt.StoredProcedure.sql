USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	Stored Procedure [dbo].[prGetJobsExt]
Date: 		2016-02-04
Author: 	Charlton Julius
Notes: 		Requires DBAdmin Database, InstanceList, ServerList and JobList table
*/

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
