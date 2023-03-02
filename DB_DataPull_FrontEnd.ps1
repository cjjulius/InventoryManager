#--------------------
#Owner: Charlton E Julius
#Update: 2023-03-02
#Purpose: Builds GUI front-end for Datapull
#Version: 2.4
#--------------------


#Point to Repository Instance.DB
param(
[string]$RepositoryInstance 	= '(local)',		#Repository Server\Instance
[string]$RepositoryDB 			= 'DBAdmin'			#Repository Database
)

#############################
#  		XAML code Reader
#http://foxdeploy.com/2015/04/10/part-i-creating-powershell-guis-in-minutes-using-visual-studio-a-new-hope/
#############################
$inputXML = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="DB_DataPull_FrontEnd" Height="285" Width="479">
    <Grid Margin="0,0,2,11">
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="310*"/>
            <ColumnDefinition Width="79*"/>
        </Grid.ColumnDefinitions>
        <Label Content="Inventory" HorizontalAlignment="Left" Margin="19,10,0,0" VerticalAlignment="Top"/>
        <Button Name="Bt_All_Data" Content="Full Inventory" HorizontalAlignment="Left" Margin="10,170,0,0" VerticalAlignment="Top" Width="85"/>
        <Button Name="Bt_Servers" Content="Servers" HorizontalAlignment="Left" Margin="11,60,0,0" VerticalAlignment="Top" Width="85"/>
        <Button Name="Bt_Instances" Content="Instances" HorizontalAlignment="Left" Margin="11,85,0,0" VerticalAlignment="Top" Width="85"/>
        <Button Name="Bt_Databases" Content="Databases" HorizontalAlignment="Left" Margin="11,110,0,0" VerticalAlignment="Top" Width="85"/>
		<Button Name="Bt_Jobs" Content="Jobs" HorizontalAlignment="Left" Margin="11,135,0,0" VerticalAlignment="Top" Width="85"/>
        <Button Name="Bt_Services" Content="Services" HorizontalAlignment="Left" Margin="11,35,0,0" VerticalAlignment="Top" Width="85"/>
        <Button Name="Bt_Exit" Content="Exit" HorizontalAlignment="Left" Margin="0,211,0,0" VerticalAlignment="Top" Width="85" Grid.Column="1"/>
        <Button Name="Bt_Server_Instance" Content="Server\Instance" HorizontalAlignment="Left" Margin="102,71,0,0" VerticalAlignment="Top" Width="85"/>
        <Button Name="Bt_Instance_DB" Content="Instance\DB" HorizontalAlignment="Left" Margin="101,96,0,0" VerticalAlignment="Top" Width="85"/>
		<Button Name="Bt_JobsExt" Content="Jobs Extended" HorizontalAlignment="Left" Margin="101,135,0,0" VerticalAlignment="Top" Width="85"/>
        <Label Content="Reporting" HorizontalAlignment="Left" Margin="273,10,0,0" VerticalAlignment="Top"/>
        <Button Name="Bt_GetServersGroup_OS_SP" Content="Servers Grouped by &#xD;&#xA;OS and Service Pack" HorizontalAlignment="Left" Margin="273,35,0,0" VerticalAlignment="Top" Width="185" Height="37" Grid.ColumnSpan="2"/>
        <Button Name="Bt_GetInstancesGroup_SQLVer" Content="Instances Grouped By&#xD;&#xA;        SQL Version" HorizontalAlignment="Left" Margin="273,77,0,0" VerticalAlignment="Top" Width="185" Height="37" Grid.ColumnSpan="2"/>
        <Button Name="Bt_GetInstancesGroup_SQLVer_SQLEd" Content="Instances Grouped By&#xD;&#xA; SQL Version, Edition" HorizontalAlignment="Left" Margin="274,119,0,0" VerticalAlignment="Top" Width="185" Height="37" Grid.ColumnSpan="2"/>
        <Button Name="Bt_GetInstancesGroup_SQLVer_SQLEd_SQLSP" Content="    Instances Grouped By&#xD;&#xA;SQL Version, Edition and SP" HorizontalAlignment="Left" Margin="274,161,0,0" VerticalAlignment="Top" Width="185" Height="37" Grid.ColumnSpan="2"/>
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
#	  Run SQL Commands
#Based on: https://github.com/Proxx/PowerShell/blob/master/Network/Invoke-SQL.ps1
#############################
function Invoke-SQL {
    param
	(
        [string] $dataSource,
        [string] $database,
        [string] $sqlCommand
    )
	Write-Host $sqlCommand
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
