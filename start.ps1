
#First Time Setup for Debuggin'

#$Credential = Get-Credential

Import-Module .\bluehive.psd1 -Force
Import-Module .\PowerShellModules\Honey\Honey.psm1 -Force
Import-Module .\PowerShellModules\Honey\HoneyAD.psm1 -Force
Import-Module .\PowerShellModules\Honey\HoneyData.psm1 -Force

Get-UDDashboard | Stop-UDDashboard
Get-UDRestApi | Stop-UDRestAPI
Start-BHDash -Server 'BC-DC.berg.com' -Credential $Credential -BlueHiveFolder 'C:\Users\lee\git\BlueHive'

