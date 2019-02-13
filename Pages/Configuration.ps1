New-UDPage -Name "Empire - Configuration" -Icon gears -Content {

    $ExistingTokens = Get-BSNetworkScanData
    $ExistingAccounts = Get-BSNetworkScanData
    $ValidEmpireNetworkResources = @()

    ForEach($Resource in $NetworkResources)
    {
        if($Resource.isEmpire -eq 'YES')
        {
            $ValidEmpireNetworkResources = $ValidEmpireNetworkResources + $Resource
           
        }
        else
        {
            #NOT EMPIRE SERVER
        }
    }





    $EmpireConfig = Get-BSEmpireConfigData
  


    New-UDLayout -Columns 1 {
        New-UDHeading -Size 4 -Content {
            "Connect to New Server"
        } 
    }

    New-UDInput -Title "Connect to Empire Server" -Id "EmpireConfiguration" -SubmitText "Connect" -Content {
        New-UDInputField -Type 'select' -Name 'EmpireComputer' -Values $ValidEmpireNetworkResources.HostName
        New-UDInputField -Type 'textarea' -Name 'EmpirePort' -DefaultValue $EmpireConfig.empire_port
        New-UDInputField -Type 'textarea' -Name 'EmpireToken' -DefaultValue $EmpireConfig.empire_token
    } -Endpoint {
        param($EmpireComputer, $EmpirePort, $EmpireToken)
        New-UDInputAction -Toast "Retrieving Empire Configurations!"
        
        
        Write-BSAuditLog -BSLogContent "Empire Configuration: Attempting to Retrieve Configuration from: $EmpireComputer"


        $EmpireConfiguration = Get-EmpireStatus -EmpireBox $EmpireComputer -EmpireToken $EmpireToken -EmpirePort $EmpirePort
        Write-BSEmpireConfigData -BSObject $EmpireConfiguration
        
        $EmpireAgents = Get-EmpireAgents -EmpireBox $EmpireComputer -EmpireToken $EmpireToken -EmpirePort $EmpirePort
        Write-BSEmpireAgentData -BSObject $EmpireAgents

        $EmpireModules = Get-EmpireModules -EmpireBox $EmpireComputer -EmpireToken $EmpireToken -EmpirePort $EmpirePort
        Write-BSEmpireModuleData -BSObject $EmpireModules

        Write-BSAuditLog -BSLogContent "Empire Configuration: Configuration Retrieval Complete"

    }

    New-UDLayout -Columns 1 {
        New-UDHeading -Size 4 -Content {
            "Existing Configuartion"
        } 
    
    }
    
    


    New-UDGrid -Title "Empire Instance" -Headers @("version", "api_username", "install_path") -Properties @("version", "api_username", "install_path") -AutoRefresh -Endpoint {
        $JsonData = Get-BSEmpireConfigData
        If ($JsonData.version)
        {
            $Text =  'Empire - Version: ' + ($JsonData.version) +' - User: ' + ($JsonData.api_username)  + ' - Installed: ' + ($JsonData.install_path)    
        }
        else 
        {
            $Text = "No Empire Found - Run Config!"            
        }
        $JsonData | Out-UDGridData
    }

        
    New-UDGrid -Title "Empire Agents" -Headers @("id", "name", "checkin_time","external_ip","hostname","internal_ip","langauge", "langauge_version", "lastseen_time","listener","os_details","username") -Properties @("id", "name", "checkin_time","external_ip","hostname","internal_ip","langauge", "langauge_version", "lastseen_time","listener","os_details","username") -AutoRefresh -Endpoint {
        $JsonData = Get-BSEmpireAgentData
        $JsonData | Out-UDGridData
    }        

    New-UDGrid -Title "Empire Modules" -Headers @("Name", "Description", "Author","Language","NeedsAdmin","OpsecSafe") -Properties @("Name", "Description", "Author","Language","NeedsAdmin","OpsecSafe") -AutoRefresh -Endpoint {
        $JsonData = Get-BSEmpireModuleData
        $JsonData | Out-UDGridData
    }      
    
    
}