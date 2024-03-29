USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Object:  	Stored Procedure [dbo].[prGetInventory]
Updated:	2023-03-30
Author: 	Charlton Julius
Notes: 		Requires DBAdmin Database, DatabaseList, ServerList 
			TableList and InstanceList tables
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
				  END )					AS 'SizeInGB'
			  ,[dl].[SizeInMB]
			  ,[tl].[SchemaName]
			  ,[tl].[TableName]
			  ,[tl].[TableRows]
			  ,[tl].[TotalSpaceMB]		AS 'TableTotalSpaceMB'
		FROM	[dbo].[ServerList]			AS [sl]
		INNER JOIN	[dbo].[InstanceList]	AS [il] ( NOLOCK )	ON [il].[ServerListId]		= [sl].[Id]
		LEFT JOIN	[dbo].[DatabaseList]	AS [dl] ( NOLOCK )	ON [dl].[InstanceListId]	= [il].[Id]
		INNER JOIN	[dbo].[JobList]			AS [jl] ( NOLOCK )	ON [jl].[InstanceListId]	= [il].[Id]
		INNER JOIN	[dbo].[TableList]		AS [tl] ( NOLOCK )	ON [tl].[ServerName]		= [sl].[ServerName]
																	AND [tl].[DatabaseName] = [dl].[DatabaseName]
		ORDER BY [sl].[Id]
			   ,[il].[Id]
			   ,[dl].[Id]
			   ,[tl].[SchemaName]
			   ,[tl].[TableName];
	END;

GO
