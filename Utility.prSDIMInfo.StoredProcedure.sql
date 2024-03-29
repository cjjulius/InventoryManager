USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Object:  	Stored Procedure [Utility].[prSDIMInfo]
Date: 		2023-03-25
Author: 	Charlton Julius
Notes: 		Requires DBAdmin Database, Utility.SDIMInfo table
*/

CREATE PROCEDURE [Utility].[prSDIMInfo]
AS
	BEGIN

		SELECT TOP(1) 
			 [Version]
			,FORMAT([LastRun] ,'yyyy-MM-dd HH:mm') AS [LastRun]
		FROM [Utility].[SDIMInfo]
	END;

GO
