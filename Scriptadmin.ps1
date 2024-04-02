#REM==========================================
#REM Create an Admin Password
#REM==========================================
#REM Created Date : 02 April 2024
#REM Update Date  : 02 April  2024
#REM Author : Raptor J (AKA Mecca)
#REM 
#REM Script Details:
#REM --------------
#REM  This script will:
#REM       + Select the computer by name
#REM       + then access the password file
#REM       + Create a password for the account
#REM 
#REM===========================================




$compname = $env:COMPUTERNAME
$adminname = "DisabledAdmin"

$file = "\\mxl0063knr\DeploymentShare11\Keys\Pass.txt"

[Byte[]] $key = (1..16)

#Settings for the password
$PasswordSecured = Get-Content $File | ConvertTo-SecureString -Key $Key
$marshal = [System.Runtime.InteropServices.Marshal]
$bstr = $marshal::SecureStringToBSTR($PasswordSecured)
$pass = $marshal::PtrToStringAuto($bstr) 



#Set the password for the Disabled Admin account 
([adsi]"WinNT://$computername/$adminname").setpassword($Pass)
