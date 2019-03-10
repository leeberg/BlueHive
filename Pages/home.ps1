

New-UDPage -Name "Home" -Icon home -Content {

    $HoneyUsers = Get-BHHoneyAccountData
    $UserAccounts = Get-BHAccountData
    $History = Get-BHDeploymentHistoryData

    New-UDRow -Columns {
        

        New-UDColumn -Size 2 {    

            New-UDCounter -Title "Deployed Honey Accounts" -Endpoint {
                ($HoneyUsers | Measure).Count | ConvertTo-Json
            } -FontColor "black"

        }

        New-UDColumn -Size 2 {    

                New-UDCounter -Title "Deployment Actions" -Endpoint {
                    ($History | Measure).Count | ConvertTo-Json
                } -FontColor "black"
    
            }

    }



    New-UDGrid -Title "Managed Honey Account Users" -Headers @("Name","Enabled","DeploymentDate") -Properties @("DisplayName", "Enabled", "whenCreated") -Endpoint {    
            $HoneyUsers | Out-UDGridData
    }


    
    New-UDGrid -Title "All Active Directory Users" -Headers @("Name", "GivenName", "Surname","Enabled") -Properties @("Name", "GivenName", "Surname","Enabled") -Endpoint {    
            $UserAccounts | Out-UDGridData
    }
    
    
}
