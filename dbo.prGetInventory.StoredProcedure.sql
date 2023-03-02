USE [DBAdmin]
GO

/*
Object:  	Stored Procedure [dbo].[prGetInventory]
Date: 		2023-03-01
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
			  ,[il].[MSSQLCU]
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


