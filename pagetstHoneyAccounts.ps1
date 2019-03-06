$JsonData = Get-BHHoneyAccountData

New-UDGrid -Title "Managed Honey Account Users" -Headers @("Name","Enabled"," ") -Properties @("Name","Enabled","Manage") -Endpoint {    
         $JsonData | ForEach-Object {

            [PSCustomObject]@{
                Name = $_.Name
                Enabled = $_.Enabled
                Manage = New-UDButton -Text "Manage" -OnClick (New-UDEndpoint -Endpoint { 
        
                    $HoneyUser = $ArgumentList[0]
                    
                    Write-AuditLog -BSLogContent "Opening Management for: $HoneyUser"
        
                    Show-UDModal -Content {
                            
                            New-UDTable -Title "Honey User Details" -Headers @("Name", "Description", "Agent") -Endpoint {
                                @{
                                    'Name' = $ModuleName
                                    'Description' = $ModuleDescription
                                    'Agent' = $EmpireAgentName
                                } | Out-UDTableData -Property @("Name", "Description", "Agent")
                                
                            }

                            New-UDInput -Title "Execute Strike Package" -Id "AgentModuleOperations" -SubmitText "Submit" -Content {
                                New-UDInputField -Type 'textbox' -Name 'Options'
                            } -Endpoint {
                            
                                ## GET EMPIRE CONFIGO
                                
                                $EmpireConfiguration = Get-BSEmpireConfigData
                                
                                $EmpireBox = $EmpireConfiguration.empire_host
                                $EmpirePort = $EmpireConfiguration.empire_port
                                $EmpireToken = $EmpireConfiguration.empire_token
        
                                $Text = 'Empire Operations: Executing Action: ' +  $ModuleName +' on: ' + $EmpireAgentName + " which lives on $EmpireBox"
                                New-UDInputAction -Toast $Text
                                Write-BSAuditLog -BSLogContent $Text
                             
                                $EmpireModuleExeuction =  Start-BSEmpireModuleOnAgent -EmpireBox $EmpireBox -EmpireToken $EmpireToken -EmpirePort $EmpirePort -AgentName $EmpireAgentName -ModuleName $ModuleName -Options $ModuleOptions
                                
        
                                Clear-UDElement -Id "StrikePackageExecution"
                                Add-UDElement -ParentId "StrikePackageExecution" -Content {
                                        New-UDHtml -Markup '<b>STRIKE STATUS: <font size="3" color="red">EXECUTED</font></b>'
                                }
        
        
                            }
        
        
                            New-UDElement -Id "StrikePackageExecution" -Tag "b" -Content  {"STRIKE STATUS: DEPLOYMENT READY"}
        
                            
                        } 
        
                } -ArgumentList $Session:CurrentlySelectedAgent, $_.Name, $_.Description, $_.Options)
           }
        } | Out-UDGridData
 }
