$processName = "SteelSeriesSonar"

if (Get-Process -Name $processName -ErrorAction SilentlyContinue) {
    Write-Host "$processName is running."
} else {
    Write-Host "$processName is not running."
}