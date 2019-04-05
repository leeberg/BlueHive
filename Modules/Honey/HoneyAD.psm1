<# TODO 

NEED TO migration these modules to essential take the @Cache:ConnectionInfo object in - then I can pass that to the domain I am trying to connect to.
#>


function Get-BHDomain {
    param (
        [Parameter(Mandatory=$true)]
        [String]$DomainName
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

    # TODO Implement Domain Searching / Params
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
        $Domain = ''
    )
        
    Write-AuditLog ("Running Function: Get-AllADUsers")
    # TODO Implement Domain Searching
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
    # TODO Implement Domain Searching
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
        
        [Parameter(Mandatory=$true)]
        [String]$Password
   
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


Function Remove-BHADUser
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

        [Parameter(Mandatory=$true)]
        [String]$DistinguishedName,
        
        [Parameter(Mandatory=$true)]
        [String]$State
        
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
    elseif($State -eq "Enabled")
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
    else {
        Write-AuditLog ("Bad State Given!")
    }

}





Function Set-ExtensionAttribute
{

    Param(
        [Parameter(Mandatory=$true)]
        [String]$ObjectDN
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


Function Invoke-HoneyUserAccount
{   
    
    param(
        $HoneyExtensionField = 'OtherName',
        $HoneyExtensionCode = '1337',
        [Parameter(Mandatory=$true)]
        [String]$HoneyUserOu,
        $IsServiceAccount = 'False'
    )

    #TODO - Implement the Honey Extension Field to be an EXT attribute or something better
    #TODO PAram all the thigns but randomize it if none provided

    Write-AuditLog ("Running Function: Invoke-HoneyUserAccount")

    if($IsServiceAccount -eq 'True')
    {
        # IF Service account - generate a different format and SPN
        $RandomUserDetails = Get-RandomServiceAccount
        $RandomDC = (Get-BHADDomainControllers | Get-Random | Select-Object -Property HostName).HostName
        $RandomServiceClass = @('MSSQLSvc','DNS','ldap','NTFrs',(New-Guid).Guid),'WEB','iisadmin','dhcp','netlogon' | Get-Random
        $RandomServicePort = @('80','8080','8081','1433','1434','443','4022','135','5432','5433',(Get-Random -Minimum 125 -Maximum 5000)) | Get-Random
        
        $RandomSPN  = ($RandomServiceClass + '/' + $RandomDC + ':' + $RandomServicePort)
        $RanomdSPNHash =@{Add=$RandomSPN}    
        
    }
    else 
    {
        $RandomUserDetails = Get-RandomPerson
    }


    Write-AuditLog ("Creating Random User: $($RandomUserDetails.samaccountname)")
    
    
    try {
        
        # TODO - Consider Optional WEAK Password List for the Honey User
        $RandomPassword = ConvertTo-SecureString -String (([char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126)) + 0..9 | sort {Get-Random})[0..8] -join '') -AsPlainText -Force
        
        if($IsServiceAccount -eq 'True')
        {
            $HoneyUser = New-ADUser -Name $RandomUserDetails.samaccountname -EmailAddress $RandomUserDetails.email -DisplayName $RandomUserDetails.displayname -Enabled $true -AccountPassword $RandomPassword -Path $HoneyUserOu -PassThru @Cache:ConnectionInfo
            Set-ADUser -Identity $HoneyUser.DistinguishedName -OtherName $HoneyExtensionCode -ServicePrincipalNames $RanomdSPNHash @Cache:ConnectionInfo
            
        }
        else 
        {
            $HoneyUser = New-ADUser -Name $RandomUserDetails.samaccountname -GivenName $RandomUserDetails.firstname -Surname $RandomUserDetails.lastname -EmailAddress $RandomUserDetails.email -DisplayName $RandomUserDetails.displayname -Enabled $true -AccountPassword $RandomPassword -Path $HoneyUserOu -PassThru @Cache:ConnectionInfo
            Set-ADUser -Identity $HoneyUser.DistinguishedName -OtherName $HoneyExtensionCode @Cache:ConnectionInfo
        }

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

