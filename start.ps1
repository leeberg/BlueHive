# BlueHive Start Script

# Set These Variables - and populate the Credential Object
$Credential = Get-Credential
$DomainControllerFQDN = 'BC-DC.berg.com'
$BlueHiveFolder = 'C:\Users\lee\git\BlueHive'
$AutoLoginServer = 'BC-DC.berg.com'

Import-Module .\bluehive.psd1 -Force

Get-UDDashboard | Stop-UDDashboard
Get-UDRestApi | Stop-UDRestAPI
Start-BHDash -Server $DomainControllerFQDN -Credential $Credential -BlueHiveFolder $BlueHiveFolder -AutoLoginServer $AutoLoginServer 