#--------------------
#Owner: Charlton E Julius
#Update: 2023-04-05
#Purpose: Builds GUI front-end for Datapull
#--------------------


#Point to Repository Instance.DB
param(
[string]$RepositoryInstance 	= '(local)',		#Repository Server\Instance
[string]$RepositoryDB 			= 'DBAdmin'		#Repository Database
)

cls

#############################
#   GET TYPE OF DATA
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
#############################

function Invoke-SQL 
{
    param
	(
        [string] $dataSource,
        [string] $database,
        [string] $sqlCommand,
        [int] $timeout = 60
    )
    $connectionString = "Data Source=$dataSource; " +
            "Integrated Security=SSPI; " +
            "Initial Catalog=$database"

    $connection = new-object system.data.SqlClient.SQLConnection($connectionString)
    $command = new-object system.data.sqlclient.sqlcommand($sqlCommand,$connection)
    $connection.Open()

    $adapter = New-Object System.Data.sqlclient.sqlDataAdapter $command
    $adapter.SelectCommand.CommandTimeout = $timeout
    $dataset = New-Object System.Data.DataSet
    $adapter.Fill($dataSet) | Out-Null

    $connection.Close()
    $dataSet.Tables

}


#############################
#	  Get System Info
#############################

$SDIMInfo = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand "
		EXEC [Utility].[prSDIMInfo];
	"
foreach ($Row in $SDIMInfo)
	{ 
    [string]$LastRun = $($Row[1])
    [string]$Version = $($Row[0])
    }

#############################
#  		Build Form
#http://foxdeploy.com/2015/04/10/part-i-creating-powershell-guis-in-minutes-using-visual-studio-a-new-hope/
#############################

$inputXML = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="SDIM v$Version" Height="295" Width="479">
    <Grid Margin="0,0,2,11">
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="310*"/>
            <ColumnDefinition Width="79*"/>
        </Grid.ColumnDefinitions>

        <Label Content="Inventory" HorizontalAlignment="Left" Margin="19,10,0,0" VerticalAlignment="Top"/>
        <Button Name="Bt_Services" Content="Services" HorizontalAlignment="Left" Margin="11,35,0,0" VerticalAlignment="Top" Width="85"/>
        <Button Name="Bt_Servers" Content="Servers" HorizontalAlignment="Left" Margin="11,60,0,0" VerticalAlignment="Top" Width="85"/>
        <Button Name="Bt_Instances" Content="Instances" HorizontalAlignment="Left" Margin="11,85,0,0" VerticalAlignment="Top" Width="85"/>
        <Button Name="Bt_Server_Instance" Content="Server\Instance" HorizontalAlignment="Left" Margin="102,71,0,0" VerticalAlignment="Top" Width="85"/>
        <Button Name="Bt_Databases" Content="Databases" HorizontalAlignment="Left" Margin="11,110,0,0" VerticalAlignment="Top" Width="85"/>
        <Button Name="Bt_Instance_DB" Content="Instance\DB" HorizontalAlignment="Left" Margin="101,96,0,0" VerticalAlignment="Top" Width="85"/>
        <Button Name="Bt_Tables" Content="Tables" HorizontalAlignment="Left" Margin="11,135,0,0" VerticalAlignment="Top" Width="85"/>
		<Button Name="Bt_Jobs" Content="Jobs" HorizontalAlignment="Left" Margin="11,160,0,0" VerticalAlignment="Top" Width="85"/>
		<Button Name="Bt_JobsExt" Content="Jobs Extended" HorizontalAlignment="Left" Margin="101,160,0,0" VerticalAlignment="Top" Width="85"/>
		<Button Name="Bt_SrvPerms" Content="Server Perms" HorizontalAlignment="Left" Margin="11,185,0,0" VerticalAlignment="Top" Width="85"/>
		<Button Name="Bt_DBPerms" Content="DB Perms" HorizontalAlignment="Left" Margin="101,185,0,0" VerticalAlignment="Top" Width="85"/>
        <Button Name="Bt_All_Data" Content="Full Inventory" HorizontalAlignment="Left" Margin="11,220,0,0" VerticalAlignment="Top" Width="85"/>

        <Label Content="Reporting" HorizontalAlignment="Left" Margin="273,10,0,0" VerticalAlignment="Top"/>
        <Button Name="Bt_GetServersGroup_OS_SP" Content="Servers Grouped by &#xD;&#xA;OS and Service Pack" HorizontalAlignment="Left" Margin="273,35,0,0" VerticalAlignment="Top" Width="185" Height="37" Grid.ColumnSpan="2"/>
        <Button Name="Bt_GetInstancesGroup_SQLVer" Content="Instances Grouped By&#xD;&#xA;        SQL Version" HorizontalAlignment="Left" Margin="273,77,0,0" VerticalAlignment="Top" Width="185" Height="37" Grid.ColumnSpan="2"/>
        <Button Name="Bt_GetInstancesGroup_SQLVer_SQLEd" Content="Instances Grouped By&#xD;&#xA; SQL Version, Edition" HorizontalAlignment="Left" Margin="274,119,0,0" VerticalAlignment="Top" Width="185" Height="37" Grid.ColumnSpan="2"/>
        <Button Name="Bt_GetInstancesGroup_SQLVer_SQLEd_SQLSP" Content="    Instances Grouped By&#xD;&#xA;SQL Version, Edition and SP/CU" HorizontalAlignment="Left" Margin="274,161,0,0" VerticalAlignment="Top" Width="185" Height="37" Grid.ColumnSpan="2"/>

        <Button Name="Bt_Exit" Content="Exit" HorizontalAlignment="Left" Margin="0,220,0,0" VerticalAlignment="Top" Width="85" Grid.Column="1"/>

        <Label Content="Last Run:" HorizontalAlignment="Left" Margin="150,216,0,0" VerticalAlignment="Top"/>
        <TextBox HorizontalAlignment="Left" Height="21" Margin="205,220,0,0" Text="$LastRun" VerticalAlignment="Top" Width="100" Grid.ColumnSpan="2"/>

    </Grid>
</Window>
"@       
 
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML

#Read XAML
$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
	try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
	catch{Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."}
 
# Load XAML Objects In PowerShell
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}

#############################
#	  Get Table Data
#############################
$WPFBt_Tables.Add_Click(
	{
	$sqlCommand = "
	EXEC dbo.prGetTables
	"

	$dataset = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand $sqlCommand
	Write-Host $dataset

	$dataset | Out-GridView -Title "Table Inventory"
	}
)


#############################
#	  Get All Data
#############################
$WPFBt_All_Data.Add_Click(
	{
	$sqlCommand = "
	EXEC dbo.prGetInventory;
	"

	$dataset = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand $sqlCommand
	Write-Host $dataset

	$dataset | Out-GridView -Title "Database Inventory"
	}
)

#############################
#	Get Server Information
#############################
$WPFBt_Servers.Add_Click(
	{
	$sqlCommand = "
		EXEC dbo.prGetServers;
	"

	$dataset = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand $sqlCommand
	Write-Host $dataset

	$dataset | Out-GridView -Title "Server Inventory"
	}
)

#############################
#	Get Instance Information
#############################
$WPFBt_Instances.Add_Click(
	{
	$sqlCommand = "
		EXEC dbo.prGetInstances;
	"

	$dataset = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand $sqlCommand
	Write-Host $dataset

	$dataset | Out-GridView -Title "Instance Inventory"

	}
)

#############################
#	Get Database Information
#############################
$WPFBt_Databases.Add_Click(
	{
	$sqlCommand = "
		EXEC dbo.prGetDatabasesAndSize;
	"

	$dataset = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand $sqlCommand
	Write-Host $dataset

	$dataset | Out-GridView -Title "Database and Size Inventory"
	}
)

#############################
#	Get Services Information
#############################
$WPFBt_Services.Add_Click(
	{
	$sqlCommand = "
		EXEC [dbo].[prGetServerServices];
	"

	$dataset = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand $sqlCommand
	Write-Host $dataset

	$dataset | Out-GridView -Title "Service Inventory"
	}
)



#############################
#	Get Server\Instance
#############################
$WPFBt_Server_Instance.Add_Click(
	{
	$sqlCommand = "
		EXEC [dbo].[prGetServersAndInstances];
	"

	$dataset = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand $sqlCommand
	Write-Host $dataset

	$dataset | Out-GridView -Title "Server\Instance Inventory"
	}
)

#############################
#	Get Instance\DB
#############################
$WPFBt_Instance_DB.Add_Click(
	{
	$sqlCommand = "
		EXEC [dbo].[prGetInstancesAndDatabases];
	"

	$dataset = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand $sqlCommand
	Write-Host $dataset

	$dataset | Out-GridView -Title "Server\Instance Inventory"
	}
)

#############################
#	Get Job Information
#############################
$WPFBt_Jobs.Add_Click(
	{
	$sqlCommand = "
		EXEC dbo.prGetjobs;
	"

	$dataset = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand $sqlCommand
	Write-Host $dataset

	$dataset | Out-GridView -Title "SQL Jobs"
	}
)

#############################
#	Get Job Ext Information
#############################
$WPFBt_JobsExt.Add_Click(
	{
	$sqlCommand = "
		EXEC dbo.prGetjobsExt;
	"

	$dataset = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand $sqlCommand
	Write-Host $dataset

	$dataset | Out-GridView -Title "SQL Jobs Extended"
	}
)

#############################
#	Get Server Permission Information
#############################
$WPFBt_SrvPerms.Add_Click(
	{
	$sqlCommand = "
		EXEC dbo.prGetSrvPermissions;
	"

	$dataset = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand $sqlCommand
	Write-Host $dataset

	$dataset | Out-GridView -Title "Server Permissions"
	}
)


#############################
#	Get DB Permission Information
#############################
$WPFBt_DBPerms.Add_Click(
	{
	$sqlCommand = "
		EXEC dbo.prGetDBPermissions;
	"

	$dataset = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand $sqlCommand
	Write-Host $dataset

	$dataset | Out-GridView -Title "Database Permissions"
	}
)



###########
#############################
# REPORTING
#############################
###########


#############################
#	Get ServersGroup_OS_SP
#############################
$WPFBt_GetServersGroup_OS_SP.Add_Click(
	{
	$sqlCommand = "
		EXEC [dbo].[prGetServersGroup_OS_SP];
	"

	$dataset = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand $sqlCommand
	Write-Host $dataset

	$dataset | Out-GridView -Title "Servers Grouped by OS and OS Service Pack"
	}
)

#############################
#	Get InstancesGroup_SQLVer
#############################
$WPFBt_GetInstancesGroup_SQLVer.Add_Click(
	{
	$sqlCommand = "
		EXEC [dbo].[prGetInstancesGroup_SQLVer];
	"

	$dataset = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand $sqlCommand
	Write-Host $dataset

	$dataset | Out-GridView -Title "SQL Instances Grouped By SQL Version"
	}
)

#############################
#	Get Instances Group_SQLVer_SQLEd
#############################
$WPFBt_GetInstancesGroup_SQLVer_SQLEd.Add_Click(
	{
	$sqlCommand = "
		EXEC [dbo].[prGetInstancesGroup_SQLVer_SQLEd];
	"

	$dataset = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand $sqlCommand
	Write-Host $dataset

	$dataset | Out-GridView -Title "SQL Instances Grouped By SQL Version and Edition"
	}
)

#############################
#	Get InstancesGroup_SQLVer_SQLEd_SQLSP
#############################
$WPFBt_GetInstancesGroup_SQLVer_SQLEd_SQLSP.Add_Click(
	{
	$sqlCommand = "
		EXEC [dbo].[prGetInstancesGroup_SQLVer_SQLEd_SQLSP];
	"

	$dataset = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand $sqlCommand
	Write-Host $dataset

	$dataset | Out-GridView -Title "SQL Instances Grouped By SQL Version, Edition and Service Pack"
	}
)

#############################
#		Close Form
#############################
$WPFBt_Exit.Add_Click(
	{
	$Form.Close()
	}
)

#############################
#		Display Form
#############################
$Form.ShowDialog() | out-null
