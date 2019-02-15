

New-UDPage -Name "Home" -Icon home -Content {
            
       
    $JsonData = Get-BHHoneyAccountData
    New-UDGrid -Title "Managed Honey Account Users" -Headers @("Name", "GivenName", "Surname","Enabled") -Properties @("Name", "GivenName", "Surname","Enabled") -Endpoint {    
            $JsonData | Out-UDGridData
    }


    $JsonData = Get-BHAccountData
    New-UDGrid -Title "All Active Directory Users" -Headers @("Name", "GivenName", "Surname","Enabled") -Properties @("Name", "GivenName", "Surname","Enabled") -Endpoint {    
            $JsonData | Out-UDGridData
    }
    
    
}
