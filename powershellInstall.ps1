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




#Elevates previlege 
function Elevate-Privileges {
    param($Privilege)
    $Definition = @"
    using System;
    using System.Runtime.InteropServices;
    public class AdjPriv {
        [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
            internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall, ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr rele);
        [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
            internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr phtok);
        [DllImport("advapi32.dll", SetLastError = true)]
            internal static extern bool LookupPrivilegeValue(string host, string name, ref long pluid);
        [StructLayout(LayoutKind.Sequential, Pack = 1)]
            internal struct TokPriv1Luid {
                public int Count;
                public long Luid;
                public int Attr;
            }
        internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
        internal const int TOKEN_QUERY = 0x00000008;
        internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;
        public static bool EnablePrivilege(long processHandle, string privilege) {
            bool retVal;
            TokPriv1Luid tp;
            IntPtr hproc = new IntPtr(processHandle);
            IntPtr htok = IntPtr.Zero;
            retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
            tp.Count = 1;
            tp.Luid = 0;
            tp.Attr = SE_PRIVILEGE_ENABLED;
            retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
            retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
            return retVal;
        }
    }
"@
    $ProcessHandle = (Get-Process -id $pid).Handle
    $type = Add-Type $definition -PassThru
    $type[0]::EnablePrivilege($processHandle, $Privilege)
}

echo "Elevating priviledges for this process"
do {} until (Elevate-Privileges SeTakeOwnershipPrivilege)

#Arguments For Data Cap
$Arguments = "/S /V`"/passive ADDDEFAULT=LAP,Shared,Client`""

#Arguments for Update 1 
Arguments1 = "/S /V`"/passive`”" 18_4_2_DynamsoftServiceSetup.msi -/i /qn

#Arguments for Update 2
Arguments2 = /qn

#Install the first File
Write-Host "Installing DataCap..." -ForegroundColor Red
Start-Process -FilePath “.\IBM_Datacap_9.1.9\setup.exe” -ArgumentList $Arguments -Wait -NoNewWindow

# Check if DataCap has been installed on the machine to move to the update
if (Test-Path "C:\DataCap") {
    # Folder exists Install Update 1
    Write-host "Successful Install of DataCap. Attempting to Do Update 1...." -f Green
    Start-Process -FilePath “.\9.1.9.0-Datacap-WIN-IF004\Update.exe” -ArgumentList $Arguments1 -Wait -NoNewWindow

    Start-Sleep -Seconds 60

     Start-Process -FilePath “.\Datacap919iFix004_DynamsoftServiceUpdate\18_4_2_DynamsoftServiceSetup.msi” -ArgumentList $Arguments2 -Wait -NoNewWindow
}
else {
    # Folder does not exist - Do something else here
    Write-host "Folder Doesn't Exists! Failure" -f Red
}





