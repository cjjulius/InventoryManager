#--------------------
#Owner: 	Charlton E Julius
#Date: 		2016-11-14
#Version: 	2.1
#Purpose: 	Fills Repository with server\instance.database information
#--------------------

param(
[string]$RepositoryInstance 	= '(local)',				#Repository Server\Instance
[string]$RepositoryDB 			= 'DBAdmin' ,					#Repository Database
[string]$CMSServer				= 'SOMESERVER' ,				#CMS location if applicable
[string]$LogDir 				= "C:\Test\" ,					#Directory to save Log
[switch]$UseCMS					= $false	,						#Toggle to use CMS
[switch]$Verbose 				= $false ,                		#Show Verbose information
[switch]$Debug 					= $false 						#Show Debug information
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
	ORDER BY server_name;
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
		SELECT  SERVERPROPERTY('productversion'), SERVERPROPERTY ('productlevel'), SERVERPROPERTY ('edition'), @@VERSION
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
		
		Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand "
		EXEC dbo.prUpdateInstanceList 
			 @MSSQLVersionLong = '$MSSQLVersionLong'
			,@MSSQLVersion = '$MSSQLVersion'
			,@MSSQLEdition = '$MSSQLEdition'
			,@MSSQLServicePack = '$MSSQLServicePack'
			,@InstanceId = $InstanceID	
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
	Try
		{
		If (Test-Connection  $Server -Count 1 -Quiet)
			{
			$ips = [System.Net.Dns]::GetHostAddresses($($Row[0]))
			
			$OSName = $((Get-WmiObject -computerName $($Server) -class Win32_OperatingSystem -ErrorAction SilentlyContinue).Caption)
			$OSServicePack = $((Get-WmiObject -computerName $($Server) -class Win32_OperatingSystem -ErrorAction SilentlyContinue).ServicePackMajorVersion)
			
			Verbose -Message "OS SP: $OSServicePack"
			
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