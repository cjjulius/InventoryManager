#############################
# Verbose and Debug Messages
# Writes to log/host debug info
#############################

Function Verbose {
	Param(  [string]$Message
           ,[string]$LogName	= "DB_DataPull_Log"
           ,[string]$Today  	= $(Get-Date -Format "yyyy-MM-dd")
         )

    $LogFullLocation = "$LogDir\$LogName" + "_" + $Today + ".txt"
	
	if ($Verbose){
		Write-Host $Message
		
		if ($LogDirExists){
			Add-Content $LogFullLocation $Message
		}
	}
	
	if ($Debug) {
		
		if ($LogDirExists){
			Add-Content $LogFullLocation $Message
		}	
	}
}