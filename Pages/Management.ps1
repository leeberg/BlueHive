

New-UDPage -Name "Managment" -Icon wrench -Content {
   
    $HoneyAccounts = Get-BHHoneyAccountData

    
    New-UDGrid -Title "Managed Honey Account Users" -Headers @("Name", "DeploymentDate" ,"Enabled", "Modify", "Delete") -Properties @("DisplayName", "whenCreated", "Enabled", "Modify","Delete") -Endpoint {    
        $HoneyAccounts | ForEach-Object{    

            [PSCustomObject]@{
                DisplayName = $_.DisplayName
                whenCreated = $_.whenCreated
                Enabled = $_.Enabled
                DistinguishedName = $_.DistinguishedName
                Modify = New-UDButton -Text "Modify" -OnClick (New-UDEndpoint -Endpoint { 

                    $DistinguishedName = $ArgumentList[0]
                    $ParentNetBios = $ArgumentList[1]
                    
                    $UserDetails = Get-BHDHoneyUserDetailsData -DistinguishedName $DistinguishedName

                    Show-UDModal -Content {
                        New-UDTable -Title "Honey User Details" -Headers @("Name", "DeployedDate", "Enabled") -Endpoint {
                            @{
                                'Name' = $UserDetails.DisplayName
                                'DeployedDate' = $UserDetails.whenCreated
                                'Enabled' = $UserDetails.Enabled
                            } | Out-UDTableData -Property @("Name", "DeployedDate", "Enabled")
                            
                        }
                       
                        New-UDInput -Title "Modify Account" -SubmitText "Apply Changes" -Content {
                             New-UDInputField -Name "Password" -Placeholder "Password" -Type "password"
                             New-UDInputField -Name "State" -Placeholder "User State" -Type "select" -Values @("Enabled","Disabled") -DefaultValue "Enabled"
                        } -Endpoint {
                                    if($Password)
                                    {
                                        try{
                                            Set-UserPassword -DistinguishedName $DistinguishedName -Password $Password
                                        }
                                        catch{
                                            New-UDInputAction -Toast "Failed to Reset Password!"
                                        }

                                         ### TODO Trigger Honey Users RESYNC with DOMAIN PARAM
                                        
                                    }

                                    if($State)
                                    {
                                        try{
                                            Set-UserState -DistinguishedName $DistinguishedName -State $State
                                        }
                                        catch{
                                            New-UDInputAction -Toast "Failed to Change State!"
                                        }
                                        
                                    }

                                     # RUN HONEY USER SYNC
                                     $DomainObject = Get-BHDomain -DomainName $ParentNetBios
                                     Save-AllADHoneyUsers -Domain $DomainObject

                        }

                    } 

                } -ArgumentList $_.DistinguishedName, $_.ParentNetBios)
                Delete = New-UDButton -Text "Delete User" -OnClick (New-UDEndpoint -Endpoint { 

                    $DistinguishedName = $ArgumentList[0]
                    Delete-BHADUser -DistinguishedName $DistinguishedName
                    
                    # RUN HONEY USER SYNC
                    $DomainObject = Get-BHDomain -DomainName $ParentNetBios
                    Save-AllADHoneyUsers -Domain $DomainObject
                    

                } -ArgumentList $_.DistinguishedName, $_.ParentNetBios)
            
            }
        }  | Out-UDGridData
    }

    
}
