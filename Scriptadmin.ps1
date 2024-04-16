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

$Encrypted = "76492d1116743f0423413b16050a5345MgB8AHUAUQBFAGgANwBpAGYAdQBVAFUAdwByAGwAVwBoAEUAMgBtAFkAbAA0AHcAPQA9AHwANQAyADUANwAwADMAMQAxADMAZgBlAGQAZAAyADQAZgBkADIANwBiADIANQA3ADcAYwAwAGIAOQAxADEANgA0ADgAOAA4ADMAMAA0AGUAMwBlAGUAYgBkAGMANgA2AGEAMwAzADUAMABmAGUANgBiADkAZQAwADgAOABjAGUAMwA0ADYAMwBjADUAYwA0ADIAYQAyADkAYgA3ADkAMQA4AGMAMAAzAGYAZQBjADUANgAxAGMAYgA2AGMAMwAyADIA"


[Byte[]] $key = (1..16)

#Settings for the password
$PasswordSecured = ConvertTo-SecureString -String $Encrypted -Key $Key
$marshal = [System.Runtime.InteropServices.Marshal]
$bstr = $marshal::SecureStringToBSTR($PasswordSecured)
$pass = $marshal::PtrToStringAuto($bstr) 



#Set the password for the Disabled Admin account 
([adsi]"WinNT://$computername/$adminname").setpassword($Pass)
