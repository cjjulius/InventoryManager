#--------------------
#Owner: 	Charlton E Julius
#Updated:	2023-04-02
#Purpose: 	Fills Repository with server\instance.database and related information
#--------------------

param(
[string]$RepositoryInstance 	= 'SomeServer',	 	 #Repository Server\Instance
[string]$RepositoryDB 			= 'DBAdmin' ,		 #Repository Database
[string]$CMSServer				= 'SomeCMSServer',	 #CMS location if applicable
[string]$LogDir 				= "C:\Logs\" ,		 #Directory to save Log
[string]$LogFile				= 'DB_DataPull_Log', #LogName
[string]$LocalDir				= 'C:\SDIM\'		 #Location of this file
[switch]$UseCMS					= $false,			 #Toggle to use CMS
[switch]$Verbose 				= $false,            #Show Verbose information
[switch]$Debug 					= $false 			 #Write Debug information
)

cls

cd $LocalDir

#############################
# 	Internal Variables
#############################

[string]$Date  					= $(Get-Date -Format "yyyy-MM-dd")
[switch]$LogDirExists			= $false

#############################
# 		Test File Path
#############################

. .\funcs\func_Test-FilePath.ps1

#############################
# Verbose and Debug Messages
#############################

. .\funcs\func_Verbose.ps1

#############################
#   GET TYPE OF DATA
#############################

. .\funcs\func_Get-Type.ps1

#############################
#CONVERT WMI-OBJ TO DATATABLE
#############################

. .\funcs\func_Out-DataTable.ps1

#############################
#	  Run SQL Commands
#############################

. .\funcs\func_Invoke-SQL.ps1

#############################
#	 Set Log File Existence
#############################

If (!(Test-FilePath -Path $LogDir)) {
	$LogDirExists = $false
}
else {
	$LogDirExists = $true
}


Verbose -Message "Starting Up..."
Verbose -Message $(Get-Date)


#############################
#	GET INFORMATION FROM CMS
#############################

if ($UseCMS){

	Verbose -Message "Collecting Server and Instance Information from CMS..."

	Invoke-SQL -datasource $Repository -database $RepositoryDB -sqlCommand  "
		TRUNCATE TABLE dbo.ServiceList;
		TRUNCATE TABLE dbo.DatabaseList;
		TRUNCATE TABLE dbo.InstanceList;
		TRUNCATE TABLE dbo.ServerList;
	"

	$CMS_Servers = Invoke-SQL -datasource $CMSServer -database "msdb" -sqlCommand  " 
	SELECT [server_name]
	FROM [dbo].[sysmanagement_shared_registered_servers_internal]
	UNION
    SELECT '$CMSServer'
	"

	foreach ($Row in $CMS_Servers.Rows)
	{ 
		Try
		{
			$ServerInstance = $($Row[0])
			$ServerSplit,$InstanceSplit = $ServerInstance.split('\\',2)
			
			If ($InstanceSplit.Length -lt 1 ){
			$InstanceSplit = 'MSSQLSERVER'
			}
			
			Verbose -Message "Server Name: $ServerSplit"
			Verbose -Message "Instance Name: $InstanceSplit"

			Invoke-SQL -datasource $Repository -database $RepositoryDB -sqlCommand  "
			EXEC dbo.prInsertNewServerAndInstanceCMS @ServerName = '$ServerSplit', @InstanceName = '$InstanceSplit'
			"
				
		}
		Catch
		{
			Verbose -Message "Cannot Collect Information on $ServerInstance"
			Verbose -Message "$_"
		}
	}
}
else {
	Verbose -Message "CMS is not being used. Assuming Servers and Instances were manually loaded."
}

#############################
#	  GET INSTANCE INFO
#############################

Verbose -Message "Collecting Instance Information..."

$ConnectionString = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand  " 
EXEC dbo.prGetConnectionInformation;
"

foreach ($Row in $ConnectionString.Rows)
{ 
	Try
	{
		$SubConnection = $($Row[0]) -replace '\\MSSQLSERVER',''
	  	$InstanceID = $($Row[2])
		
	  	Verbose -Message "Server: $SubConnection"
		
	  	$Version = Invoke-SQL -datasource $SubConnection -database master -sqlCommand  "
		SELECT  SERVERPROPERTY('productversion'), SERVERPROPERTY ('productlevel'), SERVERPROPERTY ('edition'), @@VERSION, SERVERPROPERTY('ProductUpdateLevel')
		"		
	}
	Catch [System.Data.SqlClient.SqlException]
	{
		Verbose -Message "Cannot Collect Information on $SubConnection"
		Verbose -Message "$_"
	}

	foreach ($Row in $Version.Rows)
	{ 
		$MSSQLVersion = $($Row[0])
		$MSSQLServicePack = $($Row[1])
		$MSSQLEdition = $($Row[2])
		$MSSQLVersionLong = $($Row[3])
        $MSSQLCU = $($Row[4])
		
		Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand "
		EXEC dbo.prUpdateInstanceList 
			 @MSSQLVersionLong = '$MSSQLVersionLong'
			,@MSSQLVersion = '$MSSQLVersion'
			,@MSSQLEdition = '$MSSQLEdition'
			,@MSSQLServicePack = '$MSSQLServicePack'
			,@InstanceId = $InstanceID
            ,@MSSQLCU = '$MSSQLCU'	
	"
	}
}

#############################
#	 GET DATABASE INFO
#############################

Verbose -Message "Collecting Database Information..." -LogName $LogFile

$ConnectionString = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand  " 
TRUNCATE TABLE dbo.DatabaseList;
EXEC dbo.prGetConnectionInformation;
"

foreach ($Row in $ConnectionString.Rows)
{ 
	Try
	{
		$SubConnection = $($Row[0]) -replace '\\MSSQLSERVER',''
	  	$InstanceID = $($Row[2])
	  	Verbose -Message "Server: $SubConnection" -LogName $LogFile
	  	$DataPull = Invoke-SQL -datasource $SubConnection -database master -sqlCommand  "
		    with fs
		    as
		    (
		        select database_id, type, size * 8.0 / 1024 size
		        from sys.master_files
		    )
		    select 
		    	$InstanceID AS 'InstanceId',
		    	name
		    	,SUSER_SNAME(db.owner_sid) AS 'database_owner'
		    	,db.recovery_model_desc AS 'recovery_model'
		    	,db.compatibility_level
		    	,db.is_query_store_on
		    	,db.is_encrypted
		    	,db.is_auto_close_on
		    	,db.is_auto_shrink_on
		    	,db.state_desc
		    	,db.snapshot_isolation_state_desc
		    	,db.is_read_committed_snapshot_on
		    	,page_verify_option_desc
		    	,db.is_auto_create_stats_on
		        ,(SELECT CASE   WHEN CAST(SUM(size) AS INT) < 1
		    			        THEN 1
		    			        ELSE CAST(SUM(size) AS INT)
		        END

		    	FROM	fs
		    	WHERE	type = 0
		    		AND fs.database_id = db.database_id) AS DataFileSizeMB
		    from sys.databases db
		"		
	}
	Catch [System.Data.SqlClient.SqlException]
	{
		Verbose -Message "Cannot Collect Information on $SubConnection" -LogName $LogFile
		Verbose -Message "$_" -LogName $LogFile
	}

	foreach ($Row in $DataPull.Rows)
	{
        $InstanceListId 				= $Row[0]
		$DatabaseName 					= $($Row[1])
		$database_owner				    = $($Row[2])
        $recovery_model				    = $($Row[3])
        $compatibility_level			= $Row[4]
        $is_query_store_on				= $Row[5]
        $is_encrypted					= $Row[6]
        $is_auto_close_on				= $Row[7]
        $is_auto_shrink_on				= $Row[8]
        $state_desc					    = $($Row[9])
        $snapshot_isolation_state_desc  = $($Row[10])
        $is_read_committed_snapshot_on  = $Row[11]
        $page_verify_option_desc		= $Row[12]
        $is_auto_create_stats_on		= $Row[13]
		$Size 							= $Row[14]

		Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand "
		EXEC dbo.prInsertDatabaseList
			 @InstanceListId 				= $InstanceListId
            ,@DatabaseName 					= '$DatabaseName'
            ,@database_owner				= '$database_owner'				  
            ,@recovery_model				= '$recovery_model'				  
            ,@compatibility_level			= $compatibility_level			
            ,@is_query_store_on				= $is_query_store_on				
            ,@is_encrypted					= $is_encrypted					
            ,@is_auto_close_on				= $is_auto_close_on				
            ,@is_auto_shrink_on				= $is_auto_shrink_on				
            ,@state_desc					= '$state_desc'					  
            ,@snapshot_isolation_state_desc = '$snapshot_isolation_state_desc'
            ,@is_read_committed_snapshot_on = $is_read_committed_snapshot_on
            ,@page_verify_option_desc		= '$page_verify_option_desc'		
            ,@is_auto_create_stats_on		= $is_auto_create_stats_on		
            ,@Size 							= $Size
		"
	}
}


#############################
#	 GET JOB INFO
#############################

Verbose -Message "Collecting Job Information..."

$ConnectionString = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand  " 
TRUNCATE TABLE dbo.JobList;
EXEC dbo.prGetConnectionInformation;
"

foreach ($Row in $ConnectionString.Rows)
{ 
	Try
	{
		$SubConnection = $($Row[0]) -replace '\\MSSQLSERVER',''
	  	$InstanceID = $($Row[2])
	  	Verbose -Message "Server: $SubConnection"
	  	$DataPull = Invoke-SQL -datasource $SubConnection -database master -sqlCommand  "
		
SELECT
	'$InstanceID' AS [InstanceId]
	,[sJOB].[job_id] AS [JobID] 
	,[sJOB].[name] AS [JobName]
    , ISNULL([sDBP].[name], 'User') AS [JobOwner]
    , [sCAT].[name] AS [JobCategory]
    , [sJOB].[description] AS [JobDescription]
    , CASE [sJOB].[enabled]
        WHEN 1 THEN 'Yes'
        WHEN 0 THEN 'No'
      END AS [JobIsEnabled]
    , ISNULL([sSCH].[name], 'NOT SCHEDULED') AS [JobScheduleName]
	,    CASE [sSCH].[enabled]
        WHEN 1 THEN 'Yes'
        WHEN 0 THEN 'No'
      END AS [ScheduleIsEnabled]
    , CASE 
        WHEN [sSCH].[freq_type] = 64 THEN 'Start automatically when SQL Server Agent starts'
        WHEN [sSCH].[freq_type] = 128 THEN 'Start whenever the CPUs become idle'
        WHEN [sSCH].[freq_type] IN (4,8,16,32) THEN 'Recurring'
        WHEN [sSCH].[freq_type] = 1 THEN 'One Time'
      END [ScheduleType]
    , CASE [sSCH].[freq_type]
        WHEN 1 THEN 'One Time'
        WHEN 4 THEN 'Daily'
        WHEN 8 THEN 'Weekly'
        WHEN 16 THEN 'Monthly'
        WHEN 32 THEN 'Monthly - Relative to Frequency Interval'
        WHEN 64 THEN 'Start automatically when SQL Server Agent starts'
        WHEN 128 THEN 'Start whenever the CPUs become idle'
      END [Occurrence]
    , CASE [sSCH].[freq_type]
        WHEN 4 THEN 'Occurs every ' + CAST([sSCH].[freq_interval] AS VARCHAR(3)) + ' day(s)'
        WHEN 8 THEN 'Occurs every ' + CAST([sSCH].[freq_recurrence_factor] AS VARCHAR(3)) 
                    + ' week(s) on '
                    + CASE WHEN [sSCH].[freq_interval] & 1 = 1 THEN 'Sunday' ELSE '' END
                    + CASE WHEN [sSCH].[freq_interval] & 2 = 2 THEN ', Monday' ELSE '' END
                    + CASE WHEN [sSCH].[freq_interval] & 4 = 4 THEN ', Tuesday' ELSE '' END
                    + CASE WHEN [sSCH].[freq_interval] & 8 = 8 THEN ', Wednesday' ELSE '' END
                    + CASE WHEN [sSCH].[freq_interval] & 16 = 16 THEN ', Thursday' ELSE '' END
                    + CASE WHEN [sSCH].[freq_interval] & 32 = 32 THEN ', Friday' ELSE '' END
                    + CASE WHEN [sSCH].[freq_interval] & 64 = 64 THEN ', Saturday' ELSE '' END
        WHEN 16 THEN 'Occurs on Day ' + CAST([sSCH].[freq_interval] AS VARCHAR(3)) 
                     + ' of every '
                     + CAST([sSCH].[freq_recurrence_factor] AS VARCHAR(3)) + ' month(s)'
        WHEN 32 THEN 'Occurs on '
                     + CASE [sSCH].[freq_relative_interval]
                        WHEN 1 THEN 'First'
                        WHEN 2 THEN 'Second'
                        WHEN 4 THEN 'Third'
                        WHEN 8 THEN 'Fourth'
                        WHEN 16 THEN 'Last'
                       END
                     + ' ' 
                     + CASE [sSCH].[freq_interval]
                        WHEN 1 THEN 'Sunday'
                        WHEN 2 THEN 'Monday'
                        WHEN 3 THEN 'Tuesday'
                        WHEN 4 THEN 'Wednesday'
                        WHEN 5 THEN 'Thursday'
                        WHEN 6 THEN 'Friday'
                        WHEN 7 THEN 'Saturday'
                        WHEN 8 THEN 'Day'
                        WHEN 9 THEN 'Weekday'
                        WHEN 10 THEN 'Weekend day'
                       END
                     + ' of every ' + CAST([sSCH].[freq_recurrence_factor] AS VARCHAR(3)) 
                     + ' month(s)'
      END AS [Recurrence]
    , CASE [sSCH].[freq_subday_type]
        WHEN 1 THEN 'Occurs once at ' 
                    + STUFF(
                 STUFF(RIGHT('000000' + CAST([sSCH].[active_start_time] AS VARCHAR(6)), 6)
                                , 3, 0, ':')
                            , 6, 0, ':')
        WHEN 2 THEN 'Occurs every ' 
                    + CAST([sSCH].[freq_subday_interval] AS VARCHAR(3)) + ' Second(s) between ' 
                    + STUFF(
                   STUFF(RIGHT('000000' + CAST([sSCH].[active_start_time] AS VARCHAR(6)), 6)
                                , 3, 0, ':')
                            , 6, 0, ':')
                    + ' & ' 
                    + STUFF(
                    STUFF(RIGHT('000000' + CAST([sSCH].[active_end_time] AS VARCHAR(6)), 6)
                                , 3, 0, ':')
                            , 6, 0, ':')
        WHEN 4 THEN 'Occurs every ' 
                    + CAST([sSCH].[freq_subday_interval] AS VARCHAR(3)) + ' Minute(s) between ' 
                    + STUFF(
                   STUFF(RIGHT('000000' + CAST([sSCH].[active_start_time] AS VARCHAR(6)), 6)
                                , 3, 0, ':')
                            , 6, 0, ':')
                    + ' & ' 
                    + STUFF(
                    STUFF(RIGHT('000000' + CAST([sSCH].[active_end_time] AS VARCHAR(6)), 6)
                                , 3, 0, ':')
                            , 6, 0, ':')
        WHEN 8 THEN 'Occurs every ' 
                    + CAST([sSCH].[freq_subday_interval] AS VARCHAR(3)) + ' Hour(s) between ' 
                    + STUFF(
                    STUFF(RIGHT('000000' + CAST([sSCH].[active_start_time] AS VARCHAR(6)), 6)
                                , 3, 0, ':')
                            , 6, 0, ':')
                    + ' & ' 
                    + STUFF(
                    STUFF(RIGHT('000000' + CAST([sSCH].[active_end_time] AS VARCHAR(6)), 6)
                                , 3, 0, ':')
                            , 6, 0, ':')
      END [Frequency]
FROM
    [msdb].[dbo].[sysjobs] AS [sJOB]
    LEFT JOIN [msdb].[sys].[servers] AS [sSVR]
        ON [sJOB].[originating_server_id] = [sSVR].[server_id]
    LEFT JOIN [msdb].[dbo].[syscategories] AS [sCAT]
        ON [sJOB].[category_id] = [sCAT].[category_id]
    LEFT JOIN [msdb].[dbo].[sysjobsteps] AS [sJSTP]
        ON [sJOB].[job_id] = [sJSTP].[job_id]
        AND [sJOB].[start_step_id] = [sJSTP].[step_id]
    LEFT JOIN [msdb].[sys].[database_principals] AS [sDBP]
        ON [sJOB].[owner_sid] = [sDBP].[sid]
    LEFT JOIN [msdb].[dbo].[sysjobschedules] AS [sJOBSCH]
        ON [sJOB].[job_id] = [sJOBSCH].[job_id]
    LEFT JOIN [msdb].[dbo].[sysschedules] AS [sSCH]
        ON [sJOBSCH].[schedule_id] = [sSCH].[schedule_id]
		"		
	}
	Catch [System.Data.SqlClient.SqlException]
	{
		Verbose -Message "Cannot Collect Job Information on $SubConnection"
		Verbose -Message "$_"
	}

	foreach ($Row in $DataPull.Rows)
	{ 
		$InstanceListId=$Row[0]
		$JobID=$Row[1]
		$JobName = $($Row[2]) -replace "'",""
		$JobOwner =$($Row[3]) -replace "'",""
		$JobCategory =$($Row[4]) -replace "'",""
		$JobDescription =$($Row[5]) -replace "'",""
		$JobIsEnabled =$($Row[6]) -replace "'",""
		$JobScheduleName =$($Row[7]) -replace "'",""
		$ScheduleIsEnabled =$($Row[8]) -replace "'",""
		$ScheduleType =$($Row[9]) -replace "'",""
		$Occurrence =$($Row[10]) -replace "'",""
		$Recurrence =$($Row[11]) -replace "'",""
		$Frequency =$($Row[12]) -replace "'",""

		Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand "
		EXEC dbo.prInsertJobList
			@InstanceListId = '$InstanceListId'
			,@JobID = '$JobID'
			,@JobName = '$JobName'
			,@JobOwner = '$JobOwner'
			,@JobCategory = '$JobCategory'
			,@JobDescription = '$JobDescription'
			,@JobIsEnabled = '$JobIsEnabled'
			,@JobScheduleName = '$JobScheduleName'
			,@ScheduleIsEnabled = '$ScheduleIsEnabled'
			,@ScheduleType = '$ScheduleType'
			,@Occurrence = '$Occurrence'
			,@Recurrence = '$Recurrence'
			,@Frequency = '$Frequency'

		"
	}
}

$ConnectionString = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand  " 
TRUNCATE TABLE dbo.ServiceList;
EXEC prGetServerNames;
"

#############################
#		GET SERVICE INFO
#############################

Verbose -Message "Collecting Service Information..."

foreach ($Row in $ConnectionString.Rows)
{ 
    Verbose -Message $Row[0]
	Try
	{
		If (Test-Connection  $($Row[0]) -Count 1 -Quiet){
		$ServerInfo = Get-WmiObject win32_Service -Computer $Row[0] -ErrorAction SilentlyContinue |
	    where {$_.DisplayName -match "SQL Server"} | 
	    select SystemName, DisplayName, Name, State, StartMode, StartName | Out-DataTable

		foreach ($Service in $ServerInfo)
			{
			$ServerName = $Service[0]
			$ServiceDisplayName = $Service[1]
			$ServiceName = $Service[2] 
			$ServiceState =  $Service[3] 
			$ServiceStartMode =  $Service[4] 
			$ServiceStartName =  $Service[5] 
			
			$ConnectionString = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand  " 
			EXEC dbo.prInsertServiceList
				@ServerName = '$ServerName'
				,@ServiceDisplayName = '$ServiceDisplayName'
				,@ServiceName = '$ServiceName'
				,@ServiceState = '$ServiceState'
				,@ServiceStartMode = '$ServiceStartMode'
				,@ServiceStartName = '$ServiceStartName';
			"
			}
		}
		else
		{
		Verbose -Messaget "Cannot Collect Service Information on $ServerName."
		}
	}
	Catch [System.UnauthorizedAccessException]
	{
		Verbose -Message "Cannot Collect Service Information on $ServerName. Not Authorized."
		Verbose -Message $_
	}
	Catch 
	{
		Verbose -Message "Cannot Collect Service Information on $ServerName."
		Verbose -Message $_
	}
}

#############################
#		GET SERVER INFO
#############################

Verbose -Message "Collecting Server Information..."

$ConnectionString = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand  " 
EXEC prGetServerNames;
"

foreach ($Row in $ConnectionString.Rows)
{ 
	$Server = $($Row[0])
    Verbose -Message $Server
	Try
		{
		If (Test-Connection  $Server -Count 1 -Quiet)
			{
			$ips = [System.Net.Dns]::GetHostAddresses($($Row[0]))
			
			$OSName = $((Get-WmiObject -comp $($Row[0]) -class Win32_OperatingSystem -ErrorAction SilentlyContinue).Caption)
			$OSServicePack = $((Get-WmiObject -comp $($Row[0]) -class Win32_OperatingSystem -ErrorAction SilentlyContinue).ServicePackMajorVersion)
			
			$ConnectionString = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand  "
			EXEC dbo.prUpdateServerList 
				 @IPAddress = '$ips'
				,@OSName = '$OSName'
				,@OSServicePack = '$OSServicePack'
				,@ServerName = '$Server'
			"
			}
		else
			{
			Verbose -Message "Cannot Collect Information on $Server."
			}
	}
	Catch [System.UnauthorizedAccessException]
	{
		Verbose -Message "Cannot Collect Server Information on $ServerName. Not Authorized."
		Verbose -Message $_
	}
	Catch
	{
		Verbose -Message "Cannot Collect Server Information on $ServerName."
		Verbose -Message $_
	}
}

#############################
#	 GET TABLE INFO
#############################

Verbose -Message "Collecting Table Information..." -LogName $LogFile

$ConnectionString = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand  " 
TRUNCATE TABLE dbo.TableList;
EXEC dbo.prGetConnectionInformation;
"

foreach ($Row in $ConnectionString.Rows)
{ 
	Try
	{
		$SubConnection = $($Row[0]) -replace '\\MSSQLSERVER',''
	  	$InstanceID = $($Row[2])

	  	Verbose -Message "Getting Databases from $SubConnection" -LogName $LogFile

	  	$DataPull = Invoke-SQL -datasource $SubConnection -database master -timeout 180 -sqlCommand  "
		SELECT [name]
        FROM [sys].[databases] AS [dbs]
        WHERE [dbs].[user_access] = 0
	        AND [dbs].[state] = 0
		"		
	}
	Catch [System.Data.SqlClient.SqlException]
	{
		Verbose -Message "Cannot Collect Database from $SubConnection" -LogName $LogFile
		Verbose -Message "$_" -LogName $LogFile
	}

	foreach ($TRow in $DataPull.Rows)
	{
        Try
        {
            Verbose -Message "Collecting Table information on $SubConnection.$($TRow[0])" -LogName $LogFile

	  	    $TablePull = Invoke-SQL -datasource $SubConnection -database $($TRow[0]) -timeout 720 -sqlCommand  "
		    		SELECT 
		    	 SERVERPROPERTY('MachineName')									AS ServerName
		    	,@@SERVICENAME													AS InstanceName
		    	,DB_NAME()														AS DatabaseName
		        ,s.Name															AS SchemaName
		    	,t.NAME															AS TableName
		        ,p.rows															AS TableRows
		        ,SUM(a.total_pages) * 8											AS TotalSpaceKB
		        ,CAST(
		    		ROUND(
		    				(
		    					(SUM(a.total_pages) * 8) / 1024.00
		    				)
		    			 , 2
		    			 ) 
		    		 AS NUMERIC(36, 2)
		    		 )															AS TotalSpaceMB
		        ,SUM(a.used_pages) * 8											AS UsedSpaceKB
		        ,CAST(
		    		ROUND(
		    				(
		    				(SUM(a.used_pages) * 8) / 1024.00
		    				)
		    			 , 2
		    			 ) 
		    		AS NUMERIC(36, 2)
		    		 )															AS UsedSpaceMB
		        ,(SUM(a.total_pages) - SUM(a.used_pages)) * 8					AS UnusedSpaceKB
		        ,CAST(
		    		ROUND(
		    				(
		    					(
		    					SUM(a.total_pages) - SUM(a.used_pages)
		    					) * 8
		    				) / 1024.00
		    			 , 2
		    			 ) 
		    		AS NUMERIC(36, 2))											AS UnusedSpaceMB
		    FROM sys.tables t
		    INNER JOIN		sys.indexes i 
		    	ON t.OBJECT_ID = i.object_id
		    INNER JOIN		sys.partitions p 
		    	ON i.object_id = p.OBJECT_ID 
		    		AND i.index_id = p.index_id
		    INNER JOIN sys.allocation_units a 
		    	ON p.partition_id = a.container_id
		    LEFT OUTER JOIN sys.schemas s 
		    	ON t.schema_id = s.schema_id
		    WHERE t.NAME NOT LIKE 'dt%' 
		        AND t.is_ms_shipped = 0
		        AND i.OBJECT_ID > 255 
		    GROUP BY 
		         t.Name
		    	,s.Name
		    	,p.Rows
		    "
    
            	foreach ($iRow in $TablePull.Rows)
            	{
                    Try
                    {
                    #Verbose -Message "Inserting table information on $($iRow[0]).$($iRow[2]).$($iRow[3]).$($iRow[4])" -LogName $LogFile
    
                    $ServerName =    $($iRow[0])
                    $InstanceName =  $($iRow[1])  
                    $DatabaseName =  $($iRow[2])
                    $SchemaName =    $($iRow[3])
                    $TableName =     $($iRow[4])
                    $TableRows =     $iRow[5]
                    $TotalSpaceKB =  $iRow[6]
                    $TotalSpaceMB =  $iRow[7]
                    $UsedSpaceKB  =  $iRow[8]
                    $UsedSpaceMB =   $iRow[9]
                    $UnusedSpaceKB = $iRow[10]
                    $UnusedSpaceMB = $iRow[11] 
            
                   	Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand "
                   	EXEC dbo.prInsertTableList
                   	    @ServerName	=  '$ServerName'
                       ,@InstanceName	=  '$InstanceName'
                       ,@DatabaseName	=  '$DatabaseName'
                       ,@SchemaName	=  '$SchemaName'
                       ,@TableName		=  '$TableName'
                       ,@TableRows		=  $TableRows
                       ,@TotalSpaceKB	=  $TotalSpaceKB
                       ,@TotalSpaceMB	=  $TotalSpaceMB
                       ,@UsedSpaceKB	=  $UsedSpaceKB
                       ,@UsedSpaceMB	=  $UsedSpaceMB
                       ,@UnusedSpaceKB =  $UnusedSpaceKB
                       ,@UnusedSpaceMB = $UnusedSpaceMB 
                   	"  
                 }
               	 Catch [System.Data.SqlClient.SqlException]
               	 {
               	    Verbose -Message "Cannot Insert information on $($iRow)" -LogName $LogFile
               	    Verbose -Message "$_" -LogName $LogFile
               	 }
    
             }
        }
	    Catch [System.Data.SqlClient.SqlException]
	    {
		    Verbose -Message "Cannot Collect Information on $SubConnection.$($Row[0])" -LogName $LogFile
		    Verbose -Message "$_" -LogName $LogFile
	    }
    }

}

#############################
#	 GET PERMISSIONS
#############################

Verbose -Message "Collecting Permission Information..." -LogName $LogFile

$ConnectionString = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand  " 
TRUNCATE TABLE stage.tDBPermission;
TRUNCATE TABLE stage.tSrvPermission;
EXEC dbo.prGetConnectionInformation;
"

foreach ($Row in $ConnectionString.Rows)
{ 
	Try
	{
		$SubConnection = $($Row[0]) -replace '\\MSSQLSERVER',''
	  	$InstanceID = $($Row[2])

	  	Verbose -Message "Getting Permissions from $SubConnection" -LogName $LogFile

        $DBPermission = Invoke-SQL -datasource $SubConnection -database master -timeout 3600 -sqlCommand  "
		EXEC [dbo].[sp_DBPermissions] @DBName='All', @Output = 'Report'
        WITH RESULT SETS
        (
        	(
        	 [DBName] [sysname],
        	 [DBPrincipal] [sysname],
        	 [SrvPrincipal] [sysname],
        	 [type] [char](5),
        	 [type_desc] [nvarchar](100),
        	 [RoleMembership] [nvarchar](MAX),
        	 [DirectPermissions] [nvarchar](MAX)
        	)
        )
        "
	  	$SrvPermission = Invoke-SQL -datasource $SubConnection -database master -timeout 3600 -sqlCommand  "
		EXEC [dbo].[sp_SrvPermissions] @Output = 'Report'
        WITH RESULT SETS
        (
        	(
        	 [SrvPrincipal] [sysname]
        	,[type] [char](5)
        	,[type_desc] [nvarchar](100)
        	,[is_disabled] [int]
        	,[RoleMembership] [sysname]
        	,[DirectPermissions] [nvarchar](256)
        	)
        )
		"

	}
	Catch [System.Data.SqlClient.SqlException]
	{
		Verbose -Message "Cannot Collect Permissions from $SubConnection" -LogName $LogFile
		Verbose -Message "$_" -LogName $LogFile
	}

	foreach ($DRow in $DBPermission.Rows)
	{
        Try
        {
            $ServerName			= $SubConnection
            $DBName 			= $($DRow[0])
            $DBPrincipal		= $($DRow[1])
            $SrvPrincipal		= $($DRow[2])
            $type				= $($DRow[3])
            $type_desc			= $($DRow[4])
            $RoleMembership		= $($DRow[5])
            $DirectPermissions	= $($DRow[6])
            
            $ConnectionString = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand  " 
            EXEC [dbo].[prStageDBPermissions]
                 @ServerName			='$ServerName'		
                ,@DBName                ='$DBName' 		
                ,@DBPrincipal           ='$DBPrincipal'	
                ,@SrvPrincipal          ='$SrvPrincipal'	
                ,@type                  ='$type'			
                ,@type_desc             ='$type_desc'		
                ,@RoleMembership        ='$RoleMembership'	
                ,@DirectPermissions     ='$DirectPermissions'
            "
	  	    
        }
	    Catch [System.Data.SqlClient.SqlException]
	    {
		    Verbose -Message "Cannot Collect DB Permissions on $SubConnection" -LogName $LogFile
		    Verbose -Message "$_" -LogName $LogFile
	    }
    }

    foreach ($SRow in $SrvPermission.Rows)
	{
        Try
        {
            $ServerName			= $SubConnection
            $SrvPrincipal		= $($SRow[0])
            $type				= $($SRow[1])
            $type_desc			= $($SRow[2])
            $is_disabled		= $($SRow[3])
            $RoleMembership		= $($SRow[4])
            $DirectPermissions	= $($SRow[5])
            
            $ConnectionString = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand  " 
            EXEC [dbo].[prStageSrvPermissions]
                  @ServerName			='$ServerName'
                 ,@SrvPrincipal			='$SrvPrincipal'
                 ,@type					='$type'
                 ,@type_desc			='$type_desc'
                 ,@is_disabled			='$is_disabled'
                 ,@RoleMembership		='$RoleMembership'
                 ,@DirectPermissions	='$DirectPermissions'
            "
	  	    
        }
	    Catch [System.Data.SqlClient.SqlException]
	    {
		    Verbose -Message "Cannot Collect Server Permissions on $SubConnection" -LogName $LogFile
		    Verbose -Message "$_" -LogName $LogFile
	    }
    }
}
  
Verbose -Message "Merging into final tables." -LogName $LogFile 

   $ConnectionString = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand  "
       EXEC [dbo].[prMergeDBPermissions]"

   $ConnectionString = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand  "
       EXEC [dbo].[prMergeSrvPermissions]"


#############################
#		FINISH UP
#############################

[DateTime]$CompletionTime = $(Get-Date)

Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand "
		EXEC [Utility].[prSetLastRun]
        @LastRun = '$CompletionTime';
	"

Verbose -Message "Done."