USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	View [dbo].[vwGetServers]
Date: 		2016-11-14
Author: 	Charlton Julius
Notes: 		Reporting - Requires ServerList table
*/

CREATE VIEW [Reports].[vwGetServers]
AS
	( SELECT	ROW_NUMBER() OVER ( ORDER BY ( SELECT	10
											 ) ) AS [ServerCount]
			   ,[sl].[ServerName]
			   ,[sl].[OSName]
			   ,[sl].[OSServicePack]
	  FROM		[dbo].[ServerList] AS [sl]
	);
GO
