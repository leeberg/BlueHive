New-UDPage -Name "Deployment" -Icon empire -Endpoint {

    $OUs = Get-BHOuData
    $Domains = Get-BHDomainData

    
    

    New-UDInput -Title "Deploy Honey User" -Id "HoneyUserInput" -Content {
        
        New-UDInputField -Type 'select' -Name 'DeploymentOU' -Values $OUs.DistinguishedName -DefaultValue (($OUs | Select-Object -First 1).DistinguishedName) -Placeholder "Select an OU to Deploy User Into"
        New-UDInputField -Type 'select' -Name 'DomainName' -Values $Domains.NetBIOSName -DefaultValue (($Domains| Select-Object -First 1).NetBIOSName) -Placeholder "Select an DC to Deploy User with"
        New-UDInputField -Type 'select' -Name 'Count' -Values @(1,5,10,15,25,50) -DefaultValue 1 -Placeholder "Specify Number of Accounts to Create"
        New-UDInputField -Type 'select' -Name 'ServiceAccount' -Values @('True','False') -DefaultValue 'False' -Placeholder "Is Service Account?"

    } -Endpoint {
        param($DeploymentOU,$DomainName,$Count,$ServiceAccount)

        Write-AuditLog -BSLogContent "Attempting to Create $Count Honey User(s) in OU: $DeploymentOU OU - Using: $DomainName"
        
        # Created OK is used to indicate if AT LEAST one account was created ok... 
        $CreatedUserOK = $false

        $DeployedUsers = @();
        For ($i=0; $i -lt $Count; $i++) {
            
            $NewHoneyUser = Invoke-HoneyUserAccount -HoneyUserOu $DeploymentOU -IsServiceAccount $ServiceAccount
       
            If($NewHoneyUser)
            {
                $CreatedUserOK = $true
                $DeployedUsers += $NewHoneyUser
                Write-DeploymentHistoryLog -Description "Deployed: $($NewHoneyUser.SamAccountname) to: $DomainName" -Type "Deployment"
            }
            else
            {
               #Failed
               # TODO Something here
            }

        }        
        
        if($CreatedUserOK -eq $true)
        {
            
            
            # TODO - Used to resync all honey users here... probably not needed - can do this better
            $DomainObject = Get-BHDomain -DomainName $DomainName
            Save-AllADHoneyUsers -Domain $DomainObject

            Show-UDModal -Content {
                New-UDHeading -Size 4 -Text "Honey User Deployment"
                #New-UDHeading -Size 6 -Text "Honey User: $($DeployedUsers.SamAccountname) Created!"
                    
                New-UDTable -Title "Agent Results" -Headers @("DisplayName", "DistinguishedName") -Endpoint {
                    $DeployedUsers | ForEach-Object{      
                        [PSCustomObject]@{
                            DisplayName = $_.DisplayName
                            DistinguishedName = $_.DistinguishedName
                        }
                    } | Out-UDTableData -Property @("DisplayName", "DistinguishedName")
                        
                }
            }
        }
        else {
            New-UDInputAction -Toast "Unable to Create User(s)"
        }
        
             

        Write-AuditLog -BSLogContent "Honey User Deployment Results: Retrieval and Display Completed"
  
    }    

    
}
