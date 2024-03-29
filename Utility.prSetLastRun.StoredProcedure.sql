USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Object:  	Stored Procedure [Utility].[prSetLastRun]
Date: 		2023-03-25
Author: 	Charlton Julius
Notes: 		Requires DBAdmin Database, Utility.SDIMInfo table
*/

CREATE PROCEDURE [Utility].[prSetLastRun]
( @LastRun DateTime2
)
AS
	BEGIN

		UPDATE [Utility].[SDIMInfo]
		SET [LastRun] = @LastRun
	END;

GO
