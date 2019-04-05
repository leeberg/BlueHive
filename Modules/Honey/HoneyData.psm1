#### All functions need to have proper function params, synopsis, help, etc....
#### Also where my psd1 file at

# TODO 
# When the SYNC specicies a domain - we should create a folder for it
# Then all the info for the that domain goes in it (users, groups, computers, OUs, DCs, Accounts, Honeys, ETC.)
# Then we must update all references to be domain aware

$BlueHiveFolder =  'C:\Users\lee\git\BlueHive'

#Retrieved Data
$Cache:BHDomainPath =  $BlueHiveFolder + '\Data\Retrieved\Domains'

#LOG Paths
$Cache:BHLogFilePath = $BlueHiveFolder + '\Data\Logs\AuditLog.log' 
$Cache:BHErrorFilePath = $BlueHiveFolder + '\Data\Logs\ErrorLog.log'
$Cache:BHDeploymentHistoryFilePath = $BlueHiveFolder + '\Data\Logs\Deployment.json'

#Data Generation Resources Path
$Cache:BSFirstNamesFile = $BlueHiveFolder + '\Data\Generation\FirstNames.txt'
$Cache:BSLastNamesFile = $BlueHiveFolder + '\Data\Generation\LastNames.txt'
$Cache:BSServiceAccountNamesFile = $BlueHiveFolder + '\Data\Generation\service-accounts.txt'


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

    if($DomainNetBIOSName -eq '')
    {

   
        $DomainFolders = ($Cache:BHDomainPath + '\') | Get-ChildItem | ?{ $_.PSIsContainer }
        Foreach($Folder in $DomainFolders)
        {
            $DomainFolderPath = $Folder.FullName
            $DomainJsonFile  = Get-BHJSONObject -BHFile ($DomainFolderPath + '\Accounts.json')
            $DomainData = $DomainData + $DomainJsonFile
        }

        return $DomainData
        
    }
    else 
    {
        $ResourcesJsonContent = Get-BHJSONObject -BHFile ($Cache:BHDomainPath + '\' + $DomainNetBIOSName + '\Accounts.json')

        return $ResourcesJsonContent
    }

    
}


Function Get-BHOuData
{
    param(
        $DomainNetBIOSName = ''
    )

    $Data = @()

    if($DomainNetBIOSName -eq '')
    {

   
        $DomainFolders = ($Cache:BHDomainPath + '\') | Get-ChildItem | ?{ $_.PSIsContainer }
        Foreach($Folder in $DomainFolders)
        {
            $DomainFolderPath = $Folder.FullName
            $DomainJsonFile  = Get-BHJSONObject -BHFile ($DomainFolderPath + '\OUs.json')
            $DomainData = $DomainData + $DomainJsonFile
        }

        return $DomainData
        
    }
    else 
    {
        $ResourcesJsonContent = Get-BHJSONObject -BHFile ($Cache:BHDomainPath + '\' + $DomainNetBIOSName + '\OUs.json')
        return $ResourcesJsonContent
    }




    
    

    
}




Function Get-BHHoneyAccountData
{
    param(
        $DomainNetBIOSName = ''
    )

    $DomainData = @()

    if($DomainNetBIOSName -eq '')
    {

   
        $DomainFolders = ($Cache:BHDomainPath + '\') | Get-ChildItem | ?{ $_.PSIsContainer }
        Foreach($Folder in $DomainFolders)
        {
            $DomainFolderPath = $Folder.FullName
            $DomainJsonFile  = Get-BHJSONObject -BHFile ($DomainFolderPath + '\HoneyAccounts.json')
            $DomainData = $DomainData + $DomainJsonFile
        }

        return $DomainData
        
    }
    else 
    {
        $ResourcesJsonContent = Get-BHJSONObject -BHFile ($Cache:BHDomainPath + '\' + $DomainNetBIOSName + '\HoneyAccounts.json')
        return $ResourcesJsonContent
    }
    

    
    
    
}



Function Get-BHDHoneyUserDetailsData
{
    param(
        [string]$DistinguishedName,
        [string]$DomainNetBIOSName = 'BERG'
    )

   
    $ResourcesJsonContent = Get-BHJSONObject -BHFile ($Cache:BHDomainPath + '\' + $DomainNetBIOSName + '\HoneyAccounts.json')

    $UserDetails = $ResourcesJsonContent | Where-Object DistinguishedName -eq $DistinguishedName

    return $UserDetails
    
}


Function Get-BHDomainData
{
    
    $DomainData = @()

    $DomainFolders = Get-ChildItem -Path $Cache:BHDomainPath | ?{ $_.PSIsContainer }
    
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

    $ResourcesJsonContent = Get-BHJSONObject -BHFile $Cache:BHDeploymentHistoryFilePath

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

        $BHDomainUserAccountsPath = ($Cache:BHDomainPath + '\' + $DomainNetBiosName + '\Accounts.json')

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

            $BHDomainControllersPath = ($Cache:BHDomainPath + '\' + $DomainNetBiosName + '\DCs.json')

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


Function Get-BHADDomainControllers
{
    param(
        $DomainNetBIOSName = 'berg'
    )

    $Data = @()

    if($DomainNetBIOSName -eq '')
    {

        $DomainFolders = ($Cache:BHDomainPath + '\') | Get-ChildItem | ?{ $_.PSIsContainer }
        Foreach($Folder in $DomainFolders)
        {
            $DomainFolderPath = $Folder.FullName
            $DomainJsonFile  = Get-BHJSONObject -BHFile ($DomainFolderPath + '\DCs.json')
            $DomainData = $DomainData + $DomainJsonFile
        }

        return $DomainData
        
    }
    else 
    {
        $ResourcesJsonContent = Get-BHJSONObject -BHFile ($Cache:BHDomainPath + '\' + $DomainNetBIOSName + '\DCs.json')

        return $ResourcesJsonContent
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

        $BHUserHoneyAccountsPath = ($Cache:BHDomainPath + '\' + $DomainNetBiosName + '\HoneyAccounts.json')

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
        $BHDomainOUPath = ($Cache:BHDomainPath + '\' + $DomainNetBiosName + '\OUs.json')

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
        $DomainNameFolderPath = ($Cache:BHDomainPath + '\' + $DomainName)
        
        if(Test-Path($DomainNameFolderPath))
        {
            
        }
        else
        {
            New-Item -Path $DomainNameFolderPath -ItemType Directory
        }

        $DomainNameFilePath = ($Cache:BHDomainPath + '\' + $DomainName + '\Domain.json')

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

    $BHDomainUserAccountsPath = ($Cache:BHDomainPath + '\' + $DomainNetBiosName + '\Accounts.json')

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

    $BHDomainControllersPath = ($Cache:BHDomainPath + '\' + $DomainNetBiosName + '\DCs.json')

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

    $BHUserHoneyAccountsPath = ($Cache:BHDomainPath + '\' + $DomainNetBiosName + '\HoneyAccounts.json')

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

    $BHDomainOUPath = ($Cache:BHDomainPath + '\' + $DomainNetBiosName + '\OUs.json')


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
    if(Test-Path -Path $Cache:BHDeploymentHistoryFilePath)
    {
        if(Get-Content $Cache:BHDeploymentHistoryFilePath -raw)
        {
            $JsonObject = ConvertFrom-Json -InputObject (Get-Content $Cache:BHDeploymentHistoryFilePath -raw)
            $NewJsonObject += $JsonObject
        }
        $NewJsonObject += $DeploymentRecordObject
        Clear-Content $Cache:BHDeploymentHistoryFilePath
    }
    else {
        
        $NewJsonObject = $DeploymentRecordObject
    }
  


    Write-BHJSON -BHFile $Cache:BHDeploymentHistoryFilePath -BHObjectData $NewJsonObject

}


Function Write-AuditLog
{
Param (
    $BSLogContent
)
    $BSLogContentFormatted = ($(Get-Date -Format 'yyyy-MM-dd hh:mm:ss') + ' : ' + $BSLogContent)
    $BSLogContentFormatted | Out-File $Cache:BHLogFilePath -Append
}

Function Write-ErrorLog
{
Param (
    $BSLogContent
)
    $BSLogContentFormatted = ($(Get-Date -Format 'yyyy-MM-dd hh:mm:ss') + ' : ' + $BSLogContent)
    $BSLogContentFormatted | Out-File $Cache:BHErrorFilePath -Append
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
    $FirstName = Get-BHTextFile -BHFile $Cache:BSFirstNamesFile | Get-Random
    $FirstName = $FirstName.substring(0,1).toupper()+$FirstName.substring(1).tolower()
    return $FirstName
}

Function Get-RandomLastName
{
    $LastName = Get-BHTextFile -BHFile $Cache:BSLastNamesFile | Get-Random
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
    $ServiceAccountName = Get-BHTextFile -BHFile $Cache:BSServiceAccountNamesFile | Get-Random
    # TODO SET SPN

    $ServiceAccountName = $ServiceAccountName + '_' + (Get-Random -Minimum 1 -Maximum 999 )

    $RandomServiceAccount= [PSCustomObject]@{
        
        samaccountname = ($ServiceAccountName);
        displayname = ($ServiceAccountName);
        firstname = ""
        lastname = ""
        email = ($ServiceAccountName + '@' + 'company.com');
    }
    
    Return $RandomServiceAccount

}

