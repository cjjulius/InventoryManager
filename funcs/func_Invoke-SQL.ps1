#############################
#	  Run SQL Commands
#	Based on: https://github.com/Proxx/PowerShell/blob/master/Network/Invoke-SQL.ps1
#   Updated: 2023-03-13
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