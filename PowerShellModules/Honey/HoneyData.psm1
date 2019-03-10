#### All functions need to have proper function params, synopsis, help, etc....
#### Also where my psd1 file at


# TODO 
# When the SYNC specicies a domain - we should create a folder for it
# Then all the info for the that domain goes in it (users, groups, computers, OUs, DCs, Accounts, Honeys, ETC.)
# Then we must update all references to be domain aware


#Retrieved Data
$BHUserAccountsPath = 'C:\Users\lee\git\BlueHive\Data\Retrieved\Accounts.json'
$BHDomainPath = 'C:\Users\lee\git\BlueHive\Data\Retrieved\Domains'
$BHOUPath = 'C:\Users\lee\git\BlueHive\Data\Retrieved\OUs.json'
$BHDomainControllersPath = 'C:\Users\lee\git\BlueHive\Data\Retrieved\DCs.json'

#Managed Data
$BHUserHoneyAccountsPath = 'C:\Users\lee\git\BlueHive\Data\Managed\HoneyAccounts.json'

#LOG Paths
$BHLogFilePath = 'C:\Users\lee\git\BlueHive\Data\Logs\AuditLog.log' 
$BHErrorFilePath = 'C:\Users\lee\git\BlueHive\Data\Logs\ErrorLog.log'
$BHDeploymentHistoryFilePath = 'C:\Users\lee\git\BlueHive\Data\Logs\Deployment.json'


#Data Generation Resources Path
$BSFirstNamesFile = 'C:\Users\lee\git\BlueHive\Data\Generation\FirstNames.txt'
$BSLastNamesFile = 'C:\Users\lee\git\BlueHive\Data\Generation\LastNames.txt'
$BSServiceAccountNamesFile = 'C:\Users\lee\git\BlueHive\Data\Generation\service-accounts.txt'

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
            ###WTF - Differences in different version of get-aduser??
            # Generic Function should clean on write
            $RawData = (Get-Content $BHFile -raw)
           

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


Function Get-BHDHoneyUserDetailsData
{
    param(
        [string]$DistinguishedName
    )

    $ResourcesJsonContent = Get-BHJSONObject -BHFile $BHUserHoneyAccountsPath

    $UserDetails = $ResourcesJsonContent | Where-Object DistinguishedName -eq $DistinguishedName

    return $UserDetails
    
}



Function Get-BHDeploymentHistoryData()
{

    $ResourcesJsonContent = Get-BHJSONObject -BHFile $BHDeploymentHistoryFilePath

    return $ResourcesJsonContent    
    
}


Function Get-BHHoneyAccounts()
{

    $Data = @()
    $ResourcesJsonContent = Get-BHTextFile  $BHUserHoneyAccountsPath
    

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
    # TODO - wtf weridness in different version of AD MOdules?
    # STUDPID $AccountData = $AccountData.Replace('ObjectGUID','ObjectGUIDCAP')

    Write-BHJSON -BHFile $BHUserAccountsPath -BHObjectData $AccountData

}


Function Write-BHADDomainControllers
{
    Param (
        $DomainControllers
    )
        # TODO - wtf weridness in different version of AD MOdules?
        # STUDPID $AccountData = $AccountData.Replace('ObjectGUID','ObjectGUIDCAP')
    
        Write-BHJSON -BHFile $BHDomainControllersPath -BHObjectData $DomainControllers
    
}


Function Write-BHUserHoneyAccountData
{
Param (
    $AccountData
)
    if($AccountData)
    {
        Write-BHJSON -BHFile $BHUserHoneyAccountsPath -BHObjectData $AccountData
    }
    

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
        $DomainName = $DomainData.NetBIOSName
        $DomainNameFilePath = ($BHDomainPath + '\' + $DomainName + '.json')

        if(Test-Path($DomainNameFilePath))
        {
             # Clear Existings
            Clear-Content $DomainNameFilePath -Force
        }
        else 
        {
            # Does not Exist
        }

        Write-BHJSON -BHFile $DomainNameFilePath -BHObjectData $DomainData
    }
 
}

Function Get-BHDomainData
{
    
    $DomainData = @()

    $DomainJsonFiles = Get-ChildItem -Path $BHDomainPath
    
    foreach($File in $DomainJsonFiles)
    {
       
        $ResourcesJsonContent = Get-BHJSONObject -BHFile $File.FullName
        $DomainData = $DomainData + $ResourcesJsonContent

    }

    

    return $DomainData

}



Function Write-DeploymentHistoryLog
{
    Param (
            [string]$Description,
            [string]$Type
    )

   
    #### Create PS Object
    $DeploymentRecordObject = [PSCustomObject]@{
        id=([guid]::NewGuid());
        description=($Description);
        type=($Type);
        timestamp=(Get-Date -Format u);
        
    }

    $NewJsonObject = @()


    #TODO - Get JSON and update it  - probably not very managable... but w/e
    if(Test-Path -Path $BHDeploymentHistoryFilePath)
    {
        if(Get-Content $BHDeploymentHistoryFilePath -raw)
        {
            $JsonObject = ConvertFrom-Json -InputObject (Get-Content $BHDeploymentHistoryFilePath -raw)
            $NewJsonObject += $JsonObject
        }
        $NewJsonObject += $DeploymentRecordObject
        Clear-Content $BHDeploymentHistoryFilePath
    }
    else {
        
        $NewJsonObject = $DeploymentRecordObject
    }
  


    Write-BHJSON -BHFile $BHDeploymentHistoryFilePath -BHObjectData $NewJsonObject

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


Function Clear-BHADDomainControllers
{
    if(Test-Path($BHDomainControllersPath))
    {
         # Clear Existings
        Clear-Content $BHDomainControllersPath -Force
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




Function Clear-AllADOrganizationalUnits
{
    if(Test-Path($BHOUPath))
    {
         # Clear Existings
        Clear-Content $BHOUPath -Force
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


