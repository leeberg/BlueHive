
$OUs = Get-BHOuData


New-UDPage -Name "Honey Deployment" -Icon empire -Content {
        
    New-UDInput -Title "Deploy Honey User" -Id "HoneyUserInput" -Content {
        
        New-UDInputField -Type 'select' -Name 'DeploymentOU' -Values $OUs.DistinguishedName -DefaultValue "Null" -Placeholder "Select an OU to Deploy User Into"

    } -Endpoint {
        param($DeploymentOU)

        Write-AuditLog -BSLogContent "Attempting to Create Honey User in OU: $DeploymentOU OU"


        $NewHoneyUser = Deploy-HoneyUserAccount -HoneyUserOu $DeploymentOU
        
        If($NewHoneyUser)
        {
            Show-UDModal -Content {
                New-UDHeading -Size 4 -Text "Honey User Deployment"
                New-UDHeading -Size 6 -Text "Honey User: $($NewHoneyUser.SamAccountname) Created!"
                
                New-UDTable -Title "Agent Results" -Headers @("DisplayName", "DistinguishedName","SID") -Style striped -Endpoint {
                    $NewHoneyUser | Out-UDTableData -Property @("DisplayName", "DistinguishedName","SID")
                    
                }
            }
        }
        else {

            New-UDInputAction -Toast "Failed to Create Honey User!"

        }
        


        Write-AuditLog -BSLogContent "Honey User Deployment Results: Retrieval and Display Completed"
  
    }    

    
}
