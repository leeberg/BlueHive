function Start-BHDash {

    param(
        [string]$BlueHiveFolder,
        [string]$Server,
        [string]$AutoLoginServer,
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

    #Special Functions Path
    $Cache:AutoLoginTrackerFile = $Cache:BHManagedPath + '\AutoLogins.json'

    # Create Folders / Log Files
    if((Test-Path -Path $Cache:BHRetrievedPath) -eq $false){New-Item -Path $Cache:BHRetrievedPath -ItemType Directory}
    if((Test-Path -Path $Cache:BHDomainPath) -eq $false){New-Item -Path $Cache:BHDomainPath -ItemType Directory}
    if((Test-Path -Path $Cache:BHManagedPath) -eq $false){New-Item -Path $Cache:BHManagedPath -ItemType Directory}
    if((Test-Path -Path $Cache:BHLogFolderPath) -eq $false){New-Item -Path $Cache:BHLogFolderPath -ItemType Directory}
    if((Test-Path -Path $Cache:BHLogFilePath) -eq $false){New-Item -Path $Cache:BHLogFilePath -ItemType File}
    if((Test-Path -Path $Cache:BHErrorFilePath) -eq $false){New-Item -Path $Cache:BHErrorFilePath -ItemType File}
    if((Test-Path -Path $Cache:AutoLoginTrackerFile) -eq $false){New-Item -Path $Cache:AutoLoginTrackerFile -ItemType File}

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

    # Import Active Directory
    Import-Module ActiveDirectory

    Try{
        $ADDrive = Get-PSDrive -Name AD -ErrorAction SilentlyContinue 
        if($ADDrive){Remove-PSDrive -Name AD}
    }
    Catch {
        # Probably not there yet.
    }
    
    # Connect to AD
    New-PSDrive -Name AD -PSProvider ActiveDirectory @Cache:ConnectionInfo -Root "//RootDSE/" -Scope Global

    $Pages = @()
    $Pages += . (Join-Path $PSScriptRoot "pages\home.ps1")

    Get-ChildItem (Join-Path $PSScriptRoot "pages") -Exclude "home.ps1" | ForEach-Object {
        $Pages += . $_.FullName
    }



    # Scheduled Endpoints for User Logins
    $Cache:AutoLoginServer = $AutoLoginServer

    #TODO Make the Schedule Configurable
    $10MinSchedule = New-UDEndpointSchedule -Every 10 -Minute
    
    $AutoLoginEndpoint = New-UDEndpoint -Schedule $10MinSchedule -Endpoint {
        
        $AutoLoginAccounts = Get-HoneyUserAutoLogin
        ForEach($HoneyUser in $AutoLoginAccounts)
        {
                #Get the Extended User Details from Local Storage
                $HoneyUserDetails = Get-BHDHoneyUserDetailsData -DistinguishedName $HoneyUser.DistinguishedName

                #Reset the Honey User Password
                $RandomPassword = ConvertTo-SecureString -String (([char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126)) + 0..9 | sort {Get-Random})[0..8] -join '') -AsPlainText -Force
                Set-ADAccountPassword -Identity $HoneyUser.DistinguishedName -Reset -NewPassword $RandomPassword @Cache:ConnectionInfo 
                $HoneyCred = New-Object System.Management.Automation.PSCredential(($HoneyUserDetails.ParentNetBios+'\'+$HoneyUserDetails.name),$RandomPassword)

                #Login to your Specified Login Server, Run a command, and Close Session
                $HoneySession = New-PSSession -Credential $HoneyCred -ComputerName $Cache:AutoLoginServer
                $Command = Invoke-Command $HoneySession -Scriptblock { Get-AdUser -Identity $args[0] } -ArgumentList ($HoneyUser.DistinguishedName)
                Remove-PSSession -Session $HoneySession

                # Update Local Honey Auto Login Record
                Set-HoneyUserAutoLogin -UserDistinguishedName $HoneyUser.DistinguishedName -AutoLoginSetting $true -LoginTime (Get-Date -format u) -isUpdate $true

                #Reset the Honey User Password (LOL SECURITY?)
                $RandomPassword = ConvertTo-SecureString -String (([char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126)) + 0..9 | sort {Get-Random})[0..8] -join '') -AsPlainText -Force
                Set-ADAccountPassword -Identity $HoneyUser.DistinguishedName -Reset -NewPassword $RandomPassword @Cache:ConnectionInfo 
                
        }
    }


    #Startup the Dashboard
    # TODO add AutoLogin Endpoint
    $BHEndpoints = New-UDEndpointInitialization -Module @("Modules\Honey\Honey.psm1", "Modules\Honey\HoneyAD.psm1", "Modules\Honey\HoneyData.psm1") 
    
    $Dashboard = New-UDDashboard -Title "BlueHive 🐝 🍯 🐝" -Pages $Pages -EndpointInitialization $BHEndpoints  -Theme $DarkDefault

    Try{

        Start-UDDashboard -Dashboard $Dashboard -Port 10000 -Endpoint $AutoLoginEndpoint

    }
    Catch
    {
        Write-Error($_.Exception)
    }
    



}
