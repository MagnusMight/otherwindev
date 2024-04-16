#REM==========================================
#REM Create an Admin Password
#REM==========================================
#REM Created Date : 02 April 2024
#REM Update Date  : 16 April  2024
#REM Author : Mecca
#REM 
#REM Script Details:
#REM --------------
#REM  This script will:
#REM       + Select the computer by name
#REM       + then access the password file
#REM       + Create a password for the account
#REM 
#REM===========================================

$adminname = "DisabledAdmin"

$Encrypted = "Make this your self"

[Byte[]] $key = (1..16)

#Settings for the password
$PasswordSecured = ConvertTo-SecureString -String $Encrypted -Key $Key


#Set the password for the Disabled Admin account 
Set-LocalUser -Name $adminname -Password $PasswordSecured



#Set the password for the Disabled Admin account 
Set-LocalUser -Name $adminname -Password $PasswordSecured
