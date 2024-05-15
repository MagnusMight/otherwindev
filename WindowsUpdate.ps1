if ("$env:PROCESSOR_ARCHITECTURE6432" -ne "ARM64") {
    if (Test-Path "$($env:windir)\sysnative\windowspowershell\v1.0\powershell.exe") {
        & "$($env:windir)\sysnative\windowspowershell\v1.0\powershell.exe" -executionpolicy bypass -noProfile -file "$PSCommandPath"
        Exit $LASTEXITCODE
    }
}

$KBNumber = "KB5036892" # Replace XXXXXXX with the KB number of the update you want to check

$Update = Get-HotFix | Where-Object { $_.HotFixId -eq $KBNumber }

if ($Update) {
    Write-Host "Update $KBNumber is installed."
    exit 0
}
else {
    Write-Host "Update $KBNumber is not installed."
    #Check for NuGet
    $NuGet = Get-PackageProvider -Name NuGet -ErrorAction Ignore
    Write-Host "Checking for Nuget..... "
    if (-not($NuGet)) {
        Write-Host"NuGet not found. Installing now..."
        try {
            Install-PackageProvider -Name NuGet -Confirm:$false -Force
            Write-Host "NuGet Installed"
        }
        catch {
            $message = $_
            Write-Host "Error installing Nuget: $message"
        }
    
    }
    else {
        Write-Host "NuGet already installed"
    }
    $moduleNames = @('PSWindowsUpdate',
        'BurntToast',
        'RunasUser')

    foreach ($moduleName in $moduleNames) {
        $installed = Get-InstalledModule -Name $moduleName
        Write-Host "Checking if $($moduleName) is installed...."
        If (-not($installed)) {
            Write-Host "$($moduleName) not found. Installing now...."
            try {
                Install-Module -Name $moduleName -Confirm:$false -Force
                Import-Module $moduleName
                Write-Host "$($moduleName) Installed"
            }
            catch {
                $message = $_
                Write-Host "Error Installing $($moduleName): $message"
            }
        }
        else {
            Write-Host "$($moduleName) already installed"
            Import-Module $moduleName
        }

    }
    # Copy image files for toast
    $temppath = "C:\Temp\updatesstuff"
    if (!(Test-Path $temppath)) {
        mkdir $temppath
    }
    #Copy-Item -Path "$($PSScriptRoot)\klogo.png" -Destination "$($temppath)\klogo.png" -Force
    $url = "https://i.ibb.co/s6dgGpY/kyowa-hakko-Company-logo.png"
    $outputPath = "$($temppath)\kyowa-hakko-Company-logo.png"

    Invoke-WebRequest -Uri $url -OutFile $outputPath



    $Toast1 = {
        $header = New-BTHeader -Title 'Windows Update Installing'
        $button = New-BTButton -content 'Dismiss' -Dismiss
        $text = "Get ready while we install Security Updates to your machine."
        $img = "C:\Temp\updatesstuff\kyowa-hakko-Company-logo.png"
        $Progress = New-BTProgressBar -status 'Installing.....' -Indeterminate
        New-BurntToastNotification -Text $text -Button $button -header $header -HeroImage $img -ProgressBar $Progress

    }

    $Toast2 = {
        $header = New-btheader -Title 'Windows Update Installed'
        $button = New-BTButton -content 'Dismiss' -Dismiss
        $text = "Windows Update has been successfully installed. PLEASE SAVE YOUR WORK AND RESTART TO COMPLETE."
        $img = "C:\Temp\updatesstuff\kyowa-hakko-Company-logo.png"
        New-BurntToastNotification -Text $text -Button $button -Header $header -HeroImage $img 
    }

    Invoke-AsCurrentUser -ScriptBlock $Toast1 -UseWindowsPowerShell
    Get-WindowsUpdate -Severity Critical -Download -AcceptAll
    Start-Sleep -Seconds 60
    Install-WindowsUpdate -Severity Critical -AcceptAll -IgnoreReboot
    Invoke-AsCurrentUser -ScriptBlock $Toast2 -UseWindowsPowerShell
}