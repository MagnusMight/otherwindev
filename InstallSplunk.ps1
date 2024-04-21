#REM====================================================
#REM Installing Splunk or Updating it
#REM====================================================
#REM Created Date : 20 April 2024
#REM Update Date  : 20 April  2024
#REM Author : Chukwuemeka Evulukwu
#REM 
#REM Script Details:
#REM --------------
#REM  This script will:
#REM       + Check to see if Splunk is on the machine
#REM       + if so it stops the service and attempts
#REM       + to upgrade from whatever version its on
#REM       + or if its not on there it installs 
#REM====================================================



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

$mypath = $MyInvocation.MyCommand.Path
$usepath = Split-Path $mypath -Parent



if (Test-Path "C:\Program Files\SplunkUniversalForwarder") {
    # Folder exists - Do something here
        Write-host "Folder Exists! Possible Old Version Exist" -f Green
            Start-sleep -Seconds 5
        Write-host "Stopping Splunk" -f Green
        Start-Process -FilePath ".\splunk.exe" -WorkingDirectory "C:\Program Files\SplunkUniversalForwarder\bin" -ArgumentList "stop" -Wait
        Write-host "Installing Update" -f Green
        cmd /c "msiexec.exe /i $usepath\spf240415.msi AGREETOLICENSE=yes /quiet"

}
else {
    # Folder does not exist - Do something else here
    Write-host "Folder Doesn't Exists!. Installing " -f Green
    cmd /c "msiexec.exe /i $usepath\spf240415.msi AGREETOLICENSE=yes /quiet" 
}


