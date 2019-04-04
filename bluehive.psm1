function Start-BHDash {

    param(
        [string]$BlueHiveFolder,
        [string]$Server,
        [PSCredential]$Credential,
        [int]$Port = 10000
    )

    Write-AuditLog -BSLogContent "Starting BlueHive!"

    #$Cache:Loading = $true
    #$Cache:ChartColorPalette = @('#5899DA', '#E8743B', '#19A979', '#ED4A7B', '#945ECF', '#13A4B4', '#525DF4', '#BF399E', '#6C8893', '#EE6868', '#2F6497')
    
    $Cache:ConnectionInfo = @{
        Server = $Server
        Credential = $Credential
    }
    
    $Cache:BlueHiveInfo = @{
        BlueHiveFolder = $BlueHiveFolder

    }

    $DarkDefault = New-UDTheme -Name "Basic" -Definition @{
        UDDashboard = @{
            BackgroundColor = "#393F47"
            FontColor = "#FFFFFF"
        }
        UDNavBar = @{
            BackgroundColor =  "#272C33"
            FontColor = "#FFFFFF"
        }
        UDFooter = @{
            BackgroundColor =  "#272C33"
            FontColor = "#FFFFFF"
        }


        UDCard = @{
            BackgroundColor = "#272C33"
            FontColor = "#FFFFFF"
        }
        UDChart = @{
            BackgroundColor = "#272C33"
            FontColor = "#FFFFFF"
        }
        UDMonitor = @{
            BackgroundColor = "#272C33"
            FontColor = "#FFFFFF"
        }
        UDTable = @{
            BackgroundColor = "#272C33"
            FontColor = "#FFFFFF"
        }
        UDGrid = @{
            BackgroundColor = "#272C33"
            FontColor = "#FFFFFF"
        }
        UDCounter = @{
            BackgroundColor = "#272C33"
            FontColor = "#FFFFFF"
        }
        UDInput = @{
            BackgroundColor = "#272C33"
            FontColor = "#FFFFFF"
        }
    }


    Import-Module ActiveDirectory

    Try{
        $ADDrive = Get-PSDrive -Name AD -ErrorAction SilentlyContinue 
        if($ADDrive){Remove-PSDrive}
    }
    Catch {
        # Probably not there yet.
    }
    

    
    New-PSDrive –Name AD –PSProvider ActiveDirectory @Cache:ConnectionInfo –Root "//RootDSE/" -Scope Global 


    $Pages = @()
    $Pages += . (Join-Path $PSScriptRoot "pages\home.ps1")

    Get-ChildItem (Join-Path $PSScriptRoot "pages") -Exclude "home.ps1" | ForEach-Object {
        $Pages += . $_.FullName
    }
    
    $BSEndpoints = New-UDEndpointInitialization -Module @("PowerShellModules\Honey\Honey.psm1", "PowerShellModules\Honey\HoneyAD.psm1", "PowerShellModules\Honey\HoneyData.psm1")
    $Dashboard = New-UDDashboard -Title "BlueHive 🐝 🍯 🐝" -Pages $Pages -EndpointInitialization $BSEndpoints -Theme $DarkDefault

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
