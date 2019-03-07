
function Get-BHDomain {
    param (
        $DomainName = 'berg.com'
    )

    $RetrievedDomain = Get-ADDomain $DomainName | Select-Object -Property DistinguishedName,DNSRoot,DomainControllersContainer,DomainMode,DomainSID,Forest,InfrastructureMaster,Name,NetBIOSName,ObjectGUID, PDCEmulator,ReplicaDirectoryServers,RIDMaster,SystemsContainer,UsersContainer
     
    


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
        

    try {
    
        #TODO - Different Version of AD Module have way different returns (check SID and other properties?)
        $Users = Get-ADUser -filter * -Properties "OtherName","PrimaryGroup" -Server $DomainController | Select-Object -Property DistinguishedName,Enabled,GivenName,Name,ObjectClass,ObjectGUID,OtherName,SamAccountName,SID,Surname,UserPrincipalName

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

    try{
        $OUs = Get-ADOrganizationalUnit -Filter * -Properties DistinguishedName -Server $DomainController | Select-Object -Property DistinguishedName,ManagedBy,Name,ObjectClass,ObjectGUID

    
        return $OUs
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

    try {
        $Users = Get-ADUser -Filter ("MiddleName -eq $HoneyExtensionCode") -Properties  "OtherName" -Server $DomainController | Select-Object -Property DistinguishedName,Enabled,GivenName,Name,ObjectClass,ObjectGUID,OtherName,SamAccountName,SID,Surname,UserPrincipalName
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

    try {
        Set-ADUser -Identity $ObjectDN -Add @{extensionAttribute4="myString"}    
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
        $HoneyUserOu = 'OU=ActivtySimulatorUsers,OU=Demo Users,DC=berg,DC=com',
        $DomainController = 'BC-DC.berg.com',
        $Cred = "test"
    )
    ### TODO PAram all the thigns but randomize it if none provided

    $RandomUserDetails = Get-RandomPerson
    Write-AuditLog ("Creating Random User: $($RandomUserDetails.samaccountname)")
    
    
    try {
        
        # TODO - Consider Optional WEAK Password List for the Honey User
        $RandomPassword = ConvertTo-SecureString -String (([char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126)) + 0..9 | sort {Get-Random})[0..8] -join '') -AsPlainText -Force
        $HoneyUser = New-ADUser -Name $RandomUserDetails.samaccountname -GivenName $RandomUserDetails.firstname -Surname $RandomUserDetails.lastname -EmailAddress $RandomUserDetails.email -DisplayName $RandomUserDetails.displayname -Enabled $true -AccountPassword $RandomPassword -Path $HoneyUserOu -PassThru -Server $DomainController 
        Set-ADUser -Identity $HoneyUser.DistinguishedName -OtherName $HoneyExtensionCode -Server $DomainController
        $HoneyUserDetails = Get-ADUser -Identity $HoneyUser.DistinguishedName -Properties * -Server $DomainController

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

