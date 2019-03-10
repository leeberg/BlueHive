

New-UDPage -Name "History" -Icon book -Content {
            
       
    $JsonData = Get-BHDeploymentHistoryData
    New-UDGrid -Title "Managed Honey Account Users" -Headers @("Type", "Description", "TimeStamp") -Properties @("type", "description","timestamp") -Endpoint {    
            $JsonData | Out-UDGridData
    }


    
    
}
