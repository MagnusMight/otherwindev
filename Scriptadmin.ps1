#Created By Raptor


#Settings for the auto logon process
$PasswordSecured = Get-Content $PassFile | ConvertTo-SecureString -Key $Key
$marshal = [System.Runtime.InteropServices.Marshal]
$bstr = $marshal::SecureStringToBSTR($PasswordSecured)
$pass = $marshal::PtrToStringAuto($bstr) 
