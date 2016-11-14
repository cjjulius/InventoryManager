USE [DBAdmin]
GO
/****** Object:  StoredProcedure [dbo].[prGetInstances]    Script Date: 11/14/2016 4:24:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	Stored Procedure [dbo].[prGetInstances]
Date: 		2016-02-04
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
               ,il.MSSQLEdition
               ,il.MSSQLVersionLong
        FROM    dbo.InstanceList AS il
        ORDER BY il.InstanceName;
    END;


GO
