$Credential = Get-Credential

Import-Module .\bluehive.psd1 -Force
Import-Module .\Modules\Honey\Honey.psm1 -Force
Import-Module .\Modules\Honey\HoneyAD.psm1 -Force
Import-Module .\Modules\Honey\HoneyData.psm1 -Force

Get-UDDashboard | Stop-UDDashboard
Get-UDRestApi | Stop-UDRestAPI
Start-BHDash -Server 'BC-DC.berg.com' -Credential $Credential

