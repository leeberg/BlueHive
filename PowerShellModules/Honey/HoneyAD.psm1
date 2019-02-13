Function Get-AllADUsers
{
    # TODO THIS IS GETTING FROM AD - Seperate this in a new module
    $Users = Get-ADUser -filter * #-Properties *

    return $Users



}

Function Set-ExtensionAttribute
{
    Param(
        $ObjectDN = 'CN=Alexandria Jomes,OU=ActivtySimulatorUsers,OU=Demo Users,DC=berg,DC=com'
    )


    Set-ADUser -Identity $ObjectDN -Add @{extensionAttribute4="myString"}
}




Function Deploy-HoneyUserAccount
{   
    
    ### TODO PAram all the thigns but randomize it if none provided

    $RandomUserDetails = Get-RandomPerson
    Write-AuditLog ("Creating Random User: $($RandomUserDetails.samaccountname)")
    New-ADUser -Name $RandomUserDetails.samaccountname -GivenName $RandomUserDetails.firstname -Surname $RandomUserDetails.lastname -EmailAddress $RandomUserDetails.email -DisplayName $RandomUserDetails.displayname
}

