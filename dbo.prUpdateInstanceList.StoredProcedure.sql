USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
Object:  	Stored Procedure [dbo].[prUpdateInstanceList]
Date: 		2016-02-04
Author: 	Charlton Julius
Notes: 		Requires DBAdmin Database, InstanceList table
*/

CREATE PROCEDURE [dbo].[prUpdateInstanceList](

	 @MSSQLVersionLong VARCHAR(MAX)
	,@MSSQLVersion VARCHAR(MAX)
	,@MSSQLEdition VARCHAR(MAX)
	,@MSSQLServicePack VARCHAR(20)
	,@InstanceId BIGINT
)
AS
    BEGIN

        UPDATE dbo.InstanceList
		SET MSSQLVersionLong = @MSSQLVersionLong
			,MSSQLVersion = @MSSQLVersion
			,MSSQLEdition = @MSSQLEdition
			,MSSQLServicePack = @MSSQLServicePack
		WHERE Id = @InstanceID	
    END;
    
GO
