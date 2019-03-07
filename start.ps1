
#First Time Setup DEbug
#DERP
$Credential = Get-Credential
$session = New-PSSession -ComputerName "192.168.200.130" -Credential $Credential
Invoke-Command $session -Scriptblock { Import-Module ActiveDirectory }
Import-PSSession -Session $session -module ActiveDirectory -AllowClobber


Import-Module .\bluehive.psd1 -Force
Import-Module .\PowerShellModules\Honey\Honey.psm1 -Force
Import-Module .\PowerShellModules\Honey\HoneyAD.psm1 -Force
Import-Module .\PowerShellModules\Honey\HoneyData.psm1 -Force

Get-UDDashboard | Stop-UDDashboard
Get-UDRestApi | Stop-UDRestAPI
Start-BHDash
