# BlueHive Start Script

$Credential = Get-Credential
$DomainControllerFQDN = 'BC-DC.berg.com'

Import-Module .\bluehive.psd1 -Force
Import-Module .\Modules\Honey\Honey.psm1 -Force
Import-Module .\Modules\Honey\HoneyAD.psm1 -Force
Import-Module .\Modules\Honey\HoneyData.psm1 -Force

Get-UDDashboard | Stop-UDDashboard
Get-UDRestApi | Stop-UDRestAPI
Start-BHDash -Server $DomainControllerFQDN -Credential $Credential

