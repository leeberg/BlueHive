#### All functions need to have proper function params, synopsis, help, etc....
#### Also where my psd1 file at

#Import-Module CredentialManager -force

Function Save-AllADUsers
{
    <#
    .SYNOPSIS 
    Take a Collection of Objects and save it to the JSON file
     
    #>

    Param(
        $DomainObject = ''
    )
   
    try{

        $UserObjects = Get-AllADUsers -Domain ($DomainObject.Forest)
        Write-BHUserAccountData -AccountData $UserObjects -DomainNetBiosName $DomainObject.NetBIOSName

    }
    catch{
        $Exception = $_.Exception
        $ExceptionMessage = $Exception.Message
        Write-AuditLog ("Failed to Save-AllADUsers!")
        Write-ErrorLog ("Failed to Save-AllADUsers: $($ExceptionMessage) -- $($Exception.InnerException)")
        return $null
    }
    
    

}


Function Save-AllDomainControllers
{
    Param(
        $DomainObject = ''
    )

    <#
    .SYNOPSIS 
    Take a Collection of Objects and save it to the JSON file
     
    #>
   
    try{
        $DomainControllers = Get-BHADDomainControllers -Domain ($DomainObject.Forest)
        Write-BHADDomainControllers -DomainControllers $DomainControllers -DomainNetBiosName ($DomainObject.NetBIOSName)

    }
    catch{
        $Exception = $_.Exception
        $ExceptionMessage = $Exception.Message
        Write-AuditLog ("Failed to Save-AllDomainControllers!")
        Write-ErrorLog ("Failed to Save-AllDomainControllers: $($ExceptionMessage) -- $($Exception.InnerException)")
        return $null
    }
    
    

}



Function Save-AllADHoneyUsers
{
    <#
    .SYNOPSIS 
    Take a Collection of Objects and save it to the JSON file
     
    #>

    Param(
        $DomainObject = ''
    )
   
    
    
    try{ 
        $UserObjects = Get-HoneyADusers -Domain ($DomainObject.NetBIOSName)
        
        If($UserObjects)
        {
            Write-BHUserHoneyAccountData -AccountData $UserObjects -DomainNetBiosName ($DomainObject.NetBIOSName)
        }
        else {
            Write-AuditLog "Could Not Find ANY Honey Users!"
        }

    }
    catch{
        $Exception = $_.Exception
        $ExceptionMessage = $Exception.Message
        Write-AuditLog ("Failed to Save-AllADHoneyUsers!")
        Write-ErrorLog ("Failed to Save-AllADHoneyUsers: $($ExceptionMessage) -- $($Exception.InnerException)")
        return $null
    }
    
   
    

}


Function Save-AllADOUs
{
    <#
    .SYNOPSIS 
    Take a Collection of Objects and save it to the JSON file
     
    #>
    
    Param(
        $DomainObject = ''
    )
   
    try {
        $OUs = Get-AllADOrganizationalUnits -Domain ($DomainObject.Forest)
        Write-BHOUData -OUData $OUs -DomainNetBiosName ($DomainObject.NetBIOSName)
    }
    catch {
        $Exception = $_.Exception
        $ExceptionMessage = $Exception.Message
        Write-AuditLog ("Failed to Save-AllADOUs!")
        Write-ErrorLog ("Failed to Save-AllADOUs: $($ExceptionMessage) -- $($Exception.InnerException)")
        return $null
    }

    

    
}


Function Save-ADDomain
{
    <#
    .SYNOPSIS 
    Take a Collection of Objects and save it to the JSON file
     
    #>
    
    Param(
        $Domain = 'berg.com'
    )
   
    try {
        $DomainObject = Get-BHDomain -DomainName $Domain
        Write-BHDomainData -DomainObject $DomainObject
    }
    catch {
        $Exception = $_.Exception
        $ExceptionMessage = $Exception.Message
        Write-AuditLog ("Failed to Save AD Domain Info!")
        Write-ErrorLog ("Failed to Save AD Domain Info: $($ExceptionMessage) -- $($Exception.InnerException)")
        return $null
    }

    return $DomainObject
    
}



Function Invoke-BHFullADSync
{
    <#
    .SYNOPSIS
    # I have my domain and now I want to gather all the users and honey tokens
    
    #>

    Param(
        $DomainToSync = 'berg.com'
    )
  
    Write-AuditLog -BSLogContent "Starting AD Sync!"

    Write-AuditLog -BSLogContent "Syncing Domain Info from: $($DomainToSync)"
    $DomainObject = Save-ADDomain -Domain $DomainToSync
             
    Write-AuditLog -BSLogContent "Syncing Accounts from: $($DomainToSync)"
    Save-AllADUsers -Domain $DomainObject

    Write-AuditLog -BSLogContent "Syncing Existing Honey Accounts from: $($DomainToSync)"
    Save-AllADHoneyUsers -Domain $DomainObject

    Write-AuditLog -BSLogContent "Syncing Domain Controllers from: $($DomainToSync)"
    Save-AllDomainControllers -Domain $DomainObject

    Write-AuditLog -BSLogContent "Syncing Domain OUs from: $($DomainToSync)"
    Save-AllADOUs -Domain $DomainObject

    Write-AuditLog -BSLogContent "AD Sync Complete!"


  



}








##### Testing Zone

#Invoke-HoneyUserAccount
#Get-RandomServiceAccount
#Get-RandomPerson
