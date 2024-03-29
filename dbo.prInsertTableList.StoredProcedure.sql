USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	Stored Procedure [dbo].[prInsertDatabaseList]
Date: 		2023-03-24
Author: 	Charlton Julius
Notes: 		Requires DBAdmin Database and TableList table
*/

CREATE PROCEDURE [dbo].[prInsertTableList] (
 @ServerName	[nvarchar](128)
,@InstanceName	[nvarchar](128)
,@DatabaseName	[nvarchar](128)
,@SchemaName	[sysname]
,@TableName		[sysname]
,@TableRows		[bigint]
,@TotalSpaceKB	[bigint]
,@TotalSpaceMB	[numeric](36, 2)
,@UsedSpaceKB	[bigint]
,@UsedSpaceMB	[numeric](36, 2)
,@UnusedSpaceKB [bigint] 
,@UnusedSpaceMB [numeric](36, 2)
)
AS
	BEGIN

	INSERT INTO [dbo].[TableList]
	(
		 [ServerName]
		,[InstanceName]
		,[DatabaseName]
		,[SchemaName]
		,[TableName]
		,[TableRows]
		,[TotalSpaceKB]
		,[TotalSpaceMB]
		,[UsedSpaceKB]
		,[UsedSpaceMB]
		,[UnusedSpaceKB]
		,[UnusedSpaceMB]
	)
	VALUES
	(
		 @ServerName
		,@InstanceName 
		,@DatabaseName 
		,@SchemaName
		,@TableName
		,@TableRows
		,@TotalSpaceKB 
		,@TotalSpaceMB 
		,@UsedSpaceKB
		,@UsedSpaceMB
		,@UnusedSpaceKB
		,@UnusedSpaceMB
	)

	END;
GO
