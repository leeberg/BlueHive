<# TODO 

Figure out how creds / sessions actually work in UD / migrate to IIS BAY BEE
2019-03-06 10:08:22 : Access is denied -- System.ServiceModel.FaultException: The operation failed due to insufficient access rights.

#>

function Get-BHDomain {
    param (
        $DomainName = 'berg.com'
    )

    Write-AuditLog ("Running Function: Get-BHDomain")

    $RetrievedDomain = Get-ADDomain $DomainName @Cache:ConnectionInfo | Select-Object -Property DistinguishedName,DNSRoot,DomainControllersContainer,DomainMode,DomainSID,Forest,InfrastructureMaster,Name,NetBIOSName,ObjectGUID, PDCEmulator,ReplicaDirectoryServers,RIDMaster,SystemsContainer,UsersContainer
     
    


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
        $DomainController = 'BC-DC.berg.com'
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
        $DomainController = 'BC-DC.berg.com'
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
        $DomainController = 'bc-dc.berg.com'
    )

    Write-AuditLog ("Running Function: Get-HoneyADusers")

    try {
        $Users = Get-ADUser -Filter ("MiddleName -eq $HoneyExtensionCode") -Properties  "OtherName" @Cache:ConnectionInfo | Select-Object -Property DistinguishedName,Enabled,GivenName,Name,ObjectClass,ObjectGUID,OtherName,SamAccountName,SID,Surname,UserPrincipalName
        #Get-ADUSer "SGeorgiev" -Properties *
        return $Users
    }
    catch {
        return $null
    }
   

   
}


Function Set-ExtensionAttribute
{
    Param(
        $ObjectDN = 'CN=Alexandria Jomes,OU=ActivtySimulatorUsers,OU=Demo Users,DC=berg,DC=com'
    )

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

