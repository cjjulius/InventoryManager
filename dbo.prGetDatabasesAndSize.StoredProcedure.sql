USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	Stored Procedure [dbo].[prGetDatabasesAndSize]
Date: 		2016-03-29
Author: 	Charlton Julius
Notes: 		Requires DBAdmin Database, DatabaseList and InstanceList tables
*/

CREATE PROCEDURE [dbo].[prGetDatabasesAndSize]
AS
    BEGIN

        SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 10)) AS [DatabaseCount]
				,[il].[InstanceName]					AS [Instance]
				,[dl].[DatabaseName]					AS [Database]
				,(CASE WHEN dl.SizeinMB > 1000
					THEN
						CAST(
							ROUND(
								CEILING(
									CAST(dl.SizeInMB AS FLOAT)
								/ 1000)
							, 0) 
						AS INT)
					ELSE
						0
					END)								AS [Size in GB]
				,[dl].[SizeInMB]						AS [Size in MB]
				,[dl].[database_owner]					AS [Database Owner]		
				,[dl].[recovery_model]					AS [Recovery Model]
				,[dl].[state_desc]						AS [Database State]	
				,[dl].[compatibility_level]				AS [Compatibility Level]				
				,[dl].[is_query_store_on]				AS [Query Store?]	
				,[dl].[is_encrypted]					AS [Encrypted?]					
				,[dl].[is_auto_close_on]				AS [Auto-Close?]			
				,[dl].[is_auto_shrink_on]				AS [Auto-Shrink?]		
				,[dl].[is_auto_create_stats_on]			AS [Auto-Create Stats?]
				,[dl].[is_read_committed_snapshot_on]	AS [RCSI?]
				,[dl].[snapshot_isolation_state_desc]	AS [Snapshot Isolation]
				,[dl].[page_verify_option_desc]			AS [Page Verify]		
        FROM    dbo.DatabaseList AS dl
        INNER JOIN dbo.InstanceList AS il ON il.Id = dl.InstanceListId
        ORDER BY dl.DatabaseName;
    END;


GO
