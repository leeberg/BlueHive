function Start-BHDash {

    param(
        [string]$BlueHiveFolder,
        [string]$Server,
        [PSCredential]$Credential,
        [int]$Port = 10000
    )

    # This Caches the Connection Info so the other components and modules can utilze them
    $Cache:ConnectionInfo = @{
        Server = $Server
        Credential = $Credential
    }

    #### DATA FOLDER SETUP - Cache Variables utilzed by "HoneyData Module"
    # TODO would be neat to turn into an objects

    # Setup-BHDataPaths
    $Cache:BlueHiveFolder = $BlueHiveFolder

    #Retrieved Data
    $Cache:BHRetrievedPath =  $Cache:BlueHiveFolder + '\Data\Retrieved'
    $Cache:BHDomainPath =  $Cache:BlueHiveFolder + '\Data\Retrieved\Domains'
    $Cache:BHManagedPath =  $Cache:BlueHiveFolder + '\Data\Managed'

    #LOG Paths
    $Cache:BHLogFilePath = $Cache:BlueHiveFolder + '\Data\Logs\AuditLog.log' 
    $Cache:BHErrorFilePath = $Cache:BlueHiveFolder + '\Data\Logs\ErrorLog.log'
    $Cache:BHLogFolderPath = $Cache:BlueHiveFolder + '\Data\Logs' 
    $Cache:BHDeploymentHistoryFilePath = $Cache:BlueHiveFolder + '\Data\Logs\Deployment.json'

    #Data Generation Resources Path
    $Cache:BSFirstNamesFile = $Cache:BlueHiveFolder + '\Data\Generation\FirstNames.txt'
    $Cache:BSLastNamesFile = $Cache:BlueHiveFolder + '\Data\Generation\LastNames.txt'
    $Cache:BSServiceAccountNamesFile = $Cache:BlueHiveFolder + '\Data\Generation\service-accounts.txt'


    # Create Folders / Log Files
    if((Test-Path -Path $Cache:BHRetrievedPath) -eq $false){New-Item -Path $Cache:BHRetrievedPath -ItemType Directory}
    if((Test-Path -Path $Cache:BHDomainPath) -eq $false){New-Item -Path $Cache:BHDomainPath -ItemType Directory}
    if((Test-Path -Path $Cache:BHLogFoBHManagedPathlderPath) -eq $false){New-Item -Path $Cache:BHManagedPath -ItemType Directory}
    if((Test-Path -Path $Cache:BHLogFolderPath) -eq $false){New-Item -Path $Cache:BHLogFolderPath -ItemType Directory}
    if((Test-Path -Path $Cache:BHLogFilePath) -eq $false){New-Item -Path $Cache:BHLogFilePath -ItemType File}
    if((Test-Path -Path $Cache:BHErrorFilePath) -eq $false){New-Item -Path $Cache:BHErrorFilePath -ItemType File}

    ####

    #### THEME    
    
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
        if($ADDrive){Remove-PSDrive -Name AD}
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



    # Scheduled Endpoints for User Logins
    $10MinSchedule = New-UDEndpointSchedule -Every 10 -Minute 
    
    $Endpoint = New-UDEndpoint -Schedule $10MinSchedule -Endpoint {
        
        $HoneyAccounts = Get-BHHoneyAccountData
        ForEach($HoneyUser in $HoneyAccounts)
        {
            if($HoneyUser.AutoLogin -eq 'Enabled')
            {
                
                $RandomPassword = ConvertTo-SecureString -String (([char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126)) + 0..9 | sort {Get-Random})[0..8] -join '') -AsPlainText -Force
                Set-ADAccountPassword -Identity $HoneyUser.DistinguishedName -Reset -NewPassword $RandomPassword @Cache:ConnectionInfo 
                $HoneyCred = New-Object System.Management.Automation.PSCredential(($HoneyUser.ParentNetBios+'\'+$HoneyUser.name),$RandomPassword)

                $HoneySession = New-PSSession -Credential $HoneyCred -ComputerName 'BC-DC.berg.com'
                Invoke-Command $HoneySession -Scriptblock { get-aduser -filter * }
                Remove-PSSession -Session $HoneySession

                          
            }
            

        }
    }


    <#

    #>



    
    $BSEndpoints = New-UDEndpointInitialization -Module @("Modules\Honey\Honey.psm1", "Modules\Honey\HoneyAD.psm1", "Modules\Honey\HoneyData.psm1")
    $Dashboard = New-UDDashboard -Title "BlueHive 🐝 🍯 🐝" -Pages $Pages -EndpointInitialization $BSEndpoints -Theme $DarkDefault

    Try{
        Write-AuditLog -BSLogContent "Starting BlueHive!"
        Start-UDDashboard -Dashboard $Dashboard -Port 10000 
        Write-AuditLog -BSLogContent "BlueHive Started!"
    }
    Catch
    {
        Write-Error($_.Exception)
        Write-AuditLog -BSLogContent "BlueHive Failed to Start!"
    }
    



}
