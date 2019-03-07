
New-UDPage -Name "Domain Connection" -Icon server -Content {
    
    Write-AuditLog -BSLogContent "Loaded Domain Connection Page"

    # FIRST CHECK AND SEE IF I HAVE AN EXISTING DOMAIN CONNECTION

    Write-AuditLog -BSLogContent "Domain Connection Page checking for existing domain data"
    $ExistingDomainConfiguration = Get-BHDomainData
    if($ExistingDomainConfiguration)
    {
        Write-AuditLog -BSLogContent "Domain Connection Page found Existing Domain Data!"
        New-UDGrid -Title "Existing Domain Connection" -Headers @("Name", "DistinguishedName", "Forest", "Domain Controller") -Properties @("Name", "DistinguishedName", "Forest","InfrastructureMaster") -Endpoint {    
            Get-BHDomainData | Out-UDGridData
        }
    }


    

    # TODO - should do something about being able to sync with a domain even
    # Though my workstation is not domain joined. 
    

    New-UDInput -Title "Domain Sync" -Id "HoneyDomainInput" -Content {
        
        New-UDInputField -Type 'textbox' -Name 'txtboxDomain' -DefaultValue "Null" -Placeholder "Enter your Domain"

    } -Endpoint {
        param($txtboxDomain)

        if($txtboxDomain)
        {
            Write-AuditLog -BSLogContent "Attempting to Connect to Domain: $txtboxDomain"
            
            ### Do the Domain Get Here
            $FoundDomain = Get-BHDomain -DomainName $txtboxDomain

            If($FoundDomain)
            {
                Write-AuditLog -BSLogContent "Found Domain: $($FoundDomain.DistinguishedName)!"
                
                ### Save Data
                Write-BHDomainData -DomainData $FoundDomain
                
                Invoke-BHFullADSync -DomainController $($FoundDomain.InfrastructureMaster)

                New-UDGrid -Title "Domain Information" -Headers @("Name", "DistinguishedName", "Forest", "InfrastructureMaster") -Properties @("Name", "DistinguishedName", "Forest","InfrastructureMaster") -Endpoint {    
                Get-BHDomainData | Out-UDGridData
            }

            }
            else {

                Write-AuditLog -BSLogContent "Could NOT Find Domain: $txtboxDomain!"
                New-UDInputAction -Toast "Failed to find Domain!"

            }


        }
        else
        {
            New-UDInputAction -Toast "Enter a Valid Domain Name"
        }
        


        
        



  
    }    

    
}
