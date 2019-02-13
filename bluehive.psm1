function Start-BHDash {
    
    Write-AuditLog -BSLogContent "Starting BlueHive!"

    $Pages = @()
    $Pages += . (Join-Path $PSScriptRoot "pages\home.ps1")

    Get-ChildItem (Join-Path $PSScriptRoot "pages") -Exclude "home.ps1" | ForEach-Object {
    #    $Pages += . $_.FullName
    }
    
    $BSEndpoints = New-UDEndpointInitialization -Module @("PowerShellModules\Empire\BlueHiveData.psm1", "PowerShellModules\Empire\BlueHiveEmpire.psm1")

    $Dashboard = New-UDDashboard -Title "BlueHive 🐝 🍯 🐝" -Pages $Pages -EndpointInitialization $BSEndpoints 
    Try{
        Start-UDDashboard -Dashboard $Dashboard -Port 10000 
        Write-AuditLog -BSLogContent "BlueHive Started!"
    }
    Catch
    {
        Write-Error($_.Exception)
        Write-AuditLog -BSLogContent "BlueHive Failed to Start!"
    }
    



}

function Start-BHAPI{

    ### Haven't messed around with this at all
    ### Next Step to replace module calls with API Calls?

    $Endpoints = @()

    $Endpoints += New-UDEndpoint -url 'GetEmpireModules' -Endpoint {
        Get-BSEmpireModuleData | ConvertTo-Json
        
    }

    Start-UDRestApi -Endpoint $Endpoints -Port 10001 -AutoReload




}