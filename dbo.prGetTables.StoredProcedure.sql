USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Object:  	Stored Procedure [dbo].[prGetTables]
Date: 		2023-03-31
Author: 	Charlton Julius
Notes: 		Requires DBAdmin Database, TableList table
*/

CREATE PROCEDURE [dbo].[prGetTables]
AS
    BEGIN

        SELECT  ROW_NUMBER() OVER (ORDER BY (SELECT 10)) AS [TableCount]
				,[tb].[ServerName]
				,[tb].[DatabaseName]
				,[tb].[SchemaName]
				,[tb].[TableName]
				,[tb].[TableRows]
				,[tb].[TotalSpaceKB]
				,[tb].[TotalSpaceMB]
				,[tb].[UsedSpaceKB]
				,[tb].[UsedSpaceMB]
				,[tb].[UnusedSpaceKB]
				,[tb].[UnusedSpaceMB]
		FROM [DBAdmin].[dbo].[TableList] AS [tb]
        ORDER BY [tb].[ServerName]
				,[tb].[DatabaseName]
				,[tb].[SchemaName]
				,[tb].[TableName]
    END;




GO
