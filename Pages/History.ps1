

New-UDPage -Name "History" -Icon book -Content {
            
    New-UDGrid -Title "BlueHive Change History" -Headers @("Type", "Description", "TimeStamp") -Properties @("type", "description","timestamp") -Endpoint { 
        $JsonData = Get-BHDeploymentHistoryData
        $JsonData | Out-UDGridData
    }

}
