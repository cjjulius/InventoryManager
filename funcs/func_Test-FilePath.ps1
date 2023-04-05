#############################
# 		Test File Path
# Tests a file path and returns if exists
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