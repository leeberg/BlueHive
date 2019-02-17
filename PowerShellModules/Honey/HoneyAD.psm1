Function Get-AllADUsers
{
    param(
        $HoneyExtensionField = 'OtherName'
    )
        

    try {
    
        $Users = Get-ADUser -filter * -Properties "OtherName","PrimaryGroup"
        return $Users    
    }
    catch {
        return $null    
    }
    

}


Function Get-AllADOrganizationalUnits
{
    try{
        $OUs = Get-ADOrganizationalUnit -Filter * -Properties DistinguishedName
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
        $HoneyExtensionCode = '1337'
    )

    try {
        $Users = Get-ADUser -Filter ("$HoneyExtensionField -eq $HoneyExtensionCode") -Properties  "OtherName"
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
        Write-AuditLog ("Failed to Create Random User: $($RandomUserDetails.samaccountname) OK!")
        Write-ErrorLog ("Failed to Create Random User: $($RandomUserDetails.samaccountname) OK!")
        Write-ErrorLog $ExceptionMessage
        return $null
    }
    

    
}

