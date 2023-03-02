/* 
---------------------

	---Permissions on SQL Server for SDIM 2.4---

-- Replace [SomeDomain\SomeUser] with the service account that will be pulling the data.
-- Comment out DBAdmin section if you don't have one on every server. This is only /necessary/ on the CMS.
-- You will also need to grant sufficent rights to service account for WMI. See readme.

---------------------
*/


--MASTER

USE [master];
GO

CREATE LOGIN [SomeDomain\SomeUser] 
	FROM WINDOWS;
GO
CREATE USER [SomeDomain\SomeUser] 
	FROM LOGIN [SomeDomain\SomeUser];
GO

ALTER ROLE [db_datareader] 
	ADD MEMBER [SomeDomain\SomeUser];
GRANT VIEW ANY DEFINITION
TO [SomeDomain\SomeUser];
GO


--MSDB

USE [msdb];
GO

CREATE USER [SomeDomain\SomeUser] 
	FROM LOGIN [SomeDomain\SomeUser];
GO

ALTER ROLE [db_datareader] 
	ADD MEMBER [SomeDomain\SomeUser];

ALTER ROLE [dc_proxy] 
	ADD MEMBER [SomeDomain\SomeUser]

ALTER ROLE [ServerGroupAdministratorRole] 
	ADD MEMBER [SomeDomain\SomeUser]

ALTER ROLE [ServerGroupReaderRole] 
	ADD MEMBER [SomeDomain\SomeUser]

ALTER ROLE [SQLAgentOperatorRole] 
	ADD MEMBER [SomeDomain\SomeUser]

ALTER ROLE [SQLAgentReaderRole] 
	ADD MEMBER [SomeDomain\SomeUser]

ALTER ROLE [SQLAgentUserRole] 
	ADD MEMBER [SomeDomain\SomeUser]

GRANT VIEW DEFINITION
TO [SomeDomain\SomeUser];
GO


--DBAdmin

USE [DBAdmin];
GO

CREATE USER [SomeDomain\SomeUser] 
	FROM LOGIN [SomeDomain\SomeUser];
GO

ALTER ROLE [db_datareader] 
	ADD MEMBER [SomeDomain\SomeUser];

ALTER ROLE [db_datawriter] 
	ADD MEMBER [SomeDomain\SomeUser];

GRANT VIEW DEFINITION
	TO [SomeDomain\SomeUser];

GRANT EXECUTE
	TO [SomeDomain\SomeUser];

GRANT ALTER
	TO [SomeDomain\SomeUser];