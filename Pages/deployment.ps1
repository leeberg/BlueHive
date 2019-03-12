
$OUs = Get-BHOuData
$Domains = Get-BHDomainData

New-UDPage -Name "Honey Deployment" -Icon empire -Content {
        
    New-UDInput -Title "Deploy Honey User" -Id "HoneyUserInput" -Content {
        
        New-UDInputField -Type 'select' -Name 'DeploymentOU' -Values $OUs.DistinguishedName -DefaultValue "Null" -Placeholder "Select an OU to Deploy User Into"
        ### TODO - should be a DOMAIN SELECT!!!
        New-UDInputField -Type 'select' -Name 'DomainName' -Values $Domains.NetBIOSName -DefaultValue "Null" -Placeholder "Select an DC to Deploy User with"

    } -Endpoint {
        param($DeploymentOU,$DomainName)

        Write-AuditLog -BSLogContent "Attempting to Create Honey User in OU: $DeploymentOU OU - Using: $DomainName"

        $NewHoneyUser = Invoke-HoneyUserAccount -HoneyUserOu $DeploymentOU       
       
        If($NewHoneyUser)
        {

            Write-DeploymentHistoryLog -Description "Deployed: $($NewHoneyUser.SamAccountname) to: $DomainName" -Type "Deployment"

            # RE SYNC HONEY USERS
            $DomainObject = Get-BHDomain -DomainName $DomainName
            Save-AllADHoneyUsers -Domain $DomainObject

            Show-UDModal -Content {
                New-UDHeading -Size 4 -Text "Honey User Deployment"
                New-UDHeading -Size 6 -Text "Honey User: $($NewHoneyUser.SamAccountname) Created!"
                
                New-UDTable -Title "Agent Results" -Headers @("DisplayName", "DistinguishedName") -Style striped -Endpoint {
                    $NewHoneyUser | Out-UDTableData -Property @("DisplayName", "DistinguishedName")
                    
                }
            }
        }
        else {

            New-UDInputAction -Toast "Failed to Create Honey User!"

        }
        


        Write-AuditLog -BSLogContent "Honey User Deployment Results: Retrieval and Display Completed"
  
    }    

    
}
