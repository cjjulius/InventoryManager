USE [DBAdmin]
GO

/****** Object:  StoredProcedure [dbo].[prGetInstances]    Script Date: 3/1/2023 2:49:57 PM ******/
DROP PROCEDURE [dbo].[prGetInstances]
GO

/****** Object:  StoredProcedure [dbo].[prGetInstances]    Script Date: 3/1/2023 2:49:57 PM ******/
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


