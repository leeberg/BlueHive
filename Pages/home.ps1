

New-UDPage -Name "Home" -Icon home -Content {
            
       

    $JsonData = Get-BHAccountData
    New-UDGrid -Title "Active Directory Users" -Headers @("Name", "GivenName", "Surname","Enabled") -Properties @("Name", "GivenName", "Surname","Enabled") -Endpoint {    
            $JsonData | Out-UDGridData
    }
    
    
}
