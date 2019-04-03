

New-UDPage -Name "Home" -Icon home -Content {

    $HoneyUsers = Get-BHHoneyAccountData
    $UserAccounts = Get-BHAccountData
    $DeploymentHistory = Get-BHDeploymentHistoryData


    
    <##>
    New-UDLayout -Columns 4 -Content {  
      
        New-UDCard -Id "card_Honey" -Title 'Deployed Honey Accounts' -Text ($HoneyUsers | Measure).Count  -BackgroundColor '#379af0' 
        New-UDCard -Id "care_Deployments" -Title "Deployment Actions" -Text ($DeploymentHistory | Measure).Count  -BackgroundColor '#26c6da'
    
    }


    New-UDGrid -Title "Managed Honey Account Users" -Headers @("Name","Enabled","DeploymentDate") -Properties @("DisplayName", "Enabled", "whenCreated") -Endpoint {    
            $HoneyUsers | Out-UDGridData
    }


    
    New-UDGrid -Title "All Active Directory Users" -Headers @("Name", "GivenName", "Surname","Enabled") -Properties @("Name", "GivenName", "Surname","Enabled") -Endpoint {    
            $UserAccounts | Out-UDGridData
    }
    
    
}
