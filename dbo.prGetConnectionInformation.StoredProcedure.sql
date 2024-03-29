USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	Stored Procedure [dbo].[prGetConnectionInformation]
Date: 		2016-02-04
Author: 	Charlton Julius
Notes: 		Requires DBAdmin Database, ServerList and InstanceList tables
*/

CREATE PROCEDURE [dbo].[prGetConnectionInformation]
AS
    BEGIN
        SELECT  sl.ServerName + '\' + il.InstanceName AS 'Connection'
               ,sl.Id AS 'Server ID'
               ,il.Id AS 'Instance ID'
               ,sl.ServerName
        FROM    dbo.ServerList AS sl
        INNER JOIN dbo.InstanceList AS il ( NOLOCK ) ON il.ServerListId = sl.Id;
    END;



GO
