#--------------------
#Owner: 	Charlton E Julius
#Updated:	2023-03-01
#Version: 	2.4
#Purpose: 	Fills Repository with server\instance.database and related information
#--------------------

param(
[string]$RepositoryInstance 	= '(local)',		#Repository Server\Instance
[string]$RepositoryDB 			= 'DBAdmin' ,		#Repository Database
[string]$CMSServer				= 'SOMSERVER' ,		#CMS location if applicable
[string]$LogDir 				= "C:\Logs\" ,		#Directory to save Log
[switch]$UseCMS					= $false	,		#Toggle to use CMS
[switch]$Verbose 				= $false ,          #Show Verbose information
[switch]$Debug 					= $false 			#Write Debug information
)

cls

#############################
# 	Internal Variables
#############################

[string]$Date  					= $(Get-Date -Format "yyyy-MM-dd")
[switch]$LogDirExists			= $false

#############################
# 		Test File Path
#############################

Function Test-FilePath {
	Param([string]$Path)
	
	if ((!(Test-Path $Path))) {
    	Return $false
    }
	else {
		Return $true
	}
}

#############################
# Verbose and Debug Messages
#############################

Function Verbose {
	Param([string]$Message)
	
	if ($Verbose){
		Write-Host $Message
		
		if ($LogDirExists){
			Add-Content "$LogDir\DB_DataPull_Log_$Date.txt" "$Message"
		}
	}
	
	if ($Debug) {
		
		if ($LogDirExists){
			Add-Content "$LogDir\DB_DataPull_Log_$Date.txt" "$Message"
		}	
	}
}

#############################
#  CONVERT WMI TO DATATABLE
#	Source: https://github.com/Proxx/PowerShell/blob/master/Common/Get-Type.ps1
#############################

function Get-Type 
{ 
    param($type) 
 
	$types = @( 
	'System.Boolean', 
	'System.Byte[]', 
	'System.Byte', 
	'System.Char', 
	'System.Datetime', 
	'System.Decimal', 
	'System.Double', 
	'System.Guid', 
	'System.Int16', 
	'System.Int32', 
	'System.Int64', 
	'System.Single', 
	'System.UInt16', 
	'System.UInt32', 
	'System.UInt64') 
 
    if ( $types -contains $type ) 
	{ 
        Write-Output "$type" 
    } 
    else 
	{ 
        Write-Output 'System.String' 
    } 
} 

#############################
#CONVERT WMI-OBJ TO DATATABLE
#	Source: http://poshcode.org/2119
#############################

function Out-DataTable 
{ 
    [CmdletBinding()] 
    param([Parameter(Position=0, Mandatory=$true, ValueFromPipeline = $true)] [PSObject[]]$InputObject) 
 
    Begin 
    { 
        $dt = new-object Data.datatable   
        $First = $true  
    } 
    Process 
    { 
        foreach ($object in $InputObject) 
        { 
            $DR = $DT.NewRow()   
            foreach($property in $object.PsObject.get_properties()) 
            {   
                if ($first) 
                {   
                    $Col =  new-object Data.DataColumn   
                    $Col.ColumnName = $property.Name.ToString()   
                    if ($property.value) 
                    { 
                        if ($property.value -isnot [System.DBNull]) 
						{ 
                            $Col.DataType = [System.Type]::GetType("$(Get-Type $property.TypeNameOfValue)") 
                        } 
                    } 
                    $DT.Columns.Add($Col) 
                }   
                if ($property.Gettype().IsArray) 
				{ 
                    $DR.Item($property.Name) =$property.value | ConvertTo-XML -AS String -NoTypeInformation -Depth 1 
                }   
                else 
				{ 
                    $DR.Item($property.Name) = $property.value 
                } 
            }   
            $DT.Rows.Add($DR)   
            $First = $false 
        } 
    }    
    End 
    { 
        Write-Output @(,($dt)) 
    } 
}

#############################
#	  Run SQL Commands
#	Based on: https://github.com/Proxx/PowerShell/blob/master/Network/Invoke-SQL.ps1
#############################
function Invoke-SQL 
{
    param
	(
        [string] $dataSource,
        [string] $database,
        [string] $sqlCommand
    )
    $connectionString = "Data Source=$dataSource; " +
            "Integrated Security=SSPI; " +
            "Initial Catalog=$database"

    $connection = new-object system.data.SqlClient.SQLConnection($connectionString)
    $command = new-object system.data.sqlclient.sqlcommand($sqlCommand,$connection)
    $connection.Open()

    $adapter = New-Object System.Data.sqlclient.sqlDataAdapter $command
    $dataset = New-Object System.Data.DataSet
    $adapter.Fill($dataSet) | Out-Null

    $connection.Close()
    $dataSet.Tables

}

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

Verbose -Message "Collecting Database Information..."

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
	  	Verbose -Message "Server: $SubConnection"
	  	$DataPull = Invoke-SQL -datasource $SubConnection -database master -sqlCommand  "
		with fs
		as
		(
		    select database_id, type, size * 8.0 / 1024 size
		    from sys.master_files
		)
		select 
			$InstanceID AS 'InstanceId',
			name,
		    (SELECT	CASE WHEN CAST(SUM(size) AS INT) < 1
					THEN 1
					ELSE CAST(SUM(size) AS INT)
					END

			FROM	fs
			WHERE	type = 0
				AND fs.database_id = db.database_id) AS DataFileSizeMB
		from sys.databases db
		ORDER BY DataFileSizeMB
		"		
	}
	Catch [System.Data.SqlClient.SqlException]
	{
		Verbose -Message "Cannot Collect Information on $SubConnection"
		Verbose -Message "$_"
	}

	foreach ($Row in $DataPull.Rows)
	{ 
		$Size = $Row[2]
		$DatabaseName = $($Row[1])
		$InstanceListId = $Row[0]

		Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand "
		EXEC dbo.prInsertDatabaseList
			 @DatabaseName = '$DatabaseName'
			,@InstanceListId = '$InstanceListId'
			,@Size = $Size
		
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
		Verbose -Message "Cannot Collect Information on $SubConnection"
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
Verbose -Message "Done."
