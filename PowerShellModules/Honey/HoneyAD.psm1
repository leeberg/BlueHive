<# TODO 

Figure out how creds / sessions actually work in UD / migrate to IIS BAY BEE
2019-03-06 10:08:22 : Access is denied -- System.ServiceModel.FaultException: The operation failed due to insufficient access rights.

#>

function Get-BHDomain {
    param (
        $DomainName = 'berg.com'
    )

    Write-AuditLog ("Running Function: Get-BHDomain")

    $RetrievedDomain = Get-ADDomain $DomainName @Cache:ConnectionInfo | Select-Object -Property DistinguishedName,DNSRoot,DomainControllersContainer,DomainMode,DomainSID,Forest,InfrastructureMaster,Name,NetBIOSName,ObjectGUID, PDCEmulator,ReplicaDirectoryServers,RIDMaster,SystemsContainer,UsersContainer,@{Name="BHSyncTime"; Expression = {Get-Date -format u}}
     

    if($RetrievedDomain)
    {

        return $RetrievedDomain
        

    }
    else
    {
        return $null
    }
}

function Get-BHAllDomains {

    
    Write-AuditLog ("Running Function: Get-BHAllDomains")

    $RetrievedDomain = Get-ADDomain @Cache:ConnectionInfo | Select-Object -Property DistinguishedName,DNSRoot,DomainControllersContainer,DomainMode,DomainSID,Forest,InfrastructureMaster,Name,NetBIOSName,ObjectGUID, PDCEmulator,ReplicaDirectoryServers,RIDMaster,SystemsContainer,UsersContainer
       
    if($RetrievedDomain)
    {

        return $RetrievedDomain
        

    }
    else
    {
        return $null
    }
}

Function Get-AllADUsers
{
    param(
        $HoneyExtensionField = 'OtherName',
        $Domain = 'berg.com'
    )
        
    Write-AuditLog ("Running Function: Get-AllADUsers")

    try {
    
        #TODO - Different Version of AD Module have way different returns (check SID and other properties?)
        $Users = Get-ADUser -filter * -Properties "OtherName","PrimaryGroup" @Cache:ConnectionInfo | Select-Object -Property DistinguishedName,Enabled,GivenName,Name,ObjectClass,ObjectGUID,OtherName,SamAccountName,SID,Surname,UserPrincipalName

        return $Users    
    }
    catch {
        return $null    
    }
    

}


Function Get-AllADOrganizationalUnits
{
    param(
        $Domain = ''
    )

    Write-AuditLog ("Running Function: Get-AllADOrganizationalUnits")

    try{
        $OUs = Get-ADOrganizationalUnit -Filter * -Properties DistinguishedName @Cache:ConnectionInfo | Select-Object -Property DistinguishedName,ManagedBy,Name,ObjectClass,ObjectGUID

        return $OUs
    }
    catch
    {
        return $null
    }
    


}


Function Get-BHADDomainControllers
{
    param(
        $Domain = ''
    )
   
    Write-AuditLog ("Running Function: Get-BHADDomainControllers")

    try{
        $DomainControllers = Get-ADDomainController -Filter {Name -like '*'} @Cache:ConnectionInfo

        return $DomainControllers
    }
    catch
    {
        return $null
    }
    


}

Function Get-HoneyADusers
{

    param(
        $HoneyExtensionField = 'OtherName',
        $HoneyExtensionCode = '1337',
        $Domain = ''
    )

    Write-AuditLog ("Running Function: Get-HoneyADusers")

    try {
        $Users = Get-ADUser -Filter ("MiddleName -eq $HoneyExtensionCode") -Properties "DisplayName", "OtherName","whenCreated","whenChanged" @Cache:ConnectionInfo | Select-Object -Property DisplayName, whenCreated, whenChanged, DistinguishedName,Enabled,GivenName,Name,ObjectClass,ObjectGUID,OtherName,SamAccountName,SID,Surname,UserPrincipalName,@{Name="BHSyncTime"; Expression = {Get-Date -format u}},@{Name="ParentNetBios"; Expression = {$Domain}}
        return $Users
    }
    catch {
        return $null
    }
   

   
}



Function Set-UserPassword
{
    param(
        [Parameter(Mandatory=$true)]
        [String]$DistinguishedName,
        [string]$Password
    )

    Write-AuditLog ("Resetting Password for $DistinguishedName")
    
    try 
    {
        $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
        Set-ADAccountPassword -Reset -NewPassword $SecurePassword -Identity $DistinguishedName @Cache:ConnectionInfo
        Write-DeploymentHistoryLog -Description "Changed Password: for $DistinguishedName" -Type "Modification"
    }
    catch{

        $Exception = $_.Exception
        $ExceptionMessage = $Exception.Message
        Write-ErrorLog -BSLogContent "Failed to Reset Password for Account: $DistinguishedName"
        Write-ErrorLog ("$($ExceptionMessage) -- $($Exception.InnerException)")

    }

}


Function Delete-BHADUser
{
    param(
        [Parameter(Mandatory=$true)]
        [String]$DistinguishedName
    )

    Write-AuditLog ("Attempting to Delete: $DistinguishedName")

    try 
    {
        Remove-ADUser -Identity $DistinguishedName -Confirm:$False @Cache:ConnectionInfo 
        Write-DeploymentHistoryLog -Description "DELETED Account: $DistinguishedName" -Type "Modification"
    }
    catch{

        $Exception = $_.Exception
        $ExceptionMessage = $Exception.Message
        Write-ErrorLog -BSLogContent "Failed to DELETED Account: $DistinguishedName"
        Write-ErrorLog ("$($ExceptionMessage) -- $($Exception.InnerException)")

    }

}

Function Set-UserState
{
    param(
        [string]$DistinguishedName,
        [string]$State
    )

    Write-AuditLog ("Changing State for $DistinguishedName to $State")
    
    if($State -eq "Disabled")
    {
        try 
        {
            Disable-ADAccount -Identity $DistinguishedName @Cache:ConnectionInfo
            Write-DeploymentHistoryLog -Description "Disabled Account: $DistinguishedName" -Type "Modification"
        }
        catch{

            $Exception = $_.Exception
            $ExceptionMessage = $Exception.Message
            Write-ErrorLog -BSLogContent "Failed to Disabled Account: $DistinguishedName"
            Write-ErrorLog ("$($ExceptionMessage) -- $($Exception.InnerException)")
    
        }
    
    }
    if($State -eq "Enabled")
    {
        try 
        {
            Enable-ADAccount -Identity $DistinguishedName @Cache:ConnectionInfo
            Write-DeploymentHistoryLog -Description "Enabled Account: $DistinguishedName" -Type "Modification"
        }
        catch{

            $Exception = $_.Exception
            $ExceptionMessage = $Exception.Message
            Write-ErrorLog -BSLogContent "Failed to Enabled Account: $DistinguishedName"
            Write-ErrorLog ("$($ExceptionMessage) -- $($Exception.InnerException)")
    
        }
    
    }

}





Function Set-ExtensionAttribute
{

    Param(
        [Parameter(Mandatory=$true)]
        [String]$ObjectDN
        #'CN=Alexandria Jomes,OU=ActivtySimulatorUsers,OU=Demo Users,DC=berg,DC=com'
    )

    # TODO GOTTA MAKE THIS MORE FLEXIBLE
    Write-AuditLog ("Running Function: Set-ExtensionAttribute")

    try {
        Set-ADUser -Identity $ObjectDN -Add @{extensionAttribute4="myString"} @Cache:ConnectionInfo
    }
    catch {
        return $false
    }
    
}


# todo - BAD NAME - 
Function Invoke-HoneyUserAccount
{   
    
    param(
        $HoneyExtensionField = 'OtherName',
        $HoneyExtensionCode = '1337',
        $HoneyUserOu = 'OU=ActivtySimulatorUsers,OU=Demo Users,DC=berg,DC=com'
    )

    ### TODO PAram all the thigns but randomize it if none provided

    Write-AuditLog ("Running Function: Invoke-HoneyUserAccount")

    $RandomUserDetails = Get-RandomPerson
    Write-AuditLog ("Creating Random User: $($RandomUserDetails.samaccountname)")
    
    
    try {
        
        # TODO - Consider Optional WEAK Password List for the Honey User
        $RandomPassword = ConvertTo-SecureString -String (([char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126)) + 0..9 | sort {Get-Random})[0..8] -join '') -AsPlainText -Force
        $HoneyUser = New-ADUser -Name $RandomUserDetails.samaccountname -GivenName $RandomUserDetails.firstname -Surname $RandomUserDetails.lastname -EmailAddress $RandomUserDetails.email -DisplayName $RandomUserDetails.displayname -Enabled $true -AccountPassword $RandomPassword -Path $HoneyUserOu -PassThru @Cache:ConnectionInfo
        Set-ADUser -Identity $HoneyUser.DistinguishedName -OtherName $HoneyExtensionCode @Cache:ConnectionInfo
        $HoneyUserDetails = Get-ADUser -Identity $HoneyUser.DistinguishedName -Properties * @Cache:ConnectionInfo

        Write-AuditLog ("Created Random User: $($RandomUserDetails.samaccountname) OK!")

        return $HoneyUserDetails

    }
    catch {

        $Exception = $_.Exception
        $ExceptionMessage = $Exception.Message
        Write-AuditLog ("Failed to Create Random User: $($RandomUserDetails.samaccountname)!")
        Write-ErrorLog ("Failed to Create Random User: $($RandomUserDetails.samaccountname)!")
        Write-ErrorLog ("$($ExceptionMessage) -- $($Exception.InnerException)")
        return $null
    }
    

    
}

