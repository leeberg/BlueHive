
function Get-BHDomain {
    param (
        $DomainName = 'berg.com'
    )

    $RetrievedDomain = Get-ADDomain $DomainName
     
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
    
        $Users = Get-ADUser -filter * -Properties "OtherName","PrimaryGroup" -Server $DomainController
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
        $OUs = Get-ADOrganizationalUnit -Filter * -Properties DistinguishedName -Server $DomainController
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
        $Users = Get-ADUser -Filter ("$HoneyExtensionField -eq $HoneyExtensionCode") -Properties  "OtherName" -Server $DomainController
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




Function Deploy-HoneyUserAccount
{   
    
    param(
        $HoneyExtensionField = 'OtherName',
        $HoneyExtensionCode = '1337',
        $HoneyUserOu = 'OU=ActivtySimulatorUsers,OU=Demo Users,DC=berg,DC=com'
    )
    ### TODO PAram all the thigns but randomize it if none provided

    $RandomUserDetails = Get-RandomPerson
    Write-AuditLog ("Creating Random User: $($RandomUserDetails.samaccountname)")
    
    
    try {
    
        $RandomPassword = ConvertTo-SecureString -String (([char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126)) + 0..9 | sort {Get-Random})[0..8] -join '') -AsPlainText -Force
        $HoneyUser = New-ADUser -Name $RandomUserDetails.samaccountname -GivenName $RandomUserDetails.firstname -Surname $RandomUserDetails.lastname -EmailAddress $RandomUserDetails.email -DisplayName $RandomUserDetails.displayname -Enabled $true -AccountPassword $RandomPassword -Path $HoneyUserOu -PassThru 
        Set-ADUser -Identity $HoneyUser.DistinguishedName -OtherName $HoneyExtensionCode
        $HoneyUserDetails = Get-ADUser -Identity $HoneyUser.DistinguishedName -Properties *

        Write-AuditLog ("Created Random User: $($RandomUserDetails.samaccountname) OK!")

        return $HoneyUserDetails

    }
    catch {

        $Exception = $_.Exception
        $ExceptionMessage = $Exception.Message
        Write-AuditLog ("Failed to Create Random User: $($RandomUserDetails.samaccountname)!")
        Write-ErrorLog ("Failed to Create Random User: $($RandomUserDetails.samaccountname)!")
        Write-ErrorLog $ExceptionMessage
        return $null
    }
    

    
}

