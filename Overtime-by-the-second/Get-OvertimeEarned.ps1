param (
    $startDate= "2019-08-20 08:30:00",
    $hourlyRate = "12.34",
    [System.Boolean]$keeprefreshing = $true
)

while ($keeprefreshing) {
 Clear-Host
 $hourlyCalc = (New-TimeSpan -Start $startDate -End (Get-Date)).TotalHours * $hourlyRate
 $hourlyCalc = [math]::Round($hourlyCalc,2)
 Write-Host "Since start date of $startDate"   
 Write-Host "£$hourlyCalc"
 Start-Sleep -Seconds 1
}