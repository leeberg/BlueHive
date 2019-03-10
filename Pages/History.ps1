

New-UDPage -Name "History" -Icon book -Content {
            
       
    $JsonData = Get-BHDeploymentHistoryData
    New-UDGrid -Title "BlueHive Change History" -Headers @("Type", "Description", "TimeStamp") -Properties @("type", "description","timestamp") -Endpoint {    
            $JsonData | Out-UDGridData
    }


    
    
}
