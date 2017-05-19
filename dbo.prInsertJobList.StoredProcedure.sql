USE [DBAdmin]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*
Object:  	Stored Procedure [dbo].[prInsertJobList]
Date: 		2017-05-19
Author: 	Charlton Julius
Notes: 		Inserts Jobs into table
*/


CREATE PROCEDURE [dbo].[prInsertJobList] (
	@InstanceListId BIGINT
	,@JobID UNIQUEIDENTIFIER
	,@JobName NVARCHAR(128)
	,@JobOwner NVARCHAR(128)
	,@JobCategory NVARCHAR(128)
	,@JobDescription NVARCHAR(512)
	,@JobIsEnabled VARCHAR(3)
	,@JobScheduleName NVARCHAR(128)
	,@ScheduleIsEnabled VARCHAR(3)
	,@ScheduleType VARCHAR(48)
	,@Occurrence VARCHAR(48)
	,@Recurrence VARCHAR(90)
	,@Frequency VARCHAR(54)
)
AS
    BEGIN

INSERT INTO [dbo].[JobList]
		(
		 [InstanceListId]
		,[JobID]
		,[JobName]
		,[JobOwner]
		,[JobCategory]
		,[JobDescription]
		,[JobIsEnabled]
		,[JobScheduleName]
		,[ScheduleIsEnabled]
		,[ScheduleType]
		,[Occurrence]
		,[Recurrence]
		,[Frequency]
		)
		VALUES
		(
		@InstanceListId 
		,@JobID 
		,@JobName 
		,@JobOwner 
		,@JobCategory 
		,@JobDescription 
		,@JobIsEnabled 
		,@JobScheduleName 
		,@ScheduleIsEnabled 
		,@ScheduleType 
		,@Occurrence 
		,@Recurrence 
		,@Frequency 
		)
    END;

GO
