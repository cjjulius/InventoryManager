USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	Stored Procedure [dbo].[prInsertServiceList]
Date: 		2023-03-04
Author: 	Charlton Julius
Notes: 		Requires DBAdmin Database, ServerList and ServiceList tables
*/

CREATE PROCEDURE [dbo].[prInsertServiceList] (

 @ServerName VARCHAR(MAX)
,@ServiceDisplayName VARCHAR(MAX)
,@ServiceName VARCHAR(MAX)
,@ServiceState VARCHAR(MAX)
,@ServiceStartMode VARCHAR(MAX)
,@ServiceStartName VARCHAR(MAX)
)
AS
    BEGIN

	INSERT INTO dbo.ServiceList (
			 ServerListId 
			,ServerName
			,ServiceDisplayName
			,ServiceName
			,ServiceState
			,ServiceStartMode
			,ServiceStartName)
		SELECT Id
			,@ServerName
			,@ServiceDisplayName
			,@ServiceName
			,@ServiceState
			,@ServiceStartMode
			,@ServiceStartName
		FROM dbo.ServerList sl
		WHERE sl.ServerName = @ServerName;

    END;



GO
