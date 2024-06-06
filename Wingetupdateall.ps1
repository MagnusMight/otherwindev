<# FUNCTIONS #>
#Log Function

#Install-Prerequisites
function Install-Prerequisites {

    #Write-ToLog "Checking prerequisites..." "Cyan"

    #Check if Visual C++ 2019 or 2022 installed
    $Visual2019 = "Microsoft Visual C++ 2015-2019 Redistributable*"
    $Visual2022 = "Microsoft Visual C++ 2015-2022 Redistributable*"
    $path = Get-Item HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.GetValue("DisplayName") -like $Visual2019 -or $_.GetValue("DisplayName") -like $Visual2022 }

    #If not installed, download and install
    if (!($path)) {

        #Write-ToLog "Microsoft Visual C++ 2015-2022 is not installed." "Red"

        try {
            #Get proc architecture
            if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") {
                $OSArch = "arm64"
            }
            elseif ($env:PROCESSOR_ARCHITECTURE -like "*64*") {
                $OSArch = "x64"
            }
            else {
                $OSArch = "x86"
            }

            #Download and install
            $SourceURL = "https://aka.ms/vs/17/release/VC_redist.$OSArch.exe"
            $Installer = "$env:TEMP\VC_redist.$OSArch.exe"
            #Write-ToLog "-> Downloading $SourceURL..."
            Invoke-WebRequest $SourceURL -UseBasicParsing -OutFile $Installer
            #Write-ToLog "-> Installing VC_redist.$OSArch.exe..."
            Start-Process -FilePath $Installer -Args "/passive /norestart" -Wait
            Start-Sleep 3
            Remove-Item $Installer -ErrorAction Ignore
            #Write-ToLog "-> MS Visual C++ 2015-2022 installed successfully." "Green"
        }
        catch {
            #Write-ToLog "-> MS Visual C++ 2015-2022 installation failed." "Red"
        }

    }

    #Check if Microsoft.VCLibs.140.00.UWPDesktop is installed
    if (!(Get-AppxPackage -Name 'Microsoft.VCLibs.140.00.UWPDesktop' -AllUsers)) {
        #Write-ToLog "Microsoft.VCLibs.140.00.UWPDesktop is not installed" "Red"
        $VCLibsUrl = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
        $VCLibsFile = "$env:TEMP\Microsoft.VCLibs.x64.14.00.Desktop.appx"
        #Write-ToLog "-> Downloading $VCLibsUrl..."
        Invoke-RestMethod -Uri $VCLibsUrl -OutFile $VCLibsFile
        try {
            #Write-ToLog "-> Installing Microsoft.VCLibs.140.00.UWPDesktop..."
            Add-AppxProvisionedPackage -Online -PackagePath $VCLibsFile -SkipLicense | Out-Null
            #Write-ToLog "-> Microsoft.VCLibs.140.00.UWPDesktop installed successfully." "Green"
        }
        catch {
            #Write-ToLog "-> Failed to intall Microsoft.VCLibs.140.00.UWPDesktop..." "Red"
        }
        Remove-Item -Path $VCLibsFile -Force
    }

    #Check available WinGet version, if fail set version to the latest version as of 2024-04-29
    $WingetURL = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'
    try {
        $WinGetAvailableVersion = ((Invoke-WebRequest $WingetURL -UseBasicParsing | ConvertFrom-Json)[0].tag_name).Replace("v", "")
    }
    catch {
        $WinGetAvailableVersion = "1.7.11132"
    }

    #Get installed Winget version
    try {
        $WingetInstalledVersionCmd = & $Winget -v
        $WinGetInstalledVersion = (($WingetInstalledVersionCmd).Replace("-preview", "")).Replace("v", "")
        #Write-ToLog "Installed Winget version: $WingetInstalledVersionCmd"
    }
    catch {
        #Write-ToLog "WinGet is not installed" "Red"
    }

    #Check if the available WinGet is newer than the installed
    if ($WinGetAvailableVersion -gt $WinGetInstalledVersion) {

        #Write-ToLog "-> Downloading Winget v$WinGetAvailableVersion"
        $WingetURL = "https://github.com/microsoft/winget-cli/releases/download/v$WinGetAvailableVersion/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $WingetInstaller = "$env:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        Invoke-RestMethod -Uri $WingetURL -OutFile $WingetInstaller
        try {
            Write-ToLog "-> Installing Winget v$WinGetAvailableVersion"
            Add-AppxProvisionedPackage -Online -PackagePath $WingetInstaller -SkipLicense | Out-Null
            #Write-ToLog "-> Winget installed." "Green"
        }
        catch {
            #Write-ToLog "-> Failed to install Winget!" "Red"
        }
        Remove-Item -Path $WingetInstaller -Force
    }

    #Write-ToLog "Checking prerequisites ended.`n" "Cyan"

}



#Software to be installed
$ResolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
    if ($ResolveWingetPath){
           $WingetPath = $ResolveWingetPath[-1].Path
    }

$Wingetpath = Split-Path -Path $WingetPath -Parent
cd $wingetpath
.\winget upgrade --all --accept-package-agreements --accept-source-agreements
.\winget upgrade --all -s msstore --silent --accept-package-agreements --accept-source-agreements
