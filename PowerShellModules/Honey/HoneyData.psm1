#### All functions need to have proper function params, synopsis, help, etc....
#### Also where my psd1 file at


# TODO 
# When the SYNC specicies a domain - we should create a folder for it
# Then all the info for the that domain goes in it (users, groups, computers, OUs, DCs, Accounts, Honeys, ETC.)
# Then we must update all references to be domain aware


#Retrieved Data
$BHDomainPath = 'C:\Users\lee\git\BlueHive\Data\Retrieved\Domains'

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





Function Get-BHAccountData
{   
    param(
        $DomainNetBIOSName = 'berg'
    )

    $Data = @()
    $ResourcesJsonContent = Get-BHJSONObject -BHFile ($BHDomainPath + '\' + $DomainNetBIOSName + '\Accounts.json')

    return $ResourcesJsonContent

       
}


Function Get-BHOuData
{
    param(
        $DomainNetBIOSName = 'berg'
    )

    $Data = @()
    $ResourcesJsonContent = Get-BHJSONObject -BHFile ($BHDomainPath + '\' + $domainname + '\OUs.json')

    return $ResourcesJsonContent

    
}




Function Get-BHHoneyAccountData
{
    param(
        $DomainNetBIOSName = 'berg'
    )

    $ResourcesJsonContent = Get-BHJSONObject -BHFile ($BHDomainPath + '\' + $domainname + '\HoneyAccounts.json')

    return $ResourcesJsonContent
    
    
}


Function Get-BHDHoneyUserDetailsData
{
    param(
        [string]$DistinguishedName,
        [string]$DomainNetBIOSName = 'berg'
    )

   
    $ResourcesJsonContent = Get-BHJSONObject -BHFile ($BHDomainPath + '\' + $domainname + '\HoneyAccounts.json')

    $UserDetails = $ResourcesJsonContent | Where-Object DistinguishedName -eq $DistinguishedName

    return $UserDetails
    
}


Function Get-BHDomainData
{
    
    $DomainData = @()

    $DomainFolders = Get-ChildItem -Path $BHDomainPath
    
    foreach($Folder in $DomainFolders)
    {
        $DomainFolderPath = $Folder.FullName
        $DomainJsonFile  = Get-BHJSONObject -BHFile ($DomainFolderPath + '\Domain.json')
        $DomainData = $DomainData + $DomainJsonFile

    }
    
    return $DomainData

}





Function Get-BHDeploymentHistoryData()
{

    $ResourcesJsonContent = Get-BHJSONObject -BHFile $BHDeploymentHistoryFilePath

    return $ResourcesJsonContent    
    
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



Function Write-BHUserAccountData
{
Param (
    $AccountData,
    $DomainNetBiosName
)

    if($AccountData)
    {

        $BHDomainUserAccountsPath = ($BHDomainPath + '\' + $DomainNetBiosName + '\Accounts.json')

        if(Test-Path($BHDomainUserAccountsPath))
        {
            # Clear Existings
            Clear-Content $BHDomainUserAccountsPath -Force
        }
        else 
        {
            # Does not Exist
        }

        Write-BHJSON -BHFile $BHDomainUserAccountsPath -BHObjectData $AccountData

    }

}


Function Write-BHADDomainControllers
{
    Param (
        $DomainControllers,
        $DomainNetBiosName
    )

        if($DomainControllers)
        {

            $BHDomainControllersPath = ($BHDomainPath + '\' + $DomainNetBiosName + '\DCs.json')

            if(Test-Path($BHDomainControllersPath))
            {
                # Clear Existings
                Clear-Content $BHDomainControllersPath -Force
            }
            else 
            {
                # Does not Exist
            }

            Write-BHJSON -BHFile $BHDomainControllersPath -BHObjectData $DomainControllers

        }
    
}


Function Write-BHUserHoneyAccountData
{
    Param (
        $AccountData,
        $DomainNetBiosName
    )

    if($AccountData)
    {

        $BHUserHoneyAccountsPath = ($BHDomainPath + '\' + $DomainNetBiosName + '\HoneyAccounts.json')

        if(Test-Path($BHUserHoneyAccountsPath))
        {
             # Clear Existings
            Clear-Content $BHUserHoneyAccountsPath -Force
        }
        else 
        {
            # Does not Exist
        }

        Write-BHJSON -BHFile $BHUserHoneyAccountsPath -BHObjectData $AccountData

    }
    

}

Function Write-BHOUData
{
    Param (
        $OUData,
        $DomainNetBiosName
    )
    
    If($OUData)
    {
        $BHDomainOUPath = ($BHDomainPath + '\' + $DomainNetBiosName + '\OUs.json')

        if(Test-Path($BHDomainOUPath))
        {
             # Clear Existings
            Clear-Content $BHDomainOUPath -Force
        }
        else 
        {
            # Does not Exist
        }

        Write-BHJSON -BHFile $BHDomainOUPath -BHObjectData $OUData
    }

}



# DOMAIN DATAS

Function Write-BHDomainData
{
Param (
    $DomainObject
)

    If($DomainObject)
    {
        $DomainName = $DomainObject.NetBIOSName
        $DomainNameFolderPath = ($BHDomainPath + '\' + $DomainName)
        
        if(Test-Path($DomainNameFolderPath))
        {
            
        }
        else
        {
            New-Item -Path $DomainNameFolderPath -ItemType Directory
        }

        $DomainNameFilePath = ($BHDomainPath + '\' + $DomainName + '\Domain.json')

        if(Test-Path($DomainNameFilePath))
        {
             # Clear Existings
            Clear-Content $DomainNameFilePath -Force
        }
        else 
        {
            # Does not Exist
        }

        Write-BHJSON -BHFile $DomainNameFilePath -BHObjectData $DomainObject
    }
 
}






Function Clear-BHUserAccountData
{
    param(
        $DomainNetBiosName = ''
    )

    $BHDomainUserAccountsPath = ($BHDomainPath + '\' + $DomainNetBiosName + '\Accounts.json')

    if(Test-Path($BHDomainUserAccountsPath))
    {
        # Clear Existings
        Clear-Content $BHDomainUserAccountsPath -Force
    }
    else 
    {
        # Does not Exist
    }
}


Function Clear-BHADDomainControllers
{
    param(
        $DomainNetBiosName = ''
    )

    $BHDomainControllersPath = ($BHDomainPath + '\' + $DomainNetBiosName + '\DCs.json')

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
    param(
        $DomainNetBiosName = ''
    )

    $BHUserHoneyAccountsPath = ($BHDomainPath + '\' + $DomainNetBiosName + '\HoneyAccounts.json')

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
    param(
        $DomainNetBiosName = ''
    )

    $BHDomainOUPath = ($BHDomainPath + '\' + $DomainNetBiosName + '\OUs.json')


    if(Test-Path($BHDomainOUPath))
    {
         # Clear Existings
        Clear-Content $BHDomainOUPath -Force
    }
    else 
    {
        # Does not Exist
    }

}




#### General File stuff

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


