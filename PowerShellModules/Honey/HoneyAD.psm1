Function Get-AllADUsers
{
    param(
        $HoneyExtensionField = 'OtherName'
    )
    
    
    # TODO THIS IS GETTING FROM AD - Seperate this in a new module
    $Users = Get-ADUser -filter * -Properties  "OtherName"
    
    return $Users

}

Function Get-HoneyADusers
{
    param(
        $HoneyExtensionField = 'OtherName',
        $HoneyExtensionCode = '1337'
    )

   $Users = Get-ADUser -Filter ("$HoneyExtensionField -eq $HoneyExtensionCode") -Properties  "OtherName"

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
    
    param(
        $HoneyExtensionField = 'OtherName',
        $HoneyExtensionCode = '1337'
    )
    ### TODO PAram all the thigns but randomize it if none provided

    $RandomUserDetails = Get-RandomPerson
    Write-AuditLog ("Creating Random User: $($RandomUserDetails.samaccountname)")
    $RandomPassword = ConvertTo-SecureString -String (([char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126)) + 0..9 | sort {Get-Random})[0..8] -join '') -AsPlainText -Force
    $HoneyUser = New-ADUser -Name $RandomUserDetails.samaccountname -GivenName $RandomUserDetails.firstname -Surname $RandomUserDetails.lastname -EmailAddress $RandomUserDetails.email -DisplayName $RandomUserDetails.displayname -Enabled $true -AccountPassword $RandomPassword  -PassThru
    
    Set-ADUser -Identity $HoneyUser.DistinguishedName -OtherName $HoneyExtensionCode
}

