Import-Module .\bluehive.psd1 -Force
Import-Module .\PowerShellModules\Honey\Honey.psm1 -Force
Import-Module .\PowerShellModules\Honey\HoneyAD.psm1 -Force
Import-Module .\PowerShellModules\Honey\HoneyData.psm1 -Force

Get-UDDashboard | Stop-UDDashboard
Get-UDRestApi | Stop-UDRestAPI
Start-BHDash
