USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Object:  	Stored Procedure [dbo].[prInsertDatabaseList]
Date: 		2023-03-26
Author: 	Charlton Julius
Notes: 		Requires DBAdmin Database and DatabaseList table
*/

CREATE   PROCEDURE [dbo].[prInsertDatabaseList] (
 @DatabaseName					[VARCHAR](MAX)
,@InstanceListId				[BIGINT]
,@database_owner				[NVARCHAR](256)
,@recovery_model				[NVARCHAR](60)
,@compatibility_level			[INT]
,@is_query_store_on				[BIT]
,@is_encrypted					[BIT]
,@is_auto_close_on				[BIT]
,@is_auto_shrink_on				[BIT]
,@state_desc					[NVARCHAR](60)
,@snapshot_isolation_state_desc [NVARCHAR](60)
,@is_read_committed_snapshot_on [BIT]
,@page_verify_option_desc		[NVARCHAR](60)
,@is_auto_create_stats_on		[BIT]
,@Size							[FLOAT]
)
AS
    BEGIN

	INSERT INTO dbo.DatabaseList (
		  [DatabaseName]					
		 ,[InstanceListId]				
		 ,[database_owner]				
		 ,[recovery_model]				
		 ,[compatibility_level]			
		 ,[is_query_store_on]			
		 ,[is_encrypted]					
		 ,[is_auto_close_on]				
		 ,[is_auto_shrink_on]			
		 ,[state_desc]					
		 ,[snapshot_isolation_state_desc]
		 ,[is_read_committed_snapshot_on]
		 ,[page_verify_option_desc]		
		 ,[is_auto_create_stats_on]		
		 ,[SizeInMB]						
		)
	VALUES
		(
		 @DatabaseName					
		,@InstanceListId				
		,@database_owner				
		,@recovery_model				
		,@compatibility_level			
		,@is_query_store_on				
		,@is_encrypted					
		,@is_auto_close_on				
		,@is_auto_shrink_on				
		,@state_desc					
		,@snapshot_isolation_state_desc 
		,@is_read_committed_snapshot_on 
		,@page_verify_option_desc		
		,@is_auto_create_stats_on		
		,@Size							
		);

   END;



GO
