#### All functions need to have proper function params, synopsis, help, etc....
#### Also where my psd1 file at



#Retrieved Data
$BHUserAccountsPath = 'Data\Retrieved\Accounts.json'
$BHUserAccountsPath = 'Data\Retrieved\Accounts.json'
$BHDomainPath = 'Data\Retrieved\Domain.json'
$BHOUPath = 'Data\Retrieved\OUs.json'

#Managed Data
$BHUserHoneyAccountsPath = 'Data\Managed\HoneyAccounts.json'

#LOG Paths
$BHLogFilePath = 'Data\Logs\AuditLog.log' 
$BHErrorFilePath = 'Data\Logs\ErrorLog.log'

#Data Generation Resources Path
$BSFirstNamesFile = 'Data\Generation\FirstNames.txt'
$BSLastNamesFile = 'Data\Generation\LastNames.txt'
$BSServiceAccountNamesFile = 'Data\Generation\service-accounts.txt'

Function Get-BHJSONObject 
{
Param(
    $BHFile = ''
)

    if(Test-Path($BHFile))
    {

        $FileContents = Get-Childitem -file $BHFile  
        $Length = $FileContents.Length

        iF($Length -ne 0)
        {
            $JsonObject = ConvertFrom-Json -InputObject (Get-Content $BHFile -raw)
            return $JsonObject
        }
        else 
        {
            # Empty File
            return $null
        }

        
    }
    else 
    {
        # Does not Exist
        return $null
    }
}





Function Get-BHAccountData()
{

    $Data = @()
    $ResourcesJsonContent = Get-BHJSONObject -BHFile $BHUserAccountsPath

    return $ResourcesJsonContent

    <#
    #### Data Stuff for translated 
    foreach($Resource in $ResourcesJsonContent)
    {
        
        $Data = $Data +[PSCustomObject]@{
            id=($Resource.id);
            DistinguishedName=($Resource.name);
            checkin_time=($Resource.checkin_time);
            external_ip=($Resource.external_ip);
            hostname=($Resource.hostname);
            internal_ip=($Resource.internal_ip);
            langauge=($Resource.langauge);
            langauge_version=($Resource.langauge_version);
            lastseen_time=($Resource.lastseen_time);
            listener=($Resource.listener);
            os_details=($Resource.os_details);
            username=($Resource.username);
        }
      
    }
    #>
    
    
}


Function Get-BHOuData()
{

    $Data = @()
    $ResourcesJsonContent = Get-BHJSONObject -BHFile $BHOUPath

    return $ResourcesJsonContent

    <#
    #### Data Stuff for translated 
    foreach($Resource in $ResourcesJsonContent)
    {
        
        $Data = $Data +[PSCustomObject]@{
            id=($Resource.id);
            DistinguishedName=($Resource.name);
            checkin_time=($Resource.checkin_time);
            external_ip=($Resource.external_ip);
            hostname=($Resource.hostname);
            internal_ip=($Resource.internal_ip);
            langauge=($Resource.langauge);
            langauge_version=($Resource.langauge_version);
            lastseen_time=($Resource.lastseen_time);
            listener=($Resource.listener);
            os_details=($Resource.os_details);
            username=($Resource.username);
        }
      
    }
    #>
    
    
}




Function Get-BHHoneyAccountData()
{

    $Data = @()
    $ResourcesJsonContent = Get-BHJSONObject -BHFile $BHUserHoneyAccountsPath

    return $ResourcesJsonContent

    <#
    #### Data Stuff for translated 
    foreach($Resource in $ResourcesJsonContent)
    {
        
        $Data = $Data +[PSCustomObject]@{
            id=($Resource.id);
            DistinguishedName=($Resource.name);
            checkin_time=($Resource.checkin_time);
            external_ip=($Resource.external_ip);
            hostname=($Resource.hostname);
            internal_ip=($Resource.internal_ip);
            langauge=($Resource.langauge);
            langauge_version=($Resource.langauge_version);
            lastseen_time=($Resource.lastseen_time);
            listener=($Resource.listener);
            os_details=($Resource.os_details);
            username=($Resource.username);
        }
      
    }
    #>
    
    
}




Function Get-BSEmpireConfigData()
{

    $Data = @()
    $ResourcesJsonContent = Get-BHJSONObject -BHFile $EmpireConfigFilePath

    #### Data Stuff
    foreach($Resource in $ResourcesJsonContent)
    {
        $Data = $Data +[PSCustomObject]@{
            empire_host=($Resource.empire_host);
            empire_port=($Resource.empire_port);
            empire_token=($Resource.empire_token);
            api_username=($Resource.api_username);
            install_path=($Resource.install_path);
            version=($Resource.version);
            sync_time=($Resource.sync_time)
        }
    }

    return $Data


}


Function Get-BSEmpireModuleData()
{
    
    $Data = @()
    $Options = @()
    $FirstPartOfDefinition = '^.*=@{Description='
    $SecondPartOfDefinition = ';.*;.*Value=.*}'

    $ResourcesJsonContent = Get-BHJSONObject -BHFile $EmpireModuleFilePath

    #### Data Stuff
    foreach($Module in $ResourcesJsonContent)
    {

        #Propertize the Module Objects
        $ModuleOptionsObject = @()
        $ModuleOptions = $Module.options 
        
        $ModuleOptionsNotes = $ModuleOptions | Get-Member -MemberType NoteProperty
        ForEach($Note in $ModuleOptionsNotes)
        {

            $OptionDefinitionFormatted = $Note.Definition
            $OptionDefinitionFormatted = $OptionDefinitionFormatted -replace $FirstPartOfDefinition," "
            $OptionDefinitionFormatted = $OptionDefinitionFormatted -replace $SecondPartOfDefinition,""

            $ModuleOptionsObject = $ModuleOptionsObject +[PSCustomObject]@{
                Name=($Note.Name);
                Definition=($OptionDefinitionFormatted);
            }
        }


        $Data = $Data +[PSCustomObject]@{
            Name=($Module.name);
            Author=($Module.Author);
            Description=($Module.Description);
            Language=($Module.Language);
            NeedsAdmin=($Module.NeedsAdmin);
            OpsecSafe=($Module.OpsecSafe);
            Options=($ModuleOptionsObject);
        }
    }



    return $Data


}


Function Get-BSNetworkScanData()
{

    $Data = @()
    $ResourcesJsonContent = Get-BHJSONObject -BHFile $NetworkScanFilePath
        
    #### Data Stuff
    foreach($Resource in $ResourcesJsonContent)
    {
        $Data = $Data +[PSCustomObject]@{
            HostName=($Resource.Hostname);
            IPv4=($Resource.IPv4);
            Status=($Resource.Status);
            Computer=(New-UDLink -Text "RDP" -Url "remotedesktop://$Resource.IPv4");
            Note="";
            LastScan=($Resource.ScanTime.DateTime);
            isEmpire=($Resource.EmpireServer);
        }
    }
       
    return $Data

}



Function Get-BHHoneyAccounts()
{

    $Data = @()
    $ResourcesJsonContent = Get-BHTextFile  $BHUserAccountsPath
    

    <#
    #### Data Stuff
    foreach($Resource in $ResourcesJsonContent)
    {
        $Data = $Data +[PSCustomObject]@{
            HostName=($Resource.Hostname);
            IPv4=($Resource.IPv4);
            Status=($Resource.Status);
            Computer=(New-UDLink -Text "RDP" -Url "remotedesktop://$Resource.IPv4");
            Note="";
            LastScan=($Resource.ScanTime.DateTime);
            isEmpire=($Resource.EmpireServer);
        }
    }
    #>
       
    return $Data

}




Function Clear-BSJON
{
Param(
    $BHFile = ''
)
    if(Test-Path($BHFile))
    {
         # Clear Existings
        Clear-Content $BHFile -Force
    }
    else 
    {
        # Does not Exist
    }
}


Function Write-BHJSON
{
Param (
    [Parameter(Mandatory=$true)] $BHFile = '',
    [Parameter(Mandatory=$true)] $BHObjectData
)

    $BHObjectData | ConvertTo-Json | Out-File $BHFile -Append


}



Function Write-BHObjectToJSON
{
    Param (
        [Parameter(Mandatory=$true)] $BHFile = '',
        [Parameter(Mandatory=$true)] $BHObjectData
    )

    $BHObjectData | ConvertTo-Json | Out-File $BHFile -Append

}



Function Write-BHUser
{
    Param (
        [Parameter(Mandatory=$true)] $BHObjectData
    )

    Write-BHObjectToJSON -BHFile $BHUserAccountsPath -BHObjectData $BHObjectData

}





Function Write-BHUserAccountData
{
Param (
    $AccountData
)
    
    Write-BHJSON -BHFile $BHUserAccountsPath -BHObjectData $AccountData

}


Function Write-BHUserHoneyAccountData
{
Param (
    $AccountData
)
    
    Write-BHJSON -BHFile $BHUserHoneyAccountsPath -BHObjectData $AccountData

}

Function Write-BHOUData
{
Param (
    $OUData
)
    
    Write-BHJSON -BHFile $BHOUPath -BHObjectData $OUData

}



# DOMAIN DATAS

Function Write-BHDomainData
{
Param (
    $DomainData
)
    If($DomainData)
    {
        Write-BHJSON -BHFile $BHDomainPath -BHObjectData $DomainData
    }
 
}

Function Get-BHDomainData
{
    
    $Data = @()
    $ResourcesJsonContent = Get-BHJSONObject -BHFile $BHDomainPath

    return $ResourcesJsonContent

}



Function Write-BSEmpireConfigData
{
Param (
    $BHObjectData        
)
    Clear-BSJON -BHFile $EmpireConfigFilePath
    Write-BHJSON -BHFile $EmpireConfigFilePath -BHObjectData $BHObjectData


}

Function Write-BSEmpireModuleData
{
Param (
    $BHObjectData        
)
    Clear-BSJON -BHFile $EmpireModuleFilePath
    Write-BHJSON -BHFile $EmpireModuleFilePath -BHObjectData $BHObjectData
    

}





Function Write-BSNetworkScanData
{
Param (
    $BHObjectData        
)
    Clear-BSJON -BHFile $NetworkScanFilePath
    Write-BHJSON -BHFile $NetworkScanFilePath -BHObjectData $BHObjectData
    
}

Function Write-AuditLog
{
Param (
    $BSLogContent
)
    $BSLogContentFormatted = ($(Get-Date -Format 'yyyy-MM-dd hh:mm:ss') + ' : ' + $BSLogContent)
    $BSLogContentFormatted | Out-File $BHLogFilePath -Append
}

Function Write-ErrorLog
{
Param (
    $BSLogContent
)
    $BSLogContentFormatted = ($(Get-Date -Format 'yyyy-MM-dd hh:mm:ss') + ' : ' + $BSLogContent)
    $BSLogContentFormatted | Out-File $BHErrorFilePath -Append
}


Function Clear-BHUserAccountData
{
    if(Test-Path($BHUserAccountsPath))
    {
         # Clear Existings
        Clear-Content $BHUserAccountsPath -Force
    }
    else 
    {
        # Does not Exist
    }
}




Function Clear-BHUserHoneyAccountData
{
    if(Test-Path($BHUserHoneyAccountsPath))
    {
         # Clear Existings
        Clear-Content $BHUserHoneyAccountsPath -Force
    }
    else 
    {
        # Does not Exist
    }
}






Function Get-BHTextFile
{
Param(
    $BHFile = ''
    )

    if(Test-Path($BHFile))
    {
        $FileContents =  Get-Content -Path $BHFile
        $Length = $FileContents.Length

        iF($Length -ne 0)
        {
            return $FileContents
        }
        else 
        {
            # Empty File
            return $null
        }

        
    }
    else 
    {
        # Does not Exist
        return $null
    }
}



Function Get-RandomFirstName
{
    $FirstName = Get-BHTextFile -BHFile $BSFirstNamesFile | Get-Random
    $FirstName = $FirstName.substring(0,1).toupper()+$FirstName.substring(1).tolower()
    return $FirstName
}

Function Get-RandomLastName
{
    $LastName = Get-BHTextFile -BHFile $BSLastNamesFile | Get-Random
    $LastName = $LastName.substring(0,1).toupper()+$LastName.substring(1).tolower()
    return $LastName
}


Function Get-RandomPerson
{
    $firstname = Get-RandomFirstName
    $lastname = Get-RandomLastName

    $RandomUserObject = [PSCustomObject]@{
        
        firstname = ($firstname);
        lastname = ($lastname);
        displayname =($firstname + ' ' + $lastname);
        email = ($firstname + '.' + $lastname + '@' + 'company.com');
        samaccountname = ($firstname.substring(0,1) + $lastname)


    }


    Return $RandomUserObject

}



Function Get-RandomServiceAccount
{
    $ServiceAccountName = Get-BHTextFile -BHFile $BSServiceAccountNamesFile | Get-Random
    # TODO SPN

    $RandomServiceAccount= [PSCustomObject]@{
        
        accountname = ($ServiceAccountName);
        displayname = ($ServiceAccountName);
    }
    
    Return $RandomServiceAccount

}


