$KBNumber = "KB5036892" # Replace XXXXXXX with the KB number of the update you want to check

$Update = Get-HotFix | Where-Object {$_.HotFixId -eq $KBNumber}

if ($Update) {
    Write-Host "Update $KBNumber is installed."
    exit 0
} else {
    Write-Host "Update $KBNumber is not installed."
    exit 1
}

