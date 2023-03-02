USE [DBAdmin]
GO


PRINT '[dbo].[prGetInstances]'
GO

DROP PROCEDURE [dbo].[prGetInstances]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	Stored Procedure [dbo].[prGetInstances]
Date: 		2023-03-01
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
			   ,il.MSSQLCU
               ,il.MSSQLEdition
               ,il.MSSQLVersionLong
        FROM    dbo.InstanceList AS il
        ORDER BY il.InstanceName;
    END;

GO



PRINT '[dbo].[InstanceList]'
GO

EXEC sys.sp_dropextendedproperty @name=N'exp_Table_InstanceList' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'InstanceList'
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InstanceList]') AND type in (N'U'))
DROP TABLE [dbo].[InstanceList]
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


PRINT '[dbo].[prUpdateInstanceList]'
GO

DROP PROCEDURE [dbo].[prUpdateInstanceList]
GO

/*
Object:  	Stored Procedure [dbo].[prUpdateInstanceList]
Date: 		2023-03-01
Author: 	Charlton Julius
Notes: 		Requires DBAdmin Database, InstanceList table
*/

CREATE PROCEDURE [dbo].[prUpdateInstanceList](

	 @MSSQLVersionLong VARCHAR(MAX)
	,@MSSQLVersion VARCHAR(MAX)
	,@MSSQLEdition VARCHAR(MAX)
	,@MSSQLServicePack VARCHAR(20)
	,@InstanceId BIGINT
	,@MSSQLCU VARCHAR(MAX)
)
AS
    BEGIN

        UPDATE dbo.InstanceList
		SET MSSQLVersionLong = @MSSQLVersionLong
			,MSSQLVersion = @MSSQLVersion
			,MSSQLEdition = @MSSQLEdition
			,MSSQLServicePack = @MSSQLServicePack
			,MSSQLCU = @MSSQLCU
		WHERE Id = @InstanceID	
    END;
    
GO


PRINT '[dbo].[prGetServersAndInstances]'
GO

DROP PROCEDURE [dbo].[prGetServersAndInstances]
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
			   ,[il].[MSSQLCU]
		FROM	[dbo].[InstanceList] AS [il]
		INNER JOIN [dbo].[ServerList] AS [sl] ( NOLOCK ) ON [sl].[Id] = [il].[ServerListId]
		ORDER BY [sl].[ServerName]
			   ,[il].[InstanceName];
	END;


GO


PRINT '[dbo].[prGetInventory]'
GO

DROP PROCEDURE [dbo].[prGetInventory]
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


PRINT '[dbo].[prGetInstancesGroup_SQLVer_SQLEd_SQLSP]'
GO

DROP PROCEDURE [dbo].[prGetInstancesGroup_SQLVer_SQLEd_SQLSP]
GO

/*
Object:  	Stored Procedure [dbo].[prGetInstancesGroup_SQLVer_SQLEd_SQLSP]
Date: 		2023-03-01
Author: 	Charlton Julius
Notes: 		Reporting - Requires DBAdmin Database, InstanceList table and Reporting View
*/

CREATE PROCEDURE [dbo].[prGetInstancesGroup_SQLVer_SQLEd_SQLSP]
AS
	SET NOCOUNT ON;

	BEGIN

		SELECT	[v].[ServerVersion]
			   ,[il].[MSSQLEdition]
			   ,[il].[MSSQLServicePack]
			   ,[il].[MSSQLCU]
			   ,COUNT(*) AS [NumberOfInstances]
		FROM	[dbo].[InstanceList] AS [il]
		INNER JOIN [Reports].[vwGetInstancesGroup_SQLVer] AS [v] ( NOLOCK ) ON [v].[Id] = [il].[Id]
		GROUP BY [v].[ServerVersion]
			   ,[il].[MSSQLEdition]
			   ,[il].[MSSQLServicePack]
			   ,[il].[MSSQLCU]
		ORDER BY [v].[ServerVersion]
			   ,[il].[MSSQLEdition]
			   ,[il].[MSSQLServicePack]
			   ,[il].[MSSQLCU];
	END;




GO



PRINT '[dbo].[prGetInstancesAndDatabases]'
GO

DROP PROCEDURE [dbo].[prGetInstancesAndDatabases]
GO

/*
Object:  	Stored Procedure [dbo].[prGetInstancesAndDatabases]
Date: 		2016-11-14
Author: 	Charlton Julius
Notes: 		Reporting - Requires DBAdmin Database, DatabaseList table, InstanceList table and ServerList table
*/

CREATE PROCEDURE [dbo].[prGetInstancesAndDatabases]
AS
	BEGIN

		SELECT [sl].[ServerName]
				,[il].[InstanceName]
			   ,[il].[MSSQLVersion]
			   ,[il].[MSSQLEdition]
			   ,[il].[MSSQLServicePack]
			   ,[il].[MSSQLCU]
			   ,[dl].[DatabaseName]
			   ,(CASE WHEN dl.SizeinMB > 1000
					THEN
					CAST(ROUND(CEILING(CAST(dl.SizeInMB AS FLOAT) / 1000), 0) AS INT)
					ELSE
					0
					END) AS [SizeInGB]
				,dl.SizeInMB
		FROM	[dbo].[InstanceList] AS [il]
		INNER JOIN [dbo].[DatabaseList] AS [dl] (NOLOCK) ON dl.[InstanceListId] = [il].[Id]
		INNER JOIN [dbo].[ServerList] AS [sl] (NOLOCK) ON [sl].[Id] = [il].[ServerListId]
		ORDER BY [sl].[ServerName] 
				,[il].[InstanceName]
				,[dl].[DatabaseName];
	END;


GO


