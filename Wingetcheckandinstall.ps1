#REM==========================================
#REM Winget check and insall
#REM==========================================
#REM Created Date : 25 April 2024
#REM Update Date  : 25 April  2024
#REM Author : Mecca
#REM 
#REM Script Details:
#REM --------------
#REM  This script will:
#REM      
#REM      
#REM      
#REM 
#REM===========================================


## Test if winget command can run from CMD/PS, if it can't, install prerequisites (if needed) and update to latest version
try {
	winget --version
	Write-host "Winget is present" -ForegroundColor Green
} catch {
	Write-Host "Checking prerequisites and updating winget..."
	$package = Get-AppxPackage -Name "Microsoft.UI.Xaml.2.8"
	if ($package) {
		Write-Host "Microsoft.UI.Xaml.2.8 is installed."
	} else {
		Write-Host "Installing Microsoft.UI.Xaml.2.8..."
		Add-AppxPackage https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/microsoft.ui.xaml.2.8.x64.appx
	}
<## Update Microsoft.VCLibs.140.00.UWPDesktop
		Write-Host "Updating Microsoft.VCLibs.140.00.UWPDesktop..."
		Invoke-WebRequest `
			-URI https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx `
			-OutFile UWPDesktop.appx -UseBasicParsing
		Add-AppxPackage UWPDesktop.appx
		Remove-Item UWPDesktop.appx##>

## Install latest version of Winget
Write-Host "Installing WinGet...."
 Add-AppxPackage https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
}

finally{

Write-host "Making sure it is the right version" -ForegroundColor Yellow
    $package = Get-AppxPackage -Name "Microsoft.UI.Xaml.2.8"
	if ($package) {
		Write-Host "Microsoft.UI.Xaml.2.8 is installed. Seems Updated to me" -ForegroundColor Green
	} else {
		Write-Host "Installing Microsoft.UI.Xaml.2.8..."
		Add-AppxPackage https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/microsoft.ui.xaml.2.8.x64.appx 
        Add-AppxPackage https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
	}






}
