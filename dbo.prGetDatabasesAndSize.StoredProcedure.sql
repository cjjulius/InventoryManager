USE [DBAdmin]
GO
/****** Object:  StoredProcedure [dbo].[prGetDatabasesAndSize]    Script Date: 11/14/2016 4:24:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	Stored Procedure [dbo].[prGetDatabasesAndSize]
Date: 		2016-02-04
Author: 	Charlton Julius
Notes: 		Requires DBAdmin Database, DatabaseList and InstanceList tables
*/

CREATE PROCEDURE [dbo].[prGetDatabasesAndSize]
AS
    BEGIN

        SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 10)) AS [DatabaseCount]
				,il.InstanceName
               ,dl.DatabaseName
               ,(CASE WHEN dl.SizeinMB > 1000
					THEN
					CAST(ROUND(CEILING(CAST(dl.SizeInMB AS FLOAT) / 1000), 0) AS INT)
					ELSE
					0
					END) AS [SizeInGB]
				, dl.SizeInMB
        FROM    dbo.DatabaseList AS dl
        INNER JOIN dbo.InstanceList AS il ON il.Id = dl.InstanceListId
        ORDER BY dl.DatabaseName;
    END;


GO
