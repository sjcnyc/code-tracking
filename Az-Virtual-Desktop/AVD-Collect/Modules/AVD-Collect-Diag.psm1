<#
.SYNOPSIS
   Scenario module for collecting AVD Diagnostics data

.DESCRIPTION
   Runs Diagnostics checks and generates a report in .txt and .html formats.

.NOTES  
   Authors    : Robert Klemencz (Microsoft CSS) & Alexandru Olariu (Microsoft CSS)
   Requires   : At least PowerShell 5.1 (This module is not for stand-alone use. It is used automatically from within the main AVD-Collect.ps1 script)
   Version    : See AVD-Collect.ps1 version
   Feedback   : Send an e-mail to AVDCollectTalk@microsoft.com
#>

$latestFSLogixVer = 29811153415
$cleanupFSLogixVer = 29762130127
$latestWebRTCVer = 14211118001
$latestRDCver = 1231300
$minRDCver = 1216720
$latestStoreCver = 10218170
$minStoreCver = 10215340

$bodyDiag = '<style>
BODY { background-color:#E0E0E0; font-family: sans-serif; font-size: small; }
table { background-color: white; border:none; padding: 10px; margin-left:auto; margin-right:auto; }
td { padding-left: 10px; padding-right: 10px; word-break: break-all; }
</style>'

$LogPrefix = "Diag"
$fwrfile = $NetLogFolder + $LogFilePrefix + "FirewallRules.txt"

#region Diag functions

Function global:UEXAVD_DiagMsgIssues {
    Param([Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string]$IssueType, [Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string]$LogName, 
        [array]$LogID, [Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][array]$Message, [string]$lvl)

    if ($lvl -eq "Full") { $evlvl = @(1,2,3,4) } else { $evlvl = @(1,2,3) }

    $StartTimeA = (Get-Date).AddDays(-5)
    if ($LogID) { $geteventDiag = Get-WinEvent -FilterHashtable @{logname="$LogName"; id=$LogID; StartTime=$StartTimeA; Level=$evlvl} -ErrorAction SilentlyContinue } 
    else { $geteventDiag = Get-WinEvent -FilterHashtable @{logname="$LogName"; StartTime=$StartTimeA; Level=$evlvl} -ErrorAction SilentlyContinue }
    
    if ($IssueType -eq "Agent") { $issuefile = "AVD-Diag-AgentIssuesEvents.txt" }
    elseif ($IssueType -eq "MSIXAA") { $issuefile = "AVD-Diag-MSIXAAIssuesEvents.txt" }
    elseif ($IssueType -eq "FSLogix") { $issuefile = "AVD-Diag-FSLogixIssuesEvents.txt" }
    elseif ($IssueType -eq "Shortpath") { $issuefile = "AVD-Diag-ShortpathIssuesEvents.txt" }
    elseif ($IssueType -eq "Crash") { $issuefile = "AVD-Diag-CrashEvents.txt" }
    elseif ($IssueType -eq "ProcessHang") { $issuefile = "AVD-Diag-ProcessHangEvents.txt" }
    elseif ($IssueType -eq "BlackScreen") { $issuefile = "AVD-Diag-PotentialBlackScreenEvents.txt" }
    elseif ($IssueType -eq "TCP") { $issuefile = "AVD-Diag-TCPIssuesEvents.txt" }

    $pad = 13
    $counter = 0

    If ($geteventDiag) {
        if ($Message) {
            foreach ($eventItem in $geteventDiag) {
                foreach ($msg in $Message) {
                    if ($eventItem.Message -like "*$msg*") {
                        $counter = $counter + 1
                        "TimeCreated".PadRight($pad) + " : " + $eventItem.TimeCreated 2>&1 | Out-File -Append ($BasicLogFolder + $issuefile)
                        "EventLog".PadRight($pad) + " : " + $LogName 2>&1 | Out-File -Append ($BasicLogFolder + $issuefile)
                        "ProviderName".PadRight($pad) + " : " + $eventItem.ProviderName 2>&1 | Out-File -Append ($BasicLogFolder + $issuefile)
                        "Id".PadRight($pad) + " : " + $eventItem.Id 2>&1 | Out-File -Append ($BasicLogFolder + $issuefile)
                        "Level".PadRight($pad) + " : " + $eventItem.LevelDisplayName 2>&1 | Out-File -Append ($BasicLogFolder + $issuefile)
                        "Message".PadRight($pad) + " : " + $eventItem.Message 2>&1 | Out-File -Append ($BasicLogFolder + $issuefile)
                        "" 2>&1 | Out-File -Append ($BasicLogFolder + $issuefile)
                    }
                }
            }
        }
    }
    if ($counter -gt 0) { 
        UEXAVD_LogDiag $LogLevel.DiagFileOnly  "... [WARNING] One or more $IssueType related issues have been found in the '$LogName' event logs. See $issuefile for more information."
    } else {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly "... $IssueType related issues not found in the '$LogName' event logs"
    }
}

Function global:UEXAVD_DiagProvIssues {
    Param([Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string]$IssueType, [Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string]$LogName, 
        [array]$LogID, [Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][array]$Provider, [array]$lvl)
    
    if ($lvl -eq "Full") { $evlvl = @(1,2,3,4) } else { $evlvl = @(1,2,3) }

    $StartTimeA = (Get-Date).AddDays(-5)
    if ($LogID) { $geteventDiag = Get-WinEvent -FilterHashtable @{logname="$LogName"; id=$LogID; StartTime=$StartTimeA; Level=$evlvl} -ErrorAction SilentlyContinue } 
    else { $geteventDiag = Get-WinEvent -FilterHashtable @{logname="$LogName"; StartTime=$StartTimeA; Level=$evlvl} -ErrorAction SilentlyContinue }
    
    if ($IssueType -eq "Agent") { $issuefile = "AVD-Diag-AgentIssuesEvents.txt" }
    elseif ($IssueType -eq "MSIXAA") { $issuefile = "AVD-Diag-MSIXAAIssuesEvents.txt" }
    elseif ($IssueType -eq "FSLogix") { $issuefile = "AVD-Diag-FSLogixIssuesEvents.txt" }
    elseif ($IssueType -eq "Shortpath") { $issuefile = "AVD-Diag-ShortpathIssuesEvents.txt" }
    elseif ($IssueType -eq "Crash") { $issuefile = "AVD-Diag-CrashEvents.txt" }
    elseif ($IssueType -eq "ProcessHang") { $issuefile = "AVD-Diag-ProcessHangEvents.txt" }
    elseif ($IssueType -eq "BlackScreen") { $issuefile = "AVD-Diag-PotentialBlackScreenEvents.txt" }
    elseif ($IssueType -eq "TCP") { $issuefile = "AVD-Diag-TCPIssuesEvents.txt" }

    $pad = 13
    $counter = 0

    If ($geteventDiag) {
        if ($Provider) {
            foreach ($eventItem in $geteventDiag) {
                foreach ($prv in $Provider) {
                    if ($eventItem.ProviderName -eq $prv) {
                        $counter = $counter + 1
                        "TimeCreated".PadRight($pad) + " : " + $eventItem.TimeCreated 2>&1 | Out-File -Append ($BasicLogFolder + $issuefile)
                        "EventLog".PadRight($pad) + " : " + $LogName 2>&1 | Out-File -Append ($BasicLogFolder + $issuefile)
                        "ProviderName".PadRight($pad) + " : " + $eventItem.ProviderName 2>&1 | Out-File -Append ($BasicLogFolder + $issuefile)
                        "Id".PadRight($pad) + " : " + $eventItem.Id 2>&1 | Out-File -Append ($BasicLogFolder + $issuefile)
                        "Level".PadRight($pad) + " : " + $eventItem.LevelDisplayName 2>&1 | Out-File -Append ($BasicLogFolder + $issuefile)
                        "Message".PadRight($pad) + " : " + $eventItem.Message 2>&1 | Out-File -Append ($BasicLogFolder + $issuefile)
                        "" 2>&1 | Out-File -Append ($BasicLogFolder + $issuefile)
                    }
                }
            }
        }
    }
    if ($counter -gt 0) { 
        UEXAVD_LogDiag $LogLevel.DiagFileOnly  "... [WARNING] One or more $IssueType related issues have been found in the '$LogName' event logs. See $issuefile for more information."
    } else {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly "... $IssueType related issues not found in the '$LogName' event logs"
    }
}

Function UEXAVD_GetDiskSpace {

    $drives = @()
    $drvtype = "Unknown", "No Root Directory", "Removable Disk", "Local Disk", "Network Drive", "Compact Disc", "RAM Disk"
    $Vol = Get-CimInstance -NameSpace "root\cimv2" -Query "select * from Win32_LogicalDisk" -ErrorAction Continue 2>>$global:ErrorLogFile
    foreach ($disk in $vol) {
        if ($disk.Size -ne $null) { $PercentFreeSpace = $disk.FreeSpace*100/$disk.Size } 
        else { $PercentFreeSpace = 0 }
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Drive: " + $disk.DeviceID + " - Type: " + $drvtype[$disk.DriveType] + " - Total space (MB): " + [math]::Round($disk.Size/1MB,2) + " - Free space (MB): " + [math]::Round($disk.FreeSpace/1MB,2) + " - Percent free space: " + [math]::Round($PercentFreeSpace,2) + "%")

        #check and warn if free space is below 5% of disk size
        if (($PercentFreeSpace -lt 5) -and (($drvtype[$disk.DriveType] -eq "Local Disk") -or ($drvtype[$disk.DriveType] -eq "Network Drive"))) {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] You are running low on free space (less than 5%) on drive: " + $disk.DeviceID)
        }
    }
}


Function global:UEXAVD_CheckRegKeyValue {
    Param([Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string]$RegPath, [Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string]$RegKey, [string]$RegValue, [string]$OptNote)

    $global:regok = $null

    if (UEXAVD_TestRegistryValue -path $RegPath -value $RegKey) {
        (Get-ItemProperty -path $RegPath).PSChildName | foreach-object -process {
            $key = Get-ItemPropertyValue -Path $RegPath -name $RegKey
            if ($RegValue) {
                if ($key -eq $RegValue) {
                    $global:regok = 1
                    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... '$RegPath$RegKey' exists and has the expected value of: " + $key + " " + $OptNote)
                }
                else {
                    $global:regok = 2
                    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] '$RegPath$RegKey' exists and has a value of '" + $key + "' but this is not the expected value. (The expected value is: " + $RegValue + "). " + $OptNote)
                }
            } else {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... '$RegPath$RegKey' exists and has a value of: " + $key + " " + $OptNote)
            }
        }
    } else {
        $global:regok = 0
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... '$RegPath$RegKey' not found. " + $OptNote)
    }
}

Function UEXAVD_TestAVExclusion {
    Param([Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string]$ExclPath, [Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][array]$ExclValue)

    if (Test-Path $ExclPath) {
        if ((Get-Item $ExclPath).Property) {
            $msgpath = Compare-Object -ReferenceObject(@((Get-Item $ExclPath).Property)) -DifferenceObject(@($ExclValue))

            if ($msgpath) {
                $valueNotConf = ($msgpath | Where-Object {$_.SideIndicator -eq '=>'}).InputObject
                $valueNotRec = ($msgpath | Where-Object {$_.SideIndicator -eq '<='}).InputObject

                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] The following recommended values are not configured:"
                foreach ($entryNC in $valueNotConf) {
                    UEXAVD_LogDiag $LogLevel.DiagFileOnly "... ... $entryNC"
                }

                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] The following values are configured but are not part of the public list of recommended settings:"
                foreach ($entryNR in $valueNotRec) {
                    UEXAVD_LogDiag $LogLevel.DiagFileOnly "... ... $entryNR"
                }

            } else {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... No differences found."
            }

        } else {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] No '$ExclPath' exclusions have been found. Follow the above article to configure the recommended exclusions."
        }

    } else {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly "... '$ExclPath' not found."
    }
}

function UEXAVD_CheckSiteURLStatus {
    Param([Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string]$URIkey, [Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string]$URL)

    try {
        $request = Invoke-WebRequest $URL -UseBasicParsing

        if ($request.StatusCode -eq "200") { UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... $URIkey" + ": '$URL' is up (Return code: $($request.StatusDescription) - $($request.StatusCode))") }
        else { UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] $URIkey" + ": '$URL' is not accessible.") }

    } catch {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] $URIkey" + ": '$URL' is not accessible.")
    }
}

function UEXAVD_GetDispScale {

Add-Type @'
  using System;
  using System.Runtime.InteropServices;
  using System.Drawing;

  public class DPI {
    [DllImport("gdi32.dll")]
    static extern int GetDeviceCaps(IntPtr hdc, int nIndex);

    public enum DeviceCap { VERTRES = 10, DESKTOPVERTRES = 117 }

    public static float scaling() {
      Graphics g = Graphics.FromHwnd(IntPtr.Zero);
      IntPtr desktop = g.GetHdc();
      int LogicalScreenHeight = GetDeviceCaps(desktop, (int)DeviceCap.VERTRES);
      int PhysicalScreenHeight = GetDeviceCaps(desktop, (int)DeviceCap.DESKTOPVERTRES);
      return (float)PhysicalScreenHeight / (float)LogicalScreenHeight;
    }
  }
'@ -ReferencedAssemblies 'System.Drawing.dll'

    $DScale = [Math]::round([DPI]::scaling(), 2) * 100
    if ($DScale) { UEXAVD_LogDiag $LogLevel.DiagFileOnly "... Display scaling rate: $DScale%" } 
    else { UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] Display scaling rate could not be determined." }
}

Function UEXAVD_RequiredURLCheck {
    $toolpath = "C:\Program Files\Microsoft RDInfra\"

    If (!($ver -like "*Windows 7*")) {
        If (Test-Path $toolpath) {
            $toolfolder = Get-ChildItem $toolpath -Directory | Foreach-Object {If (($_.psiscontainer) -and ($_.fullname -like "*RDAgent_*")) { $_.Name }} | Select-Object -Last 1
            $URLCheckToolPath = $toolpath + $toolfolder + "\WVDAgentUrlTool.exe"

            if (Test-Path $URLCheckToolPath) {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... WVDAgentUrlTool found."
                Try{
                    $urlout = Invoke-Expression "& '$URLCheckToolPath'"
                    foreach ($urlline in $urlout) {
                        if (!($urlline -like "*===========*") -and !($urlline -like $null) -and ($urlline -ne "WVD")) {
                            if (($urlline -like "*Accessible URLs*") -or ($urlline -like "*Azure Instance*") -or ($urlline -like "*Virtual Machine*")) {
                                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... $urlline"
                            } else {
                                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... ... $urlline"
                            }
                        }
                    }
                } Catch {
                    UEXAVD_LogException ("Error: An exception occurred in UEXAVD_URLCheckTool.") -ErrObj $_ $fLogFileOnly
                    Continue
                }
            } else {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] $toolpath found, but 'WVDAgentUrlTool.exe' is missing, skipping check. You should be running agent version 1.0.2944.1200 or higher."
            }
        } else {
            UEXAVD_LogDiag $LogLevel.Warning "... AVD Agent not found. Skipping check (not applicable)."
        }
    } else {
        UEXAVD_LogDiag $LogLevel.Warning ("... Windows 7 detected. Skipping check (not applicable).")
    }
}

Function global:UEXAVD_GetDsregcmdInfo {
    Param([Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string]$dsregentry)

    foreach ($entry in $DsregCmdStatus) {
        if ($entry -match $dsregentry) { UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... " + $entry) }
    }
}

Function global:UEXAVD_GetDNSInfo {
    
    $dnsip = Get-DnsClientServerAddress -AddressFamily IPv4
    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Local network interface DNS configuration:")
    foreach ($entry in $dnsip) {
        if (!($entry.InterfaceAlias -like "Loopback*")) {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... ... " + $entry.InterfaceAlias + ": " + $entry.ServerAddresses)
        }
    }

    Try {
        $vmdomain = [System.Directoryservices.Activedirectory.Domain]::GetComputerDomain()
        $dcdns = $vmdomain | ForEach-Object {$_.DomainControllers} |
            ForEach-Object {
                $hostEntry= [System.Net.Dns]::GetHostByName($_.Name)
                New-Object -TypeName PSObject -Property @{
                        Name = $_.Name
                        IPAddress = $hostEntry.AddressList[0].IPAddressToString
                    }
                } | Select-Object Name, IPAddress

        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... DNS servers available in the domain '$($vmdomain.Name)':")
        foreach ($dcentry in $dcdns) { UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... ... " + $dcentry.Name + ": " + $dcentry.IPAddress) }

    } Catch {
        UEXAVD_LogException ("Error: An error occurred in $vmdomain") -ErrObj $_ $fLogFileOnly
        Continue
    }
}


Function global:UEXAVD_GetFirewallInfo {

    $FWService = Get-Service | ? { $_.Name -eq "mpssvc" }
    $FWService | % {
        If ($_.Status -eq "Running") {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... The mpssvc ($($_.DisplayName)) service is in $($_.Status) state")

            $FWProfiles = Get-NetFirewallProfile
            $FWProfiles | % {
                If ($_.Enabled -eq 1) {  UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... The Windows Firewall $($_.Name) profile is enabled") } 
                else { UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] The Windows Firewall $($_.Name) profile is disabled")}
            }
        } else {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] The $($_.DisplayName) service is in $($_.Status) state")
        }
    }

    Try {
        $3fw = Get-CimInstance -NameSpace "root\SecurityCenter2" -Query "select * from FirewallProduct" -ErrorAction Continue
        if ($3fw) {
            foreach ($3fwentry in $3fw) { UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Third party firewall found: " + $3fwentry.displayName) }
        } else {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Third party firewall(s) not found.")
        }
        
    } Catch {
        UEXAVD_LogException ("Error: An error occurred in $3fw") -ErrObj $_ $fLogFileOnly
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] An error occurred while trying to retrieve third party firewall information. See AVD-Collect-Error.txt for more information." )
        Continue
    }
}


Function global:UEXAVD_GetAntivirusInfo {
    
    Try {
        $AVprod = (Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct).displayName
        if ($AVprod) {
            foreach ($AVPentry in $AVprod) { UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Antivirus software found: " + $AVPentry) }
        } else {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Antivirus software not found.")
        }

    } Catch {
        UEXAVD_LogException ("Error: An error occurred in $AVprod") -ErrObj $_ $fLogFileOnly
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] An error occurred while trying to retrieve Antivirus information. See AVD-Collect-Error.txt for more information." )
        Continue
    }
}


Function global:UEXAVD_GetDCInfo {

    Try {
        $vmdomain = [System.Directoryservices.Activedirectory.Domain]::GetComputerDomain()
        $trusteddc = nltest /sc_query:$vmdomain
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... nltest /sc_query:")

        foreach ($entry in $trusteddc) {
            if (!($entry -like "The command completed*")) { UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... ... " + $entry) }
        }

        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... nltest /dnsgetdc:")
        $alldc = nltest /dnsgetdc:$vmdomain
        foreach ($dcentry in $alldc) {
            if (!($dcentry -like "The command completed*")) { UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... ... " + $dcentry) }
        }
    } Catch {
        UEXAVD_LogException ("Error: An error occurred in $vmdomain") -ErrObj $_ $fLogFileOnly
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] An error occurred while trying to retrieve DC information. See AVD-Collect-Error.txt for more information." )
        Continue
    }

}


Function UEXAVD_GetCPUusage {

    $Top10CPU = Get-Process | Sort-Object CPU -desc | Select-Object -first 10
    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... List of top 10 processes using CPU at the moment the script was running (ProcessName, Id, CPU, Handles, NPM, PM, WS):")
    foreach ($entry in $Top10CPU) {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... ... " + $entry.ProcessName + " | " + $entry.Id + " | " + $entry.CPU + " | " + $entry.Handles + " | " + $entry.NPM + " | " + $entry.PM + " | " + $entry.WS)
    }

}


Function UEXAVD_ProcessCheck {
    Param([Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string]$proc, [string]$intName)

    $check = Get-Process $proc -ErrorAction SilentlyContinue
    if ($check -eq $null) { 
        UEXAVD_LogDiag $LogLevel.DiagFileOnly "... $proc ($intName) not found"
    } else {
        $vendor = (Get-Process $proc | Group-Object -Property Company).Name
        if (($vendor -eq $null) -or ($vendor -eq "")) { $vendor = "N/A" }
        $counter = (Get-Process $proc | Group-Object -Property ProcessName).Count
        $desc = (Get-Process $proc | Group-Object -Property Description).Name
        $path = (Get-Process $proc | Group-Object -Property Path).Name
        $prodver = (Get-Process $proc | Group-Object -Property ProductVersion).Name
        if (($desc -eq $null) -or ($desc -eq "")) { $desc = "N/A" }
        if (($prodver -eq $null) -or ($prodver -eq "")) { $prodver = "N/A" }
        UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] $proc (version: $prodver) found running on this system in $counter instance(s). Company: $vendor - Description: $desc - Path: $path"
    }
}


Function Test-StunEndpoint {
    Param([Parameter(Mandatory)]$UdpClient, [Parameter(Mandatory)]$StunEndpoint)
  
    $ipendpoint = $null
    try {
        $UdpClient.client.ReceiveTimeout = 5000 
        $listenport = $UdpClient.client.localendpoint.port
        $endpoint = New-Object -TypeName System.Net.IPEndPoint -ArgumentList ([IPAddress]::Any, $listenport)
  
        [Byte[]] $payload = 
        0x00, 0x01, # Message Type: 0x0001 (Binding Request)
        0x00, 0x00, # Message Length: 0 bytes excluding header
        0x21, 0x12, 0xa4, 0x42 # Magic Cookie: Always 0x2112A442

        $LocalTransactionId = ([guid]::NewGuid()).ToByteArray()[1..12]
        $payload = $payload + $LocalTransactionId
    
        try {
            $null = $UdpClient.Send($payload, $payload.length, $StunEndpoint)
        } catch {
            throw "Unable to send data, check if $($StunEndpoint.AddressFamily) is configured"
        }
  
        try {
            $content = $UdpClient.Receive([ref]$endpoint)
        } catch {
            try {
                $null = $UdpClient.Send($payload, $payload.length, $StunEndpoint)
                $content = $UdpClient.Receive([ref]$endpoint)
            } catch {
                try {
                    $null = $UdpClient.Send($payload, $payload.length, $StunEndpoint)
                    $content = $UdpClient.Receive([ref]$endpoint)
                } catch {
                    throw "Unable to receive data, check if firewall allows access to $($StunEndpoint.ToString())"
                }
            }
        }
    
        if (-not $content) {
            throw  'Null response.'
        }
  
        [Byte[]]$messageType = $content[0..1]
        [Byte[]]$messageCookie = $content[4..7]
        [Byte[]]$TransactionId = $content[8..19]
        [Byte[]]$AttributeType = $content[20..21]
        [Byte[]]$AttributeLength = $content[22..23]

        if ([System.BitConverter]::IsLittleEndian) { [Array]::Reverse($AttributeLength) }

        if (-not ([BitConverter]::ToString($messageType)) -eq '01-01') { throw  "Invalid message type: $([BitConverter]::ToString($messageType))" }
        
        if (-not ([BitConverter]::ToString($messageCookie)) -eq '21-12-A4-42') { throw  "Invalid message cookie: $([BitConverter]::ToString($messageCookie))" }
  
        if (-not ([BitConverter]::ToString($TransactionId)) -eq [BitConverter]::ToString($LocalTransactionId) ) { throw  "Invalid message id: $([BitConverter]::ToString($TransactionId))" }
    
        if (-not ([BitConverter]::ToString($AttributeType)) -eq '00-20' ) { throw  "Invalid Attribute Type: $([BitConverter]::ToString($AttributeType))" }
    
        $ProtocolByte = $content[25]
        if (-not (($ProtocolByte -eq 1) -or ($ProtocolByte -eq 2))) { throw "Invalid Address Type: $([BitConverter]::ToString($ProtocolByte))" }

        $portArray = $content[26..27]
        if ([System.BitConverter]::IsLittleEndian) { [Array]::Reverse($portArray) }

        $port = [Bitconverter]::ToUInt16($portArray, 0) -bxor 0x2112
          
        if ($ProtocolByte -eq 1) {
            $IPbytes = $content[28..31]
      
            if ([System.BitConverter]::IsLittleEndian) { [Array]::Reverse($IPbytes) }
            $IPByte = [System.BitConverter]::GetBytes(([Bitconverter]::ToUInt32($IPbytes, 0) -bxor 0x2112a442))
        
            if ([System.BitConverter]::IsLittleEndian) { [Array]::Reverse($IPByte) }
            $IP = [ipaddress]::new($IPByte)
        
        } elseif ($ProtocolByte -eq 2) {
            $IPbytes = $content[28..44]
            [Byte[]]$magic = $content[4..19]
            
            for ($i = 0; $i -lt $IPbytes.Count; $i ++) {
                $IPbytes[$i] = $IPbytes[$i] -bxor $magic[$i]
            }
            $IP = [ipaddress]::new($IPbytes)
        }
        $ipendpoint = [IPEndpoint]::new($IP, $port)
    
    } catch {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] Failed to communicate $($StunEndpoint.ToString()) with error: $_" )
    }
  
    return $ipendpoint
}

function RDPShortPathStun {

    $UdpClient6 = [Net.Sockets.UdpClient]::new([Net.Sockets.AddressFamily]::InterNetworkV6)
    $UdpClient = [Net.Sockets.UdpClient]::new([Net.Sockets.AddressFamily]::InterNetwork)
  
    $ipendpoint1 = Test-StunEndpoint -UdpClient $UdpClient -StunEndpoint ([IPEndpoint]::new(([Net.Dns]::GetHostAddresses('worldaz.turn.teams.microsoft.com') | Where-Object -FilterScript {$_.AddressFamily -EQ 'InterNetwork'})[0].Address, 3478))
    $ipendpoint2 = Test-StunEndpoint -UdpClient $UdpClient -StunEndpoint ([IPEndpoint]::new([ipaddress]::Parse('13.107.17.41'), 3478))
    $ipendpoint3 = Test-StunEndpoint -UdpClient $UdpClient6 -StunEndpoint ([IPEndpoint]::new([ipaddress]::Parse('2a01:111:202f::155'), 3478))

    $localendpoint1 = $UdpClient.Client.LocalEndPoint
    $localEndpoint2 = $UdpClient6.Client.LocalEndPoint

    if ($null -ne $ipendpoint1) {
        if ($ipendpoint1.Port -eq $localendpoint1.Port) { UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Local NAT uses port preservation") }
        else { UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] Local NAT does not use port preservation, custom port range may not work with Shortpath") }
  
        if ($null -eq $ipendpoint2) {
            if ($ipendpoint1.Equals($ipendpoint2)) { UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Local NAT reuses SNAT ports") } 
            else { UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] Local NAT does not reuse SNAT ports, preventing Shortpath from connecting this endpoint") }
        }
    }

    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Local endpoints:")
    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... ... 1) $localendpoint1")
    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... ... 2) $localendpoint2")
    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Discovered external endpoints:")
    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... ... 1) $ipendpoint1")
    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... ... 2) $ipendpoint2")
    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... ... 3) $ipendpoint3")

    $UdpClient.Close()
    $UdpClient6.Close()

}


function Get-UserRights {

    [array]$localrights = $null

    function Get-SecurityPolicy {					

        # Fail script if we can't find SecEdit.exe
        $SecEdit = Join-Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::System)) "SecEdit.exe"
        if (-not (Test-Path $SecEdit)) {
            UEXAVD_LogException ("File not found - '$SecEdit'") -ErrObj $_ $fLogFileOnly
            return
        }
        # LookupPrivilegeDisplayName Win32 API doesn't resolve logon right display names, so use this hashtable
        $UserLogonRights = @{
"SeBatchLogonRight"				    = "Log on as a batch job"
"SeDenyBatchLogonRight"			    = "Deny log on as a batch job"
"SeDenyInteractiveLogonRight"	    = "Deny log on locally"
"SeDenyNetworkLogonRight"		    = "Deny access to this computer from the network"
"SeDenyRemoteInteractiveLogonRight" = "Deny log on through Remote Desktop Services"
"SeDenyServiceLogonRight"		    = "Deny log on as a service"
"SeInteractiveLogonRight"		    = "Allow log on locally"
"SeNetworkLogonRight"			    = "Access this computer from the network"
"SeRemoteInteractiveLogonRight"	    = "Allow log on through Remote Desktop Services"
"SeServiceLogonRight"			    = "Log on as a service"
}
					
        # Create type to invoke LookupPrivilegeDisplayName Win32 API
        $Win32APISignature = @'
[DllImport("advapi32.dll", SetLastError=true)]
public static extern bool LookupPrivilegeDisplayName(
string systemName,
string privilegeName,
System.Text.StringBuilder displayName,
ref uint cbDisplayName,
out uint languageId
);
'@

        $AdvApi32 = Add-Type advapi32 $Win32APISignature -Namespace LookupPrivilegeDisplayName -PassThru
					
        # Use LookupPrivilegeDisplayName Win32 API to get display name of privilege (except for user logon rights)

        function Get-PrivilegeDisplayName {
        param ([String]$name)

            $displayNameSB = New-Object System.Text.StringBuilder 1024
            $languageId = 0
            $ok = $AdvApi32::LookupPrivilegeDisplayName($null, $name, $displayNameSB, [Ref]$displayNameSB.Capacity, [Ref]$languageId)
            
            if ($ok) { $displayNameSB.ToString() } 
            else {
                # Doesn't lookup logon rights, so use hashtable for that
                if ($UserLogonRights[$name]) { $UserLogonRights[$name] } 
                else { $name }
            }
        }

        # Outputs list of hashtables as a PSObject
        function Out-Object {
        param ([System.Collections.Hashtable[]]$hashData)

            $order = @()
            $result = @{ }
            $hashData | ForEach-Object {
                $order += ($_.Keys -as [Array])[0]
                $result += $_
            }

            $out = New-Object PSObject -Property $result | Select-Object $order
            return $out
        }
					
        # Translates a SID in the form *S-1-5-... to its account name;
        function Get-AccountName {
        param ([String]$principal)

            try {
                $sid = New-Object System.Security.Principal.SecurityIdentifier($principal.Substring(1))
                $sid.Translate([Security.Principal.NTAccount])
            } catch { $principal }
        }
					
        $TemplateFilename = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName())
        $LogFilename = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName())
        $StdOut = & $SecEdit /export /cfg $TemplateFilename /areas USER_RIGHTS /log $LogFilename

        if ($LASTEXITCODE -eq 0) {
            $dtable = $null
            $dtable = New-Object System.Data.DataTable
            $dtable.Columns.Add("Privilege", "System.String") | Out-Null
            $dtable.Columns.Add("PrivilegeName", "System.String") | Out-Null
            $dtable.Columns.Add("Principal", "System.String") | Out-Null
            
            Select-String '^(Se\S+) = (\S+)' $TemplateFilename | Foreach-Object {
                $Privilege = $_.Matches[0].Groups[1].Value
                $Principals = $_.Matches[0].Groups[2].Value -split ','
                foreach ($Principal in $Principals) {						
                    $nRow = $dtable.NewRow()
                    $nRow.Privilege = $Privilege
                    $nRow.PrivilegeName = Get-PrivilegeDisplayName $Privilege
                    $nRow.Principal = Get-AccountName $Principal			
                    $dtable.Rows.Add($nRow)
                }
                return $dtable
            }
        } else {
            UEXAVD_LogException ("Error: An error occurred in $StdOut") -ErrObj $_ $fLogFileOnly
        }
        Remove-Item $TemplateFilename, $LogFilename -ErrorAction SilentlyContinue
    }

    $localrights += Get-SecurityPolicy
    $localrights = $localrights | Select-Object Privilege, PrivilegeName, Principal -Unique | Where-Object { ($_.Privilege -like "*NetworkLogonRight") -or ($_.Privilege -like "*RemoteInteractiveLogonRight")} 
    Foreach ($LR in $localrights) {
        if (!($LR -like "Privilege*")) {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... " + $LR.PrivilegeName + " (" + $LR.Privilege + "): " + $LR.Principal)
        }
    } 

}


#endregion Diag functions


Function RunUEX_AVDDiag {
    
    "`n" | Out-File -Append $OutputLogFile
    UEXAVD_LogMessage $LogLevel.Info "Running diagnostics - please wait ...`n`n" -Color "Cyan"

    "`nThis report is intended to help you get a better overview of this machine, identify known issues and ease overall troubleshooting. Depending on the issue you are investigating, some of the performed checks may not necessarily be relevant, or additional data collection and analysis may be required." | Out-File -Append $diagfile
    " " | Out-File -Append $diagfile


#region Deployment info
    " " | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running deployment check"
    " " | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... FQDN: " + $fqdn)

    if (!(get-ciminstance -Class Win32_ComputerSystem).PartOfDomain) { UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] This machine is not joined to a domain.") }

    [string]$WinVerBuild = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion' CurrentBuild).CurrentBuild
    [string]$WinVerRevision = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion' UBR).UBR
    [string]$WinVer7 = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion' CurrentVersion).CurrentVersion

    if (!($ver -like "*Windows 7*")) {
        [string]$WinVerMajor = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion' CurrentMajorVersionNumber).CurrentMajorVersionNumber
        [string]$WiNVerMinor = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion' CurrentMinorVersionNumber).CurrentMinorVersionNumber
            if ($WinVerMajor -like "*10*") {
                if (($WinVerBuild -like "*18363*") -or ($WinVerBuild -like "*18362*") -or ($WinVerBuild -like "*17134*") -or ($WinVerBuild -like "*19041*") -or ($WinVerBuild -like "*16299*") -or ($WinVerBuild -like "*15063*")) {
                    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] This OS version is no longer supported. Upgrade the OS to a supported version. See: https://docs.microsoft.com/en-us/lifecycle/products/windows-10-enterprise-and-education")
                }
            }
    }

    #Azure VM query
    Try {
        $AVDVMquery = Invoke-RestMethod -Headers @{"Metadata"="true"} -URI 'http://169.254.169.254/metadata/instance?api-version=2021-10-01' -Method Get -TimeoutSec 20

        $vmloc = $AVDVMquery.Compute.location
        $vmsize = $AVDVMquery.Compute.vmSize
        $vmlictype = $AVDVMquery.Compute.licenseType
        if ($AVDVMquery.Compute.sku -eq "") { $vmsku = "N/A" } else { $vmsku = $AVDVMquery.Compute.sku }

    } Catch {
        UEXAVD_LogException ("Error: An error occurred in $AVDVMquery") -ErrObj $_ $fLogFileOnly
        $vmsku = "N/A"
        $vmloc = "N/A"
        $vmsize = "N/A"
        $vmlictype = "N/A"
    }
    
    if (($ver -like "*Pro*") -or ($ver -like "*Enterprise N*") -or ($ver -like "*LTSB*") -or ($ver -like "*LTSC*") -or ($ver -like "*Enterprise KN*") -or ($ver -like "*Windows 8*")) {
        UEXAVD_LogDiag $LogLevel.Warning ("... [WARNING] OS: " + $ver + ". If this machine is intended to be an AVD host, then this OS is not supported. See the list of supported virtual machine OS images for AVD: https://docs.microsoft.com/en-us/azure/virtual-desktop/prerequisites#operating-systems-and-licenses")
    } else {
        if (!($ver -like "*Windows 7*")) {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... OS: $ver (Build: $WinVerMajor.$WiNVerMinor.$WinVerBuild.$WinVerRevision - SKU: $vmsku)")
        } else {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... OS: $ver (Build: $WinVer7.$WinVerBuild.$WinVerRevision - SKU: $vmsku)")
        }
    }

    #check number of vCPUs
    $vCPUs = (Get-CimInstance -Namespace "root\cimv2" -Query "select NumberOfLogicalProcessors from Win32_ComputerSystem" -ErrorAction SilentlyContinue).NumberOfLogicalProcessors

    if (($ver -like "*Virtual Desktops*") -or ($ver -like "*Server*")) {
        if (($vCPUs -lt 4) -or ($vCPUs -gt 24)) {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] Size: $vmsize (" + $vCPUs + " vCPUs). Recommended is to have between 4 and 24 vCPUs for multi-session VMs. See https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/virtual-machine-recs#recommended-vm-sizes-for-standard-or-larger-environments")
        } else {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Size: $vmsize (" + $vCPUs + " vCPUs)")
        }
    } else {
        if ($vCPUs -lt 4) {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] Size: $vmsize (" + $vCPUs + " vCPUs). Recommended is to have at least 4 vCPUs for single-session VMs. See https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/virtual-machine-recs#recommended-vm-sizes-for-standard-or-larger-environments")
        } else {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Size: $vmsize (" + $vCPUs + " vCPUs)")
        }
    }

    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Location: $vmloc")

    if ($vmlictype -ne "Windows_Client") {
        UEXAVD_LogDiag $LogLevel.Warning ("... [WARNING] License Type: $vmlictype. This machine is either not an AVD VM or it is not configured properly. See: https://docs.microsoft.com/en-us/azure/virtual-desktop/apply-windows-license")
    } else {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... License Type: $vmlictype")
    }    

    If (Test-Path 'HKLM:\SOFTWARE\Microsoft\RDMonitoringAgent') {
        if (UEXAVD_TestRegistryValue -path "HKLM:\SOFTWARE\Microsoft\RDMonitoringAgent" -value "SessionHostPool") {
            $global:hp = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\RDMonitoringAgent" -name "SessionHostPool"
        } else { $global:hp = $false }
        
        if (UEXAVD_TestRegistryValue -path "HKLM:\SOFTWARE\Microsoft\RDInfraAgent" -value "Geography") {
            $geo = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\RDInfraAgent" -name "Geography"    
        } else { $geo = "N/A" }
        
        if (UEXAVD_TestRegistryValue -path "HKLM:\SOFTWARE\Microsoft\RDMonitoringAgent" -value "Cluster") {
            $cluster = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\RDMonitoringAgent" -name "Cluster"    
        } else { $cluster = "N/A" }

        if ($global:hp) {
            if (UEXAVD_TestRegistryValue -path "HKLM:\SOFTWARE\Microsoft\RDMonitoringAgent" -value "Ring") {
                $ring = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\RDMonitoringAgent" -name "Ring"
            } else { $ring = "N/A" }

            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Host pool: $global:hp (Ring: $ring - Geography: $geo - cluster: $cluster)")
            if ($ring -eq "R0") {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] Host pool ring: $ring. This is a validation ring, intended for testing, not for production use!")
            }

        } else {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] 'RDMonitoringAgent' reg key found, but this machine is not part of an AVD host pool. It might have host pool registration issues.")
        }

        if (UEXAVD_TestRegistryValue -path "HKLM:\SOFTWARE\Microsoft\RDInfraAgent" -value "AzureResourceId") {
            $arid = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\RDInfraAgent" -name "AzureResourceId"
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Azure Resource Id: $arid")
        }

    } else {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] This machine is not part of an AVD host pool.")
    }

    #get timezone
    $tz = (Get-TimeZone).DisplayName
    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Timezone: $tz")

    #check last boot up time
    $lboott = (Get-CimInstance -ClassName win32_operatingsystem).lastbootuptime
    $lboottdif = [datetime]::Now - $lboott
    $sincereboot = " (" + $lboottdif.Days + "d " + $lboottdif.Hours + "h " + $lboottdif.Minutes + "m ago)"

    if ($lboottdif.TotalHours -ge 25) {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] Last boot up time: " + $lboott + $sincereboot + ". Rebooting once every day could help clean out stuck sessions and avoid potential profile load issues.")
    } else {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Last boot up time: " + $lboott + $sincereboot)
    }

    #check .Net Framework
    $dotnet = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release
    if ($dotnet -ge 528040) { $dotnetver = ".NET Framework 4.8 or later" }
    elseif (($dotnet -ge 461808) -and ($dotnet -lt 528040)) { $dotnetver = ".NET Framework 4.7.2 or later" }
    elseif (($dotnet -ge 461308) -and ($dotnet -lt 461808)) { $dotnetver = ".NET Framework 4.7.1 or later" }
    elseif (($dotnet -ge 460798) -and ($dotnet -lt 461308)) { $dotnetver = ".NET Framework 4.7 or later" }
    elseif (($dotnet -ge 394802) -and ($dotnet -lt 460798)) { $dotnetver = ".NET Framework 4.6.2 or later" }
    elseif (($dotnet -ge 394254) -and ($dotnet -lt 394802)) { $dotnetver = ".NET Framework 4.6.1 or later" }
    elseif (($dotnet -ge 393295) -and ($dotnet -lt 394254)) { $dotnetver = ".NET Framework 4.6 or later" }
    elseif (($dotnet -ge 379893) -and ($dotnet -lt 393295)) { $dotnetver = ".NET Framework 4.5.2 or later" }
    elseif (($dotnet -ge 378675) -and ($dotnet -lt 379893)) { $dotnetver = ".NET Framework 4.5.1 or later" }
    elseif (($dotnet -ge 378389) -and ($dotnet -lt 378675)) { $dotnetver = ".NET Framework 4.5 or later" }
    else { $dotnetver = "No .NET Framework 4.5 or later" }

    if ($dotnet -ge 378389) {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... $dotnetver version found")
    } else {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] $dotnetver version found. AVD requires .NET Framework version 4.7.2 or later for proper functionality")
    }

    #check RDSH role presence
    if ($ver -like "*Windows Server*") {
        "`n`n" | Out-File -Append $diagfile
        if (Get-WindowsFeature -Name RDS-RD-Server) {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... Remote Desktop Session Host role is installed on this VM."
        } else {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] VM is running a Windows Server OS but the Remote Desktop Session Host role is not installed. This role is required for AVD VMs running Windows Server OS."
        }
    }

    "`n`n" | Out-File -Append $diagfile
    #checking for useful reg keys
    $Commands = @(
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\Setup\' 'OOBEInProgress' '0'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\Setup\' 'SystemSetupInProgress' '0'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\Setup\' 'SetupPhase' '0'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True
    
    " " | Out-File -Append $diagfile
    $Commands = @(
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\' 'DisableLockWorkstation'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters\' 'AllowEncryptionOracle'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\' 'ScreenSaverGracePeriod'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System\' 'ProcessTSUserLogonAsync' '' '(Policy: Allow asynchronous user Group Policy processing when logging on through Remote Desktop Services)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\' 'LmCompatibilityLevel'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\' 'DeleteUserAppContainersOnLogoff' '1' 'You could run into performance/hang issues if this key is not configured. See https://support.microsoft.com/en-us/help/4490481'"
        "UEXAVD_CheckRegKeyValue 'HKU:\.DEFAULT\Software\Microsoft\Windows\CurrentVersion\Policies\System\' 'DisableRegistryTools'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True
    
#endregion Brief deployment info


#region Checking status of key system services
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running key system services status check"
    " " | Out-File -Append $diagfile

    if (!($ver -like "*Windows 7*")) {
        $servlist = "RdAgent", "RDAgentBootLoader", "TermService", "SessionEnv", "UmRdpService", "RDWebRTCSvc", "WinRM", "frxsvc", "frxdrv", "frxccds", "OneDrive Updater Service", "msiserver", "himds"
    } else {
        $servlist = "WVDAgent", "WVDAgentManager", "TermService", "SessionEnv", "UmRdpService", "WinRM", "frxsvc", "frxdrv", "frxccds", "OneDrive Updater Service", "msiserver"
    }

    $servlist | ForEach-Object -Process {

        $service = Get-Service -Name $_ -ErrorAction SilentlyContinue
        if ($service.Length -gt 0) {
            $servstatus = (Get-Service $_).Status
            $servdispname = (Get-Service $_).DisplayName
            $servstart = (Get-Service $_).StartType
            if ($servstart -eq "Disabled") {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] " + $_ + " (" + $servdispname + ") is in " + $servstatus + " state (StartType: " + $servstart + ").")
            } else {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... " + $_ + " (" + $servdispname + ") is in " + $servstatus + " state (StartType: " + $servstart + ").")
            }
        }
        else {
            if ($_ -eq "himds") {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] " + $_ + " not found. (Only relevant for Azure Stack HCI scenarios)")
            } elseif (($_ -eq "frxsvc") -or ($_ -eq "frxdrv") -or ($_ -eq "frxccds")) {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] " + $_ + " not found. (Only relevant for FSLogix scenarios)")
            } elseif ($_ -eq "RDWebRTCSvc") {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] " + $_ + " not found. (Only relevant for Teams Media Optimization scenarios)")
            } else {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] " + $_ + " not found.")
            }
        }
    }

#endregion Checking status of key system services


#region Checking Windows Update configuration
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running Windows Update configuration check"
    " " | Out-File -Append $diagfile

    if ($WinVerMajor -like "*10*") {
        If ($WinVerBuild -like "*14393*") { $PatchURL = "https://support.microsoft.com/en-us/help/4000825"
        } elseif ($WinVerBuild -like "*17763*") { $PatchURL = "https://support.microsoft.com/en-us/help/4464619"
        } elseif ($WinVerBuild -like "*18363*") { $PatchURL = "https://support.microsoft.com/en-us/help/4529964"
        } elseif ($WinVerBuild -like "*19042*") { $PatchURL = "https://support.microsoft.com/en-us/help/4581839"
        } elseif ($WinVerBuild -like "*19043*") { $PatchURL = "https://support.microsoft.com/en-us/help/5003498"
        } elseif ($WinVerBuild -like "*19044*") { $PatchURL = "https://support.microsoft.com/en-us/help/5008339"
        } elseif ($WinVerBuild -like "*20348*") { $PatchURL = "https://support.microsoft.com/en-us/help/5005454"
        } elseif ($WinVerBuild -like "*22000*") { $PatchURL = "https://support.microsoft.com/en-us/help/5006099" }

        $buildlist = "14393", "17763", "18363", "19042", "19043", "19044", "20348", "22000"
        $buildlist | ForEach-Object -Process {
            if ($WinVerBuild -like $_) {
                $PatchHistory = " - Check the Windows Update history (" + $PatchURL + ") if the latest OS update is installed. Use the last digits of the OS build number for an easy comparison."
            }
        }

        if (($WinVerBuild -like "*18363*") -or ($WinVerBuild -like "*18362*") -or ($WinVerBuild -like "*17134*") -or ($WinVerBuild -like "*19041*") -or ($WinVerBuild -like "*16299*") -or ($WinVerBuild -like "*15063*")) {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] This OS version is no longer supported. Upgrade the OS to a supported version. See: https://docs.microsoft.com/en-us/lifecycle/products/windows-10-enterprise-and-education")
        }
    }

    if (!($ver -like "*Windows 7*")) {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... OS Build: " + $WinVerMajor + "." + $WiNVerMinor + "." + $WinVerBuild + "." + $WinVerRevision + $PatchHistory)
    } else {
        $Win7PatchURL = "https://support.microsoft.com/en-us/help/4009469"
        $Win7PatchHistory = " - Check the Windows Update history (" + $Win7PatchURL + ") if the latest OS update is installed."
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... OS Build: " + $WinVer7 + "." + $WinVerBuild + "." + $WinVerRevision + $Win7PatchHistory)
    }

    $Commands = @(
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\' 'WUServer'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\' 'WUStatusServer'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\' 'NoAutoUpdate'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\' 'AUOptions'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\' 'UseWUServer'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True

#endregion Checking Windows Update configuration


#region Checking for graphics configuration (if not Windows 7 or Server 2012 R2)
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running graphics configuration check"
    " " | Out-File -Append $diagfile
    if ((!($ver -like "*Windows 7*")) -or (!($ver -like "*Windows Server 2012 R2*"))) {

        if (($AVDVMquery.Compute.vmSize -like "*NV*") -or ($AVDVMquery.Compute.vmSize -like "*NC*")) {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... A GPU optimized VM size has been detected. Make sure all the prerequisites are met to take full advantage of the GPU capabilities. See https://docs.microsoft.com/en-us/azure/virtual-desktop/configure-vm-gpu"

            $Commands = @(
                "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'bEnumerateHWBeforeSW' '1' '(Policy: Use hardware graphics adapters for all Remote Desktop Services sessions)'"
                "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'AVCHardwareEncodePreferred' '1' '(Policy: Configure H.264/AVC hardware encoding for Remote Desktop Connections)'"
                "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'AVC444ModePreferred' '1' '(Policy: Prioritize H.264/AVC 444 graphics mode for Remote Desktop Connections)'"
            )
            UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True

        } else {
            UEXAVD_LogDiag $LogLevel.Warning ("... This machine is not a GPU enabled Azure VM.")
        }
    } else {
        UEXAVD_LogDiag $LogLevel.Warning ("... GPU-accelerated rendering and encoding are not supported for this OS version.")
    }

    UEXAVD_LogDiag $LogLevel.DiagFileOnly "... Available Video Controllers:"
    $commandline = "wmic path win32_VideoController get name,driverversion"
    $out = Invoke-Expression -Command $commandline
    foreach ($outopt in $out) {
        if (!($outopt -like $null)) {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... ... $outopt"
        }
    }

    #Get display scale
    UEXAVD_GetDispScale

    "`n`n" | Out-File -Append $diagfile
    $Commands = @(
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'fEnableWddmDriver' '' '(Policy: Use WDDM graphics display driver for Remote Desktop Connections)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'fEnableRemoteFXAdvancedRemoteApp' '' '(Policy: Use advanced RemoteFX graphics for RemoteApp)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'MaxMonitors' '' '(Policy: Limit number of monitors)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'MaxXResolution' '' '(Policy: Limit maximum display resolution)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'MaxYResolution' '' '(Policy: Limit maximum display resolution)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\' 'DWMFRAMEINTERVAL'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\' 'IgnoreClientDesktopScaleFactor'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' 'MaxMonitors'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' 'MaxXResolution'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' 'MaxYResolution'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\rdp-sxs\' 'MaxMonitors'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\rdp-sxs\' 'MaxXResolution'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\rdp-sxs\' 'MaxYResolution'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True
    
    " " | Out-File -Append $diagfile
    $Commands = @(
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\SideBySide\' 'PreferExternalManifest'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Display\' 'DisableGdiDPIScaling' '' '(Policy: Turn off GdiDPIScaling for applications)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\Control Panel\Desktop\' 'DesktopDPIOverride'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\Control Panel\Desktop\' 'LogPixels'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\Control Panel\Desktop\' 'Win8DpiScaling'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True

#endregion Checking for graphics configuration


#region Checking for CPU usage
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running CPU utilization check"
    " " | Out-File -Append $diagfile
    UEXAVD_GetCPUusage

#endregion Checking for CPU usage


#region Checking Disk space
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running Disk space check"
    " " | Out-File -Append $diagfile
    UEXAVD_GetDiskSpace

#endregion Checking Disk space


#region Checking SSL/TLS configuration
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running SSL and TLS configuration check"
    " " | Out-File -Append $diagfile

    if (Test-Path 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002') {
        if (UEXAVD_TestRegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002' -Value 'Functions') {
            $rdpkeyvalue1 = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002' -name "Functions"
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002\Functions' exists and has a value of: " + $rdpkeyvalue1)
            #UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] Make sure the configured SSL cipher suites contain also those required by Azure Front Door: https://docs.microsoft.com/en-us/azure/frontdoor/front-door-faq#what-are-the-current-cipher-suites-supported-by-azure-front-door"
        }
        else {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002\Functions' not found."
        }

        if (UEXAVD_TestRegistryValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002' -Value 'EccCurves') {
            $rdpkeyvalue2 = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002' -name "EccCurves"
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002\EccCurves' exists and has a value of: " + $rdpkeyvalue2)
        }
        else {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002\EccCurves' not found."
        }

    } else {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly "... 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002' not found."
    }

    " " | Out-File -Append $diagfile
    $Commands = @(
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client\' 'Enabled' '0'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server\' 'Enabled' '0'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client\' 'Enabled' '0'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client\' 'DisabledByDefault'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server\' 'Enabled' '0'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server\' 'DisabledByDefault'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client\' 'Enabled'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client\' 'DisabledByDefault'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server\' 'Enabled'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server\' 'DisabledByDefault'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client\' 'Enabled'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client\' 'DisabledByDefault'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server\' 'Enabled'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server\' 'DisabledByDefault'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Client\' 'Enabled'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Client\' 'DisabledByDefault'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server\' 'Enabled'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server\' 'DisabledByDefault'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True

#endregion Checking SSL/TLS configuration


#region Checking PowerShell configuration
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running PowerShell configuration check"
    " " | Out-File -Append $diagfile

    $PSlock = $ExecutionContext.SessionState.LanguageMode
    if ($PSlock -eq "ConstrainedLanguage") {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] PowerShell is configured to run in $PSlock mode.")
    } else {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... PowerShell is configured to run in $PSlock mode.")
    }

    $pssexec = Get-ExecutionPolicy -List
    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Execution policies:")
        foreach ($entrypss in $pssexec) {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... ... " + $entrypss.Scope + ": " + $entrypss.ExecutionPolicy)
        }

#endregion Checking PowerShell configuration


#region Checking WinRM configuration
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running WinRM configuration check"
    " " | Out-File -Append $diagfile

    $winrmsvcstatus = (get-service -name WinRM).status
    if ($winrmsvcstatus -eq "Running") {
            $ipfilter = Get-Item WSMan:\localhost\Service\IPv4Filter
            if ($ipfilter.Value) {
                if ($ipfilter.Value -eq "*") {
                    UEXAVD_LogDiag $LogLevel.DiagFileOnly "... IPv4Filter = *"
                } else {
                    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] IPv4Filter = " + $ipfilter.Value)
                }
            } else {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] IPv4Filter is empty, WinRM will not listen on IPv4.")
            }

            $ipfilter = Get-Item WSMan:\localhost\Service\IPv6Filter
            if ($ipfilter.Value) {
                if ($ipfilter.Value -eq "*") {
                    UEXAVD_LogDiag $LogLevel.DiagFileOnly "... IPv6Filter = *"
                } else {
                    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] IPv6Filter = " + $ipfilter.Value)
                }
            } else {
                    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] IPv6Filter is empty, WinRM will not listen on IPv6.")
            }
        } else {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] The WinRM service is in '$winrmsvcstatus' state.")
        }
    
    if (!($ver -like "*Windows 7*")) {
        $fwrules5 = (Get-NetFirewallPortFilter -Protocol TCP | Where-Object { $_.localport -eq '5985' } | Get-NetFirewallRule)
        if ($fwrules5.count -eq 0) {
          UEXAVD_LogDiag $LogLevel.DiagFileOnly "... No firewall rule for port 5985."
        } else {
          UEXAVD_LogDiag $LogLevel.DiagFileOnly "... Found firewall rule for port 5985. See 'FirewallRules.txt' for more information (not available in 'DiagOnly' mode)."
        }


        $fwrules6 = (Get-NetFirewallPortFilter -Protocol TCP | Where-Object { $_.localport -eq '5986' } | Get-NetFirewallRule)
        if ($fwrules6.count -eq 0) {
          UEXAVD_LogDiag $LogLevel.DiagFileOnly "... No firewall rule for port 5986."
        } else {
          UEXAVD_LogDiag $LogLevel.DiagFileOnly "... Found firewall rule for port 5986. See 'FirewallRules.txt' for more information (not available in 'DiagOnly' mode)."
        }
    } else {
        UEXAVD_LogDiag $LogLevel.Warning "... Windows 7 detected. Skipping firewall port check. (not implemented yet)"
    }

#endregion Checking WinRM configuration

#region Checking the WinRMRemoteWMIUsers__ group"
    if ((get-ciminstance -Class Win32_ComputerSystem).PartOfDomain) {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly "... Checking the WinRMRemoteWMIUsers__ group"
        $search = New-Object DirectoryServices.DirectorySearcher([ADSI]"")  # This is a Domain local group, therefore we need to collect to a non-global catalog
        $search.filter = "(samaccountname=WinRMRemoteWMIUsers__)"
        try {
            $results = $search.Findall()
        } catch {
            $_ | Out-File -Append -FilePath $global:ErrorLogFile
        }

        if ($results.count -gt 0) {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Found " + $results.Properties.distinguishedname)
            if ($results.Properties.grouptype -eq  -2147483644) {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... WinRMRemoteWMIUsers__ is a Domain local group."
            } elseif ($results.Properties.grouptype -eq -2147483646) {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] WinRMRemoteWMIUsers__ is a Global group."
            } elseif ($results.Properties.grouptype -eq -2147483640) {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] WinRMRemoteWMIUsers__ is a Universal group."
            }
            if (get-ciminstance -query "select * from Win32_Group where Name = 'WinRMRemoteWMIUsers__' and Domain = '$env:computername'") {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... The group WinRMRemoteWMIUsers__ is also present as machine local group."
            }
        } else {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... The WinRMRemoteWMIUsers__ was not found in the domain."
            if (get-ciminstance -query "select * from Win32_Group where Name = 'WinRMRemoteWMIUsers__' and Domain = '$env:computername'") {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... The group WinRMRemoteWMIUsers__ is present as machine local group."
            } else {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... WinRMRemoteWMIUsers__ group not found as machine local group."
            }
        }
    } else {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] The machine is not joined to a domain."
        if (get-ciminstance -query "select * from Win32_Group where Name = 'WinRMRemoteWMIUsers__' and Domain = '$env:computername'") {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... The group WinRMRemoteWMIUsers__ is present as machine local group."
        } else {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... WinRMRemoteWMIUsers__ group not found as machine local group."
        }
    }

#endregion Checking the WinRMRemoteWMIUsers__ group"


#region Checking UAC configuration
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running User Account Control configuration check"
    " " | Out-File -Append $diagfile

    $Commands = @(
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\' 'EnableLUA' '' '(Policy: User Account Control: Run all administrators in Admin Approval Mode)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\' 'PromptOnSecureDesktop' '' '(Policy: User Account Control: Switch to the secure desktop when prompting for elevation)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\' 'ConsentPromptBehaviorAdmin' '' '(Policy: User Account Control: Behavior of the elevation prompt for administrators in Admin Approval Mode)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\' 'ConsentPromptBehaviorUser' '' '(Policy: User Account Control: Behavior of the elevation prompt for standard users)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\' 'EnableUIADesktopToggle' '' '(Policy: User Account Control: Allow UIAccess applications to prompt for elevation without using the secure desktop)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\' 'EnableInstallerDetection' '' '(Policy: User Account Control: Detect application installations and prompt for elevation)'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True

#endregion Checking UAC configuration


#region Checking AVD Agent and Stack information
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running AVD Agent and SxS Stack information check"
    " " | Out-File -Append $diagfile

    if (!($ver -like "*Windows 7*")) {
        if (Test-Path 'HKLM:\SOFTWARE\Microsoft\RDAgentBootLoader') {
            if (UEXAVD_TestRegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\RDAgentBootLoader\' -Value 'DefaultAgent') {

                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... AVD Agent:")

                $AVDagent = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\RDAgentBootLoader\' -name "DefaultAgent"
                $AVDagentver = $AVDagent.split("_")[1]
                $AVDagentdate = (Get-ItemProperty  hklm:\software\microsoft\windows\currentversion\uninstall\* | Where-Object {($_.DisplayName -eq "Remote Desktop Services Infrastructure Agent" -and $_.DisplayVersion -eq $AVDagentver)}).InstallDate
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... ... Current version: " + $AVDagentver + " (Installed on: " + $AVDagentdate + ")")

                if (UEXAVD_TestRegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\RDAgentBootLoader\' -Value 'PreviousAgent') {
                    $AVDagentpre = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\RDAgentBootLoader\' -name "PreviousAgent"
                    $AVDagentverpre = $AVDagentpre.split("_")[1]
                    $AVDagentdatepre = (Get-ItemProperty  hklm:\software\microsoft\windows\currentversion\uninstall\* | Where-Object {($_.DisplayName -eq "Remote Desktop Services Infrastructure Agent" -and $_.DisplayVersion -eq $AVDagentverpre)}).InstallDate
                } else {
                    $AVDagentverpre = "N/A"
                    $AVDagentdatepre = "N/A"
                }
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... ... Previous version: " + $AVDagentverpre + " (Installed on: " + $AVDagentdatepre + ")")

            } else {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... 'HKLM:\SOFTWARE\Microsoft\RDAgentBootLoader\DefaultAgent' not found. This machine is either not part of an AVD host pool or it is not configured properly.")
            }

        } else {
            UEXAVD_LogDiag $LogLevel.Warning ("... [WARNING] RDAgentBootLoader configuration not found. This machine is either not part of an AVD host pool or it is not configured properly.")
            if ($global:hp) {
                UEXAVD_LogDiag $LogLevel.Warning ("... [WARNING] VM is part of host pool '$global:hp' but the HKLM:\SOFTWARE\Microsoft\RDAgentBootLoader registry key could not be found. You may have issues accessing this VM through AVD.")
            }
        }
    } else {
        if (Test-Path 'HKLM:\SOFTWARE\Microsoft\WVDAgentManager') {
            if (UEXAVD_TestRegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\WVDAgentManager\' -Value 'CurrentAgentVersion') {

                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... AVD Agent:")

                $Win7AVDagent = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\WVDAgentManager\' -name "CurrentAgentVersion"
                $Win7AVDagentver = $Win7AVDagent.split("_")[1]
                $Win7AVDagentdate = (Get-ItemProperty  hklm:\software\microsoft\windows\currentversion\uninstall\* | Where-Object {($_.DisplayName -eq "Windows Virtual Desktop Agent" -and $_.DisplayVersion -eq $Win7AVDagentver)}).InstallDate
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... ... Current version: " + $Win7AVDagentver + " (Installed on: " + $Win7AVDagentdate + ")")

                if (UEXAVD_TestRegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\WVDAgentManager\' -Value 'PreviousAgentVersion') {
                    $Win7AVDagentpre = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\WVDAgentManager\' -name "PreviousAgentVersion"
                    $Win7AVDagentverpre = $Win7AVDagentpre.split("_")[1]
                    $Win7AVDagentdatepre = (Get-ItemProperty  hklm:\software\microsoft\windows\currentversion\uninstall\* | Where-Object {($_.DisplayName -eq "Windows Virtual Desktop Agent" -and $_.DisplayVersion -eq $Win7AVDagentverpre)}).InstallDate
                } else {
                    $Win7AVDagentverpre = "N/A"
                    $Win7AVDagentdatepre = "N/A"
                }
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... ... Previous version: " + $Win7AVDagentverpre + " (Installed on: " + $Win7AVDagentdatepre + ")")

            } else {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... 'HKLM:\SOFTWARE\Microsoft\WVDAgentManager\CurrentAgentVersion' not found. This machine is either not part of an AVD host pool or it is not configured properly.")
            }

        } else {
            UEXAVD_LogDiag $LogLevel.Warning ("... [WARNING] WVDAgentManager configuration not found. This machine is either not part of an AVD host pool or it is not configured properly.")
            if ($global:hp) {
                UEXAVD_LogDiag $LogLevel.Warning ("... [WARNING] VM is part of host pool '$global:hp' but the HKLM:\SOFTWARE\Microsoft\WVDAgentManager registry key could not be found. You may have issues accessing this VM through AVD.")
            }
        }
    }

    if (Test-Path 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent') {

        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... SxS Stack:")

        if (UEXAVD_TestRegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent\SxsStack\' -Value 'CurrentVersion') {
            $sxsstack = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent\SxsStack' -name "CurrentVersion"
            $sxsstackpath = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent\SxsStack' -name $sxsstack
            $sxsstackver = $sxsstackpath.split("-")[1].trimend(".msi")
            $sxsstackdate = (Get-ItemProperty  hklm:\software\microsoft\windows\currentversion\uninstall\* | Where-Object {($_.DisplayName -eq "Remote Desktop Services SxS Network Stack" -and $_.DisplayVersion -eq $sxsstackver)}).InstallDate
        } else {
            $sxsstackver = "N/A"
            $sxsstackdate = "N/A"
        }
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... ... Current version: " + $sxsstackver + " (Installed on: " + $sxsstackdate + ")")

        if ($sxsstackver -eq "N/A") {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... ... [WARNING] The current SxS Stack version could not be detected. Check if the SxS Stack was installed and works properly.")
        }

        if (UEXAVD_TestRegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent\SxsStack\' -Value 'PreviousVersion') {
            $sxsstackpre = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent\SxsStack' -name "PreviousVersion"
            if (($sxsstackpre) -and ($sxsstackpre -ne "")) {
                $sxsstackpathpre = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent\SxsStack' -name $sxsstackpre
                $sxsstackverpre = $sxsstackpathpre.split("-")[1].trimend(".msi")
                $sxsstackdatepre = (Get-ItemProperty  hklm:\software\microsoft\windows\currentversion\uninstall\* | Where-Object {($_.DisplayName -eq "Remote Desktop Services SxS Network Stack" -and $_.DisplayVersion -eq $sxsstackverpre)}).InstallDate
            } else {
                $sxsstackverpre = "N/A"
                $sxsstackdatepre = "N/A"
            }
        } else {
            $sxsstackverpre = "N/A"
            $sxsstackdatepre = "N/A"
        }
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... ... Previous version: " + $sxsstackverpre + " (Installed on: " + $sxsstackdatepre + ")")

        "`n`n" | Out-File -Append $diagfile
        $Commands = @(
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent\' 'IsRegistered' '1'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True

        if (UEXAVD_TestRegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent\' -Value 'RegistrationToken') {
            $regtoken = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent' -name "RegistrationToken"
            if ($regtoken -eq "") {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent\RegistrationToken' exists and has the expected empty value")
            } else {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent\RegistrationToken' exists but it is not empty. You may have issues with this VM being registered in the host pool. See: https://docs.microsoft.com/en-us/azure/virtual-desktop/troubleshoot-agent#error-invalid_registration_token")
            }
        } else {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent\RegistrationToken' not found. This machine is either not part of an AVD host pool or it is not configured properly.")
        }
    } else {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] RDInfraAgent configuration not found. This machine is either not part of an AVD host pool or it is not configured properly.")
    }

#endregion Checking AVD Agent and Stack information


#region Checking BrokerURI, BrokerURIGlobal, BrokerResourceIdURIGlobal, DiagnosticsUri /api/health availability
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running AVD services URI health status check"
    " " | Out-File -Append $diagfile

    $brokerURIregpath = "HKLM:\SOFTWARE\Microsoft\RDInfraAgent\"

    if (Test-Path $brokerURIregpath) {
        $brokerURIregkey = "BrokerURI"
            if (UEXAVD_TestRegistryValue -path $brokerURIregpath -value $brokerURIregkey) {
                $brokerURI = Get-ItemPropertyValue -Path $brokerURIregpath -name $brokerURIregkey
                $brokerURI = $brokerURI + "api/health"
                UEXAVD_CheckSiteURLStatus $brokerURIregkey $brokerURI
            } else {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... '$brokerURIregpath$brokerURIregkey' not found. This machine doesn't seem to be a AVD VM or it is not configured properly."
            }

        $brokerURIGlobalregkey = "BrokerURIGlobal"
            if (UEXAVD_TestRegistryValue -path $brokerURIregpath -value $brokerURIGlobalregkey) {
                $brokerURIGlobal = Get-ItemPropertyValue -Path $brokerURIregpath -name $brokerURIGlobalregkey
                $brokerURIGlobal = $brokerURIGlobal + "api/health"
                UEXAVD_CheckSiteURLStatus $brokerURIGlobalregkey $brokerURIGlobal
            } else {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... '$brokerURIregpath$brokerURIGlobalregkey' not found. This machine doesn't seem to be a AVD VM or it is not configured properly."
            }

        $diagURIregkey = "DiagnosticsUri"
            if (UEXAVD_TestRegistryValue -path $brokerURIregpath -value $diagURIregkey) {
                $diagURI = Get-ItemPropertyValue -Path $brokerURIregpath -name $diagURIregkey
                $diagURI = $diagURI + "api/health"
                UEXAVD_CheckSiteURLStatus $diagURIregkey $diagURI
            } else {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... '$brokerURIregpath$diagURIregkey' not found. This machine doesn't seem to be a AVD VM or it is not configured properly."
            }

        $BrokerResourceIdURIGlobalregkey = "BrokerResourceIdURIGlobal"
            if (UEXAVD_TestRegistryValue -path $brokerURIregpath -value $diagURIregkey) {
                $BrokerResourceIdURIGlobal = Get-ItemPropertyValue -Path $brokerURIregpath -name $BrokerResourceIdURIGlobalregkey
                $BrokerResourceIdURIGlobal = $BrokerResourceIdURIGlobal + "api/health"
                UEXAVD_CheckSiteURLStatus $BrokerResourceIdURIGlobalregkey $BrokerResourceIdURIGlobal
            } else {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... '$brokerURIregpath$BrokerResourceIdURIGlobalregkey' not found. This machine doesn't seem to be a AVD VM or it is not configured properly."
            }
    } else {
        UEXAVD_LogDiag $LogLevel.Warning ("... AVD Agent not found. Skipping check (not applicable).")
    }

#endregion Checking BrokerURI, BrokerURIGlobal, DiagnosticsUri /api/health availability


#region Checking AVD host VM access to the required URLs
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running AVD host required URLs access check"
    " " | Out-File -Append $diagfile
    UEXAVD_RequiredURLCheck

#endregion Checking AVD host VM access to the required URLs


#region Checking public IP information
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running public IP information check"
    " " | Out-File -Append $diagfile

    try {
        $WSProxy = New-object System.Net.WebProxy
        $WSWebSession = new-object Microsoft.PowerShell.Commands.WebRequestSession
        $WSWebSession.Proxy = $WSProxy
        $WSWebSession.Credentials = [System.Net.CredentialCache]::DefaultCredentials
        $pubip = Invoke-RestMethod -Uri "https://ipinfo.io/json" -Method Get -WebSession $WSWebSession -TimeoutSec 20

        if ($pubip) {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... IP: $($pubip.ip)"
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... City/Region: $($pubip.city)/$($pubip.region)"
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... Country: $($pubip.country)"
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... Organization: $($pubip.org)"
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... Timezone: $($pubip.timezone)"
        } else {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] Public IP information could not be retrieved."
        }

    } Catch {
        UEXAVD_LogException ("Error: An error occurred in $pubip") -ErrObj $_ $fLogFileOnly
        UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] Public IP information could not be retrieved. See AVD-Collect-Error.txt for more information."
    }

#endregion Checking public IP information


#region Checking for proxy and route settings
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running proxy and route configuration check"
    " " | Out-File -Append $diagfile
    $binval = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" -Name WinHttpSettings).WinHttPSettings
    $proxylength = $binval[12]
    if ($proxylength -gt 0) {
        $proxy = -join ($binval[(12+3+1)..(12+3+1+$proxylength-1)] | ForEach-Object {([char]$_)})
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] A NETSH WINHTTP proxy is configured: " + $proxy)
        $bypasslength = $binval[(12+3+1+$proxylength)]

        if ($bypasslength -gt 0) {
            $bypasslist = -join ($binval[(12+3+1+$proxylength+3+1)..(12+3+1+$proxylength+3+1+$bypasslength)] | ForEach-Object {([char]$_)})
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] Bypass list: " + $bypasslist)
        } else {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] No bypass list is configured."
        }
    } else {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly "... NETSH WINHTTP proxy configuration not found."
    }

    UEXAVD_LogDiag $LogLevel.DiagFileOnly "... Device-wide IE proxy configuration (LOCALSYSTEM)"
    $commandline = "bitsadmin /util /getieproxy LOCALSYSTEM"
    $out = Invoke-Expression -Command $commandline
    foreach ($outopt in $out) {
        if (($outopt -like "*Proxy usage:*") -or ($outopt -like "*Auto discovery script URL:*") -or ($outopt -like "*Proxy list:*") -or ($outopt -like "*Proxy bypass:*")) {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... ... $outopt"
        }
    }

    UEXAVD_LogDiag $LogLevel.DiagFileOnly "... Device-wide IE proxy configuration (NETWORKSERVICE)"
    $commandline = "bitsadmin /util /getieproxy NETWORKSERVICE"
    $out = Invoke-Expression -Command $commandline
    foreach ($outopt in $out) {
        if (($outopt -like "*Proxy usage:*") -or ($outopt -like "*Auto discovery script URL:*") -or ($outopt -like "*Proxy list:*") -or ($outopt -like "*Proxy bypass:*")) {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... ... $outopt"
        }
    }

    UEXAVD_LogDiag $LogLevel.DiagFileOnly "... Device-wide IE proxy configuration (LOCALSERVICE)"
    $commandline = "bitsadmin /util /getieproxy LOCALSERVICE"
    $out = Invoke-Expression -Command $commandline
    foreach ($outopt in $out) {
        if (($outopt -like "*Proxy usage:*") -or ($outopt -like "*Auto discovery script URL:*") -or ($outopt -like "*Proxy list:*") -or ($outopt -like "*Proxy bypass:*")) {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... ... $outopt"
        }
    }

    $Commands = @(
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections\' 'WinHttpSettings'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True

    "`n`n" | Out-File -Append $diagfile
    $Commands = @(
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\' 'ProxyEnable' '' '(machine config)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\' 'ProxyServer' '' '(machine config)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\' 'ProxyOverride' '' '(machine config)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\' 'AutoConfigURL' '' '(machine config)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\' 'ProxyEnable' '' '(user config)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\' 'ProxyServer' '' '(user config)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\' 'ProxyOverride' '' '(user config)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\' 'AutoConfigURL' '' '(user config)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections\' 'DefaultConnectionSettings'"
        "UEXAVD_CheckRegKeyValue 'HKU:\.DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\' 'ProxyEnable'"
        "UEXAVD_CheckRegKeyValue 'HKU:\.DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections\' 'DefaultConnectionSettings'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True

    "`n`n" | Out-File -Append $diagfile
    $Commands = @(
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Edge\' 'ProxySettings' '' '(machine config)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\SOFTWARE\Policies\Microsoft\Edge\' 'ProxySettings' '' '(user config)'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True

    "`n`n" | Out-File -Append $diagfile
    $Commands = @(
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkIsolation\' 'DProxiesAuthoritive' '' '(Policy: Proxy definitions are authoritative)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkIsolation\' 'DomainProxies' '' '(Policy: Internet proxy servers for apps)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkIsolation\' 'DomainLocalProxies' '' '(Policy: Intranet proxy servers for apps)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\NetworkIsolation\' 'CloudResources' '' '(Policy: Intranet proxy servers for apps)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\Software\Policies\Microsoft\Windows\TCPIP\v6Transition\' 'force_Tunneling' '' '(Policy: Enterprise resource domains hosted in the cloud)'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True

#region Checking for Firewall configuration
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running Firewall configuration check"
    " " | Out-File -Append $diagfile

    if (!($ver -like "*Windows 7*")) {
        $Commands = @(
            "UEXAVD_GetFirewallInfo"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True
    } else {
        UEXAVD_LogDiag $LogLevel.Warning ("... Windows 7 detected. Skipping check (not applicable).")
    }

#endregion Checking for Firewall configuration


#region Checking for DNS configuration
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running DNS configuration check"
    " " | Out-File -Append $diagfile

    if (!($ver -like "*Windows 7*")) {
        $Commands = @(
            "UEXAVD_GetDNSInfo"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters\' 'EnableNetbios' '' '(Policy: Configure NetBIOS settings)'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True

    } else {
        UEXAVD_LogDiag $LogLevel.Warning ("... Windows 7 detected. Skipping check (not applicable).")
    }

#endregion Checking for DNS configuration


#region Checking for DC information
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running Domain Controller information check"
    " " | Out-File -Append $diagfile

    $Commands = @(
        "UEXAVD_GetDCInfo"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True

#endregion Checking for DC information


#region Checking secure channel connection to the domain
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running domain secure channel connection check"
    " " | Out-File -Append $diagfile

    Try {
        $commandline = "Test-ComputerSecureChannel -Verbose 4>&1"
        $out = Invoke-Expression -Command $commandline
        foreach ($outopt in $out) {
            if ($outopt -like "*False*") {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] $outopt"
            } else {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... $outopt"
            }
        }
    } Catch {
        UEXAVD_LogException ("Error: An error occurred in $CommandLine") -ErrObj $_ $fLogFileOnly
        UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] Could not test secure channel connection. See AVD-Collect-Error.txt for more information."
    }

#endregion Checking secure channel connection to the domain


#region Checking for Azure AD-join configuration
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running Azure AD Join configuration check"
    " " | Out-File -Append $diagfile

    if (!($ver -like "*Windows 7*")) {
        $DsregCmdStatus = dsregcmd /status
        $Commands = @(
            "UEXAVD_GetDsregcmdInfo 'AzureAdJoined :'"
            "UEXAVD_GetDsregcmdInfo 'WorkplaceJoined :'"
            "UEXAVD_GetDsregcmdInfo 'DeviceAuthStatus :'"
            "UEXAVD_GetDsregcmdInfo 'TenantName :'"
            "UEXAVD_GetDsregcmdInfo 'TenantId :'"
            "UEXAVD_GetDsregcmdInfo 'DeviceID :'"
            "UEXAVD_GetDsregcmdInfo 'DeviceCertificateValidity :'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True

        $Commands = @(
            "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\pku2u\' 'AllowOnlineID '1''"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin\' 'BlockAADWorkplaceJoin'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin\' 'autoWorkplaceJoin'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Microsoft\IdentityStore\LoadParameters\{B16898C6-A148-4967-9171-64D755DA8520}\' 'Enabled'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True
    } else {
        UEXAVD_LogDiag $LogLevel.Warning ("... Windows 7 detected. Skipping check (not applicable).")
    }

#endregion Checking for Azure AD-join configuration


#region Checking RDP Shortpath configuration
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running RDP Shortpath check"
    " " | Out-File -Append $diagfile

    if (!($ver -like "*Windows 7*")) {
        if (Test-Path $agentpath) {
            $Commands = @(
                "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'fUseUdpPortRedirector' '1' '(Policy: Enable RDP Shortpath for managed networks)'"
                "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'UdpRedirectorPort' '3390' '(Policy: Enable RDP Shortpath for managed networks)'"
                "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client\' 'fClientDisableUDP'"
                "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'SelectTransport'"
                "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Microsoft\Terminal Server Client\' 'DisableUDPTransport'"
            )
            UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True
            
            # Checking if TermService is listening for UDP
            $udplistener = Get-NetUDPEndpoint -OwningProcess ((get-ciminstance win32_service -Filter "name = 'TermService'").ProcessId) -LocalPort 3390 -ErrorAction SilentlyContinue

            " " | Out-File -Append $diagfile
            if ($udplistener) {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... TermService is listening on UDP port 3390."
            } else {
                # Checking the process occupying UDP port 3390
                $procpid = (Get-NetUDPEndpoint -LocalPort 3390 -LocalAddress 0.0.0.0 -ErrorAction SilentlyContinue).OwningProcess

                if ($procpid) {
                    UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] TermService is NOT listening on UDP port 3390. RDP Shortpath is not configured properly. The UDP port 3390 is being used by:"
                    tasklist /svc /fi "PID eq $procpid" | Out-File -Append $diagfile
                } else {
                    UEXAVD_LogDiag $LogLevel.DiagFileOnly "... No process is listening on UDP port 3390. RDP Shortpath for managed networks is not enabled."
                }
            }

            "`n`n" | Out-File -Append $diagfile
            $Commands = @(
                "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\' 'ICEControl' '2' '(RDP Shortpath for public networks)'"
                "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'ICEEnableClientPortRange' '1'"
                "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'ICEClientPortBase'"
                "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'ICEClientPortRange'"
            )
            UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True
            
            #Checking STUN server connectivity and NAT type
            " " | Out-File -Append $diagfile
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... STUN server connectivity and NAT type:"
            RDPShortPathStun
            "`n`n" | Out-File -Append $diagfile

            #Checking if there are Firewall rules for UDP 3390
            $fwrulesUDP = (Get-NetFirewallPortFilter -Protocol UDP | Where-Object { $_.localport -eq '3390' } | Get-NetFirewallRule)
            if (@($fwrulesUDP.count) -eq 0) {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... No Windows Firewall rule is defined for UDP port 3390."
            } else {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... Found Windows Firewall rule for UDP port 3390. See 'FirewallRules.txt' for more information (not available in 'DiagOnly' mode)."
            }

            #Checking for events 131 in the past 5 days
            $StartTimeSP = (Get-Date).AddDays(-5)
            If (Get-WinEvent -FilterHashtable @{logname="Microsoft-Windows-RemoteDesktopServices-RdpCoreCDV/Operational"; id="131"; StartTime=$StartTimeSP} -MaxEvents 1 -ErrorAction SilentlyContinue | where-object { $_.Message -like '*UDP*' }) {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... One or more UDP events 131 have been found in the 'Microsoft-Windows-RemoteDesktopServices-RdpCoreCDV/Operational' event logs. RDP Shortpath was used within the last 5 days."
            } else {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... UDP events 131 not found in the 'Microsoft-Windows-RemoteDesktopServices-RdpCoreCDV/Operational' event logs. RDP Shortpath was not used within the last 5 days."
            }

        } else {
            UEXAVD_LogDiag $LogLevel.Warning "... AVD Agent not found. Skipping check (not applicable)."
        }

    } else {
        UEXAVD_LogDiag $LogLevel.Warning "... Windows 7 detected. Skipping check (not applicable)."
    }

#endregion Checking RDP Shortpath configuration


#region Checking RDP and RD Listener configuration
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running RDP and Remote Desktop Listener configuration check"
    " " | Out-File -Append $diagfile

    $Commands = @(
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'fDenyTSConnections' '' '(Policy: Allow users to connect remotely by using Remote Desktop Services)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'fSingleSessionPerUser' '' '(Policy: Restrict RDS users to a single RDS session)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'fQueryUserConfigFromDC'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'MaxInstanceCount' '' '(Policy: Limit number of connections)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' 'fDenyTSConnections' '0'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' 'fSingleSessionPerUser' '1'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' 'fEnableWinStation' '1'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' 'MaxInstanceCount' '4294967295'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True


    #checking if multiple AVD listener reg keys are present
    "`n`n" | Out-File -Append $diagfile
    if (Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\rdp-sxs*') {

        $SxSlisteners = (Get-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\rdp-sxs*').PSChildName
        $SxSlisteners | foreach-object -process {
            if ($_ -ne "rdp-sxs") {
                $AVDlistener = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\" + $_
                if (UEXAVD_TestRegistryValue -Path $AVDlistener -Value 'fEnableWinStation') {
                    $AVDkeyvalue = Get-ItemPropertyValue -Path $AVDlistener -name "fEnableWinStation"
                    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\" + $_ + "\fEnableWinStation' exists and has a value of: " + $AVDkeyvalue)
                }
                else {
                    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] AVD Listener reg keys found, but reg key 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\" + $_ + "\fEnableWinStation' not found.")
                }
            }
        }
    }
    else {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] AVD listener (HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\rdp-sxs*) reg keys not found. This machine is either not a AVD VM or the AVD listener is not configured properly.")
    }

    #checking for the current AVD listener version and "fReverseConnectMode"
    if (Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations') {
        if (UEXAVD_TestRegistryValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\' -Value 'ReverseConnectionListener') {
            $listenervalue = Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations' -name "ReverseConnectionListener"
            $listenerregpath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\' + $listenervalue

            if (UEXAVD_TestRegistryValue -Path $listenerregpath -Value 'fReverseConnectMode') {
                $revconkeyvalue = Get-ItemPropertyValue -Path $listenerregpath -name "fReverseConnectMode"
                if ($revconkeyvalue -eq "1") {
                    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\" + $listenervalue + "\fReverseConnectMode' exists and has a value of: " + $revconkeyvalue)
                } else {
                    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\" + $listenervalue + "\fReverseConnectMode' exists BUT has a value of: " + $revconkeyvalue + " (instead of the expected value of '1'). See: https://docs.microsoft.com/en-us/azure/virtual-desktop/troubleshoot-agent#error-stack-listener-isnt-working-on-windows-10-2004-vm")
                }
            } else {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\" + $listenervalue + "\fReverseConnectMode not found.")
            }
            
            $Commands = @(
                "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\$listenervalue\' 'MaxInstanceCount' '4294967295'"
            )
            UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... The AVD listener currently in use is: " + $listenervalue)

        } else {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\ReverseConnectionListener' not found. This machine is either not a AVD VM or the AVD listener is not configured properly.")
        }
    } else {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations' not found. This machine is either not a AVD VM or the AVD listener is not configured properly.")
    }

#endregion Checking RDP and RD Listener configuration


#region Checking RD Client configuration
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running AVD Remote Desktop clients check"
    " " | Out-File -Append $diagfile

    $RDCver = (Get-ItemProperty  hklm:\software\microsoft\windows\currentversion\uninstall\* | Where-Object {($_.DisplayName -eq "Remote Desktop")}).DisplayVersion
    
    if ($RDCver) {
        $RDCdate = (Get-ItemProperty  hklm:\software\microsoft\windows\currentversion\uninstall\* | Where-Object {($_.DisplayName -eq "Remote Desktop")}).InstallDate
        $RDCloc = (Get-ItemProperty  hklm:\software\microsoft\windows\currentversion\uninstall\* | Where-Object {($_.DisplayName -eq "Remote Desktop")}).InstallLocation

        $RDCverStrip = $RDCver.Replace(".","")
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Windows Desktop RD client found. Version: $RDCver (Installed on: $RDCdate - Install Location: $RDCloc)")
        if (($RDCverStrip -ge $minRDCver) -and ($RDCverStrip -lt $latestRDCver)) {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] You are using an older Windows Desktop RD Client version. Please consider updating. See: https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/clients/windowsdesktop-whatsnew")
        }
        if ($RDCverStrip -lt $minRDCver) {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] You are using an unsupported Windows Desktop RD Client version. Please update. See: https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/clients/windowsdesktop-whatsnew")
        }

        $Commands = @(
            "UEXAVD_CheckRegKeyValue 'HKLM:\Software\Microsoft\MSRDC\Policies\' 'AutomaticUpdates'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\Software\Microsoft\MSRDC\Policies\' 'ReleaseRing'"
            )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True

    } else {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Windows Desktop RD client not found.")
    }

    if (!($ver -like "*Windows 7*")) {
        $StoreClient = Get-AppxPackage -name microsoft.remotedesktop
        $StoreCver = $StoreClient.Version
        if ($StoreCver) { $StoreCverStrip = $StoreCver.Replace(".","") } else { $StoreCverStrip = 0 }

        if ($StoreClient) {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Microsoft Store RD client found. Version: " + $StoreCver)
    
            if (($StoreCverStrip -ge $minStoreCver) -and ($StoreCverStrip -lt $latestStoreCver)) {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] You are running an older Store RD Client version. Please consider updating. See: https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/clients/windows-whatsnew")
            }
            if ($StoreCverStrip -lt $minStoreCver) {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] You are running an older Store RD Client version which does not support AVD ARM connections. Please update. See: https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/clients/windows-whatsnew")
            }
        } else {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Microsoft Store RD client not found.")
        }
    }

#endregion Checking RD Client configuration


#region Checking for Session Time Limit configuration
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running Session Time Limit configuration check"
    " " | Out-File -Append $diagfile

    $Commands = @(
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'MaxIdleTime' '' '(Computer Policy: Set time limit for active but idle RDS sessions)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'MaxIdleTime' '' '(User Policy: Set time limit for active but idle RDS sessions)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'MaxConnectionTime' '' '(Computer Policy: Set time limit for active RDS sessions)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'MaxConnectionTime' '' '(User Policy: Set time limit for active RDS sessions)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'MaxDisconnectionTime' '' '(Computer Policy: Set time limit for disconnected sessions)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'MaxDisconnectionTime' '' '(User Policy: Set time limit for disconnected sessions)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'RemoteAppLogoffTimeLimit' '' '(Computer Policy: Set time limit for logoff of RemoteApp sessions)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'RemoteAppLogoffTimeLimit' '' '(User Policy: Set time limit for logoff of RemoteApp sessions)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'fResetBroken' '' '(Computer Policy: End session when time limits are reached)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'fResetBroken' '' '(User Policy: End session when time limits are reached)'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True
    
    "`n`n" | Out-File -Append $diagfile
    $Commands = @(
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' 'MaxIdleTime' '0'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' 'MaxConnectionTime' '0'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' 'MaxDisconnectionTime' '0'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' 'fResetBroken' '0'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True
    
    if (Test-Path $agentpath) {
        $Commands = @(
            "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\$listenervalue\' 'MaxIdleTime' '0'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\$listenervalue\' 'MaxConnectionTime' '0'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\$listenervalue\' 'MaxDisconnectionTime' '0'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\$listenervalue\' 'fResetBroken' '0'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True
    } else {
        UEXAVD_LogDiag $LogLevel.Warning "... AVD Agent not found. Skipping check of SxS listener keys (not applicable)."
    }

#endregion Checking for Session Time Limit configuration


#region Checking for redirection policy configuration
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running device and resource redirection policy configuration check"
    " " | Out-File -Append $diagfile

    $Commands = @(
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'fDisableAudioCapture' '' '(Policy: Allow audio recording redirection)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'fDisableCam' '' '(Policy: Allow audio and video playback redirection)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'fDisableCdm' '' '(Policy: Do not allow drive redirection)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'fDisableClip' '' '(Computer Policy: Do not allow clipboard redirection)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'fDisableClip' '' '(User Policy: Do not allow clipboard redirection)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'fDisableCcm' '' '(Policy: Do not allow COM port redirection)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'fDisableLPT' '' '(Policy: Do not allow LPT port redirection)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'fEnableSmartCard' '' '(Policy: Do not allow smart card device redirection)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'fDisablePNPRedir' '' '(Policy: Do not allow supported Plug and Play device redirection)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'fDisableCameraRedir' '' '(Policy: Do not allow video capture redirection)'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True

    "`n`n" | Out-File -Append $diagfile
    $Commands = @(
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'fEnableTimeZoneRedirection' '' '(Computer Policy: Allow time zone redirection)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'fEnableTimeZoneRedirection' '' '(User Policy: Allow time zone redirection)'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True

#endregion Checking for redirection policy configuration


#region Checking for Screen Capture Protection configuration
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running Screen Capture Protection configuration check"
    " " | Out-File -Append $diagfile

    if (Test-Path $agentpath) {
        $Commands = @(
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'fEnableScreenCaptureProtect' '' '(Policy: Enable screen capture protection)'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True
    } else {
        UEXAVD_LogDiag $LogLevel.Warning "... AVD Agent not found. Skipping check (not applicable)."
    }

#endregion Checking for Screen Capture Protection configuration


#region Checking for Licensing configuration
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running Licensing configuration check"
    " " | Out-File -Append $diagfile

    if (Test-Path $agentpath) {
            $Commands = @(
                "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'LicenseServers' '' '(policy config)'"
                "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'LicensingMode' '' '(policy config)'"
                "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Services\TermService\Parameters\LicenseServers\' 'SpecifiedLicenseServers' '' '(local config)'"
                "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\Licensing Core\' 'LicensingMode' '' '(local config)'"
            )
            UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True
    } else {
        UEXAVD_LogDiag $LogLevel.Warning "... AVD Agent not found. Skipping check (not applicable)."
    }

#endregion Checking for Licensing configuration


#region Checking User Rights policy configuration
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running User Rights policy configuration check"
    " " | Out-File -Append $diagfile
    Get-UserRights

#endregion Checking User Rights policy configuration
    
    
#region Checking FSLogix configuration
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running FSLogix configuration check"
    " " | Out-File -Append $diagfile

    $cmd = "c:\program files\fslogix\apps\frx.exe"

    if (Test-path -path 'C:\Program Files\FSLogix\apps') {

        Invoke-Expression "& '$cmd' + 'version'" | ForEach-Object -Process {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... " + $_)
            if ($_ -like "*Service*") {
                $frxver = ($_.Split(":")[1]).Trim()
                $frxverstrip = $frxver.Replace(".","")
            }
        }

        if ($frxverstrip -lt $latestFSLogixVer) {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] You are not using the latest available FSLogix release. Please consider updating. See: https://docs.microsoft.com/en-us/fslogix/whats-new"
        }

        "`n`n" | Out-File -Append $diagfile
        if (UEXAVD_TestRegistryValue -path "HKLM:\SOFTWARE\FSLogix\Profiles\" -value "Enabled") {
            $pOn = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\FSLogix\Profiles\" -name "Enabled"
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... FSLogix Profiles container 'Enabled' reg key found and has a value of: " + $pOn)

            if (UEXAVD_TestRegistryValue -path "HKLM:\SOFTWARE\FSLogix\Profiles\" -value "VHDLocations") {
                $pvhd = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\FSLogix\Profiles\" -name "VHDLocations"
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... FSLogix Profiles container 'VHDLocations' reg key found and has a value of: " + $pvhd)
                $pconPath = $pvhd.split("\")[2]
                if ($pconPath) {
                    $pconTest = "Test-NetConnection -ComputerName $pconPath -Port 445"
                    $pconout = (Invoke-Expression -Command $pconTest).TcpTestSucceeded
                    if ($pconout) {
                        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Test-NetConnection result: Profile storage location '$pconPath' is reachable (TcpTestSucceeded: $pconout).")
                    }
                    if ($pconout.PingSucceeded) {
                        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] Test-NetConnection result: Profile storage location '$pconPath' may not be reachable (PingSucceeded: $pconout).")
                    }
                }
            } else {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] FSLogix Profile Container 'VHDLocations' reg key not found.")
            }

            if (UEXAVD_TestRegistryValue -path "HKLM:\SOFTWARE\FSLogix\Profiles\" -value "CCDLocations") {
                $pccd = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\FSLogix\Profiles\" -name "CCDLocations"
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... FSLogix Cloud Cache for Profile Container 'CCDLocations' reg key found.")# and has a value of: " + $pccd)
            } else {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... FSLogix Cloud Cache for Profile Container 'CCDLocations' reg key not found.")
            }

            if ((UEXAVD_TestRegistryValue -path "HKLM:\SOFTWARE\FSLogix\Profiles\" -value "VHDLocations") -and (UEXAVD_TestRegistryValue -path "HKLM:\SOFTWARE\FSLogix\Profiles\" -value "CCDLocations")) {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] Both Profile VHDLocations and Profile Cloud Cache CCDLocations reg keys are present. If you want to use Profile Cloud Cache, remove any setting for Profile 'VHDLocations'. See https://docs.microsoft.com/en-us/fslogix/configure-cloud-cache-tutorial#configure-cloud-cache-for-smb")
            }

        } else {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] FSLogix Profile Container 'Enabled' reg key not found. Profile container is not enabled.")
        }

        "`n`n" | Out-File -Append $diagfile
        if (UEXAVD_TestRegistryValue -path "HKLM:\SOFTWARE\Policies\FSLogix\ODFC\" -value "Enabled") {
            $oOn = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Policies\FSLogix\ODFC\" -name "Enabled"
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... FSLogix Office container 'Enabled' reg key found and has a value of: " + $oOn)

            if (UEXAVD_TestRegistryValue -path "HKLM:\SOFTWARE\Policies\FSLogix\ODFC\" -value "VHDLocations") {
                $ovhd = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Policies\FSLogix\ODFC\" -name "VHDLocations"
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... FSLogix Office container 'VHDLocations' reg key found and has a value of: " + $ovhd)
                $oconPath = $ovhd.split("\")[2]
                if ($oconPath) {
                    $oconTest = "Test-NetConnection -ComputerName $oconPath -Port 445"
                    $oconout = (Invoke-Expression -Command $oconTest).TcpTestSucceeded
                    if ($oconout) {
                        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Test-NetConnection result: ODFC storage is reachable (TcpTestSucceeded: $oconout).")
                    }
                    if ($oconout.PingSucceeded) {
                        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] Test-NetConnection result: ODFC storage may not be reachable (PingSucceeded: $oconout).")
                    }
                }
            } else {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] FSLogix Office Container 'VHDLocations' reg key not found.")
            }

            if (UEXAVD_TestRegistryValue -path "HKLM:\SOFTWARE\Policies\FSLogix\ODFC\" -value "CCDLocations") {
                $occd = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Policies\FSLogix\ODFC\" -name "CCDLocations"
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... FSLogix Cloud Cache for Office Container 'CCDLocations' reg key found.")# and has a value of: " + $occd)
            } else {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... FSLogix Cloud Cache for Office Container 'CCDLocations' reg key not found.")
            }

            if ((UEXAVD_TestRegistryValue -path "HKLM:\SOFTWARE\Policies\FSLogix\ODFC\" -value "VHDLocations") -and (UEXAVD_TestRegistryValue -path "HKLM:\SOFTWARE\Policies\FSLogix\ODFC\" -value "CCDLocations")) {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] Both Office VHDLocations and Office Cloud Cache CCDLocations reg keys are present. If you want to use Office Cloud Cache, remove any setting for Office 'VHDLocations'. See https://docs.microsoft.com/en-us/fslogix/configure-cloud-cache-tutorial#configure-cloud-cache-for-smb")
            }

        } else {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] FSLogix Office Container 'Enabled' reg key not found. Office Container is not enabled.")
        }

        "`n`n" | Out-File -Append $diagfile
        if ($frxverstrip -ge $cleanupFSLogixVer) {
            $Commands = @(
                "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\FSLogix\Apps\' 'CleanupInvalidSessions' '1'"
            )
            UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True
        } else {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... FSLogix release earlier than release 2009 found. Update to the latest release. See: https://docs.microsoft.com/en-us/fslogix/whats-new"
        }

        $Commands = @(
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\FSLogix\Profiles\' 'DeleteLocalProfileWhenVHDShouldApply' '1'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\FSLogix\Profiles\' 'SizeInMBs' '30000'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\FSLogix\Profiles\' 'VolumeType' 'VHDx'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\FSLogix\Profiles\' 'FlipFlopProfileDirectoryName' '1'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\FSLogix\Profiles\' 'NoProfileContainingFolder' '0'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\FSLogix\Profiles\' 'RedirXMLSourceFolder'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True
        
        " " | Out-File -Append $diagfile
        $Commands = @(
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC\' 'IncludeOfficeActivation'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC\' 'DeleteLocalProfileWhenVHDShouldApply' '1'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC\' 'SizeInMBs' '30000'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC\' 'VolumeType' 'VHDx'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC\' 'FlipFlopProfileDirectoryName' '1'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC\' 'NoProfileContainingFolder' '0'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True

        " " | Out-File -Append $diagfile
        $Commands = @(
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\' 'SpecialRoamingOverrideAllowed'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Kerberos\Parameters\' 'CloudKerberosTicketRetrievalEnabled'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\AzureADAccount\' 'LoadCredKeyFromProfile'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters\' 'CloudKerberosTicketRetrievalEnabled'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True

        "`n`n" | Out-File -Append $diagfile
        UEXAVD_LogDiag $LogLevel.DiagFileOnly "... FSLogix service recovery settings:"
        $commandline = "sc.exe qfailure frxsvc"
        $out = Invoke-Expression -Command $commandline
        foreach ($outopt in $out) {
            if (($outopt -like "*RESET*") -or ($outopt -like "*REBOOT*") -or ($outopt -like "*COMMAND*") -or ($outopt -like "*FAILURE*") -or ($outopt -like "*RUN*") -or ($outopt -like "*RESTART*")) {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... ... $outopt"
            }
        }

    } else {
        UEXAVD_LogDiag $LogLevel.Warning "... FSLogix not found. Skipping check (not applicable)."
    }

#endregion Checking FSLogix configuration


#region Checking for Antivirus software
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running Antivirus software check"
    " " | Out-File -Append $diagfile

    $Commands = @(
        "UEXAVD_GetAntivirusInfo"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True

    if ($ver -like "*Windows Server*") {
        $WDpath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\"
        $WDkey = "DisableAntiSpyware"
        if (UEXAVD_TestRegistryValue -path $WDpath -value $WDkey) {
            (Get-ItemProperty -path $WDpath).PSChildName | foreach-object -process {
                $key = Get-ItemPropertyValue -Path $WDpath -name $WDkey

                if ($key -eq $True) {
                    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] '$WDpath$WDkey' exists and is set to 'True'. It is not recommended to disable Windows Defender, unless you are using another Antivirus software. See: https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/security-malware-windows-defender-disableantispyware")
                }
                else {
                    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... '$WDpath$WDkey' exists and is set to 'False'.")
                }
            }
        } else {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... '$WDpath$WDkey' not found.")
        }
    }

#endregion Checking for Antivirus software

#region Checking for proper Defender Exclusions for FSLogix
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running recommended FSLogix Windows Defender Exclusions check"
    " " | Out-File -Append $diagfile

    if (Test-path -path 'C:\Program Files\FSLogix\apps') {

        #checking for actual Profiles VHDLocations value
        $pVHDpath = "HKLM:\SOFTWARE\FSLogix\Profiles\"
        $pVHDkey = "VHDLocations"
        if (UEXAVD_TestRegistryValue -path $pVHDpath -value $pVHDkey) {
            $pkey = (Get-ItemPropertyValue -Path $pVHDpath -name $pVHDkey).replace("`n","")
            $pkey1 = $pkey + "\*.VHD"
            $pkey2 = $pkey + "\*.VHDX"
        } else {
            #no path found, defaulting to generic value
            $pkey1 = "\\<storageaccount>.file.core.windows.net\<share>\*.VHD"
            $pkey2 = "\\<storageaccount>.file.core.windows.net\<share>\*.VHDX"
        }

        $ccdVHDkey = "CCDLocations"
        if (UEXAVD_TestRegistryValue -path $pVHDpath -value $ccdVHDkey) {
            $ccdkey = $True
        } else {
            $ccdkey = $false
        }

        $ccdRec = "%ProgramData%\FSLogix\Cache\*.VHD","%ProgramData%\FSLogix\Cache\*.VHDX","%ProgramData%\FSLogix\Proxy\*.VHD","%ProgramData%\FSLogix\Proxy\*.VHDX"
        $avRec = "%ProgramFiles%\FSLogix\Apps\frxdrv.sys","%ProgramFiles%\FSLogix\Apps\frxdrvvt.sys","%ProgramFiles%\FSLogix\Apps\frxccd.sys","%TEMP%\*.VHD","%TEMP%\*.VHDX","%Windir%\TEMP\*.VHD","%Windir%\TEMP\*.VHDX"

        UEXAVD_LogDiag $LogLevel.DiagFileOnly "... The script is comparing existing Windows Defender exclusion settings with recommended settings. See https://docs.microsoft.com/en-us/azure/architecture/example-scenario/wvd/windows-virtual-desktop-fslogix#antivirus-exclusions"
        UEXAVD_LogDiag $LogLevel.DiagFileOnly "... The recommended values can be configured locally or through GPO. They should be present at least in one of the locations."
        UEXAVD_LogDiag $LogLevel.DiagFileOnly "... Comparing local values found with recommended values. False positives may occur if you use full paths instead of environment variables."

        " " | Out-File -Append $diagfile

        if ($ccdkey) {
            $recAVexclusionsPaths = $avRec + $pkey1 + $pkey2 + $ccdRec
        } else {
            $recAVexclusionsPaths = $avRec + $pkey1 + $pkey2
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... Cloud Cache is not enabled. The recommended Cloud Cache Exclusions will not be taken into consideration for this check. This may lead to false positives if you have the Cloud Cache Exclusions configured."
        }

        "`n`n" | Out-File -Append $diagfile
        UEXAVD_LogDiag $LogLevel.DiagFileOnly "... Windows Defender Paths exclusions (local config)"
        UEXAVD_TestAVExclusion "HKLM:\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" $recAVexclusionsPaths
        " " | Out-File -Append $diagfile
        UEXAVD_LogDiag $LogLevel.DiagFileOnly "... Windows Defender Paths exclusions (GPO config)"
        UEXAVD_TestAVExclusion "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Paths" $recAVexclusionsPaths

        "`n`n" | Out-File -Append $diagfile
        UEXAVD_LogDiag $LogLevel.DiagFileOnly "... Windows Defender Processes exclusions (local config)"
        UEXAVD_TestAVExclusion "HKLM:\SOFTWARE\Microsoft\Windows Defender\Exclusions\Processes" ("%ProgramFiles%\FSLogix\Apps\frxccd.exe","%ProgramFiles%\FSLogix\Apps\frxccds.exe","%ProgramFiles%\FSLogix\Apps\frxsvc.exe")
        " " | Out-File -Append $diagfile
        UEXAVD_LogDiag $LogLevel.DiagFileOnly "... Windows Defender Processes exclusions (GPO config)"
        UEXAVD_TestAVExclusion "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Processes" ("%ProgramFiles%\FSLogix\Apps\frxccd.exe","%ProgramFiles%\FSLogix\Apps\frxccds.exe","%ProgramFiles%\FSLogix\Apps\frxsvc.exe")

    } else {
        UEXAVD_LogDiag $LogLevel.Warning "... FSLogix not found. Skipping check (not applicable)."
    }

#endregion Checking for proper Defender Exclusions for FSLogix


#region Checking Office configuration
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running Microsoft Office configuration check"
    " " | Out-File -Append $diagfile

    $oversion = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\O365ProPlusRetail* -ErrorAction SilentlyContinue

    if ($oversion) {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly "... Office installation found: $($oversion.Displayname) ($($oversion.DisplayVersion))"

        $Commands = @(
            "UEXAVD_CheckRegKeyValue 'HKCU:\SOFTWARE\Policies\Microsoft\office\16.0\common\' 'InsiderSlabBehavior' '2'"
            "UEXAVD_CheckRegKeyValue 'HKCU:\SOFTWARE\Policies\Microsoft\office\16.0\outlook\cached mode\' 'enable' '1'"
            "UEXAVD_CheckRegKeyValue 'HKCU:\SOFTWARE\Policies\Microsoft\office\16.0\outlook\cached mode\' 'syncwindowsetting' '1'"
            "UEXAVD_CheckRegKeyValue 'HKCU:\SOFTWARE\Policies\Microsoft\office\16.0\outlook\cached mode\' 'CalendarSyncWindowSetting' '1'"
            "UEXAVD_CheckRegKeyValue 'HKCU:\SOFTWARE\Policies\Microsoft\office\16.0\outlook\cached mode\' 'CalendarSyncWindowSettingMonths' '1'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate\' 'hideupdatenotifications' '1'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate\' 'hideenabledisableupdates' '1'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True
    
    } else {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly "... Microsoft Office not found. Skipping check (not applicable)."
    }
    

#endregion Checking Office configuration


#region Checking OneDrive configuration
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running OneDrive configuration check"
    " " | Out-File -Append $diagfile

    $ODM86 = "C:\Program Files (x86)\Microsoft OneDrive" + '\OneDrive.exe'
    $ODM = "C:\Program Files\Microsoft OneDrive" + '\OneDrive.exe'
    $ODU = "$ENV:localappdata" + '\Microsoft\OneDrive\OneDrive.exe'

    if ((test-path $ODM86) -or (test-path $ODM) -or (test-path $ODU)) {

        if (test-path $ODM) {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... Found OneDrive per-machine installation. ($ODM)"
        } elseif (test-path $ODM86) {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] Found OneDrive per-user installation. ($ODM86)"
        } else {
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] Found OneDrive per-user installation. ($ODU)"
        }

        $Commands = @(
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Microsoft\OneDrive\' 'AllUsersInstall' '1'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\FSLogix\Profiles\' 'ConcurrentUserSessions' '0'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\FSLogix\Profiles\' 'ProfileType' '0'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC\' 'VHDAccessMode' '0'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\' 'OneDrive'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce\' 'OneDrive'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\RailRunonce\' 'OneDrive'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True

    } else {
        UEXAVD_LogDiag $LogLevel.Warning "... OneDrive installation not found."
    }

#endregion Checking OneDrive configuration


#region Checking media optimization configuration for Teams
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running Teams media optimization configuration check"
    " " | Out-File -Append $diagfile

    if ($ver -like "*Windows 1*") {

        $Commands = @(
            "UEXAVD_CheckRegKeyValue 'HKCU:\SOFTWARE\Microsoft\Terminal Server Client\' 'IsSwapChainRenderingEnabled' '' '(Client side GPU render path optimization)'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True
        " " | Out-File -Append $diagfile

        if (Test-Path $agentpath) {
            #Checking Teams installation info
            $TeamsLogPath = $env:userprofile + "\AppData\Local\Microsoft\Teams\current\Teams.exe"
            if(Test-Path $TeamsLogPath) {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] Teams is installed in per-user mode. Teams won't work properly with per-user installation on a non-persistent setup."
                $isinst = $true
            } elseif (Test-Path "C:\Program Files (x86)\Microsoft\Teams\current\Teams.exe") {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly "... Teams is installed in per-machine mode."
                $isinst = $true
            } else {
                UEXAVD_LogDiag $LogLevel.Warning "... Teams not found. Skipping check (not applicable)."
                $isinst = $false
            }

            if ($isinst) {
                #Checking reg keys
                $Commands = @(
                "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Microsoft\Teams\' 'IsWVDEnvironment' '1'"
                "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\AddIns\WebRTC Redirector\' 'Enabled' '1'"
                "UEXAVD_CheckRegPath 'HKLM:\SOFTWARE\Citrix\PortICA' '(This path should not exist on an AVD-only deployment)'"
                "UEXAVD_CheckRegPath 'HKLM:\SOFTWARE\VMware, Inc.\VMware VDM\Agent' '(This path should not exist on an AVD-only deployment)'"
                )
                UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True
                
                " " | Out-File -Append $diagfile
                #Checking Teams deployment
                $verpath = $env:userprofile + "\AppData\Roaming\Microsoft\Teams\settings.json"

                if (Test-Path $verpath) {
                    if ($PSVersionTable.PSVersion -like "*5.1*") {
                        $response = Get-Content $verpath -ErrorAction Continue
                        $response = $response -creplace 'enableIpsForCallingContext','enableIPSForCallingContext'
                        $response = $response | ConvertFrom-Json

                        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Teams version: " + $response.version)
                        
                        if ($response.ring) { $teamsring = $response.ring } else { $teamsring = "N/A" }
                        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Teams ring: " + $teamsring)
                        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Teams environment: " + $response.environment)
                    } else {
                        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Teams version: " + (Get-Content $verpath -ErrorAction Continue | ConvertFrom-Json -AsHashTable).version)
                        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Teams ring: " + (Get-Content $verpath -ErrorAction Continue | ConvertFrom-Json -AsHashTable).ring)
                        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Teams environment: " + (Get-Content $verpath -ErrorAction Continue | ConvertFrom-Json -AsHashTable).environment)
                    }
                } else {
                    UEXAVD_LogDiag $LogLevel.Warning "... $verpath not found."
                }

                $WebRTCver = (Get-CimInstance -Class Win32_Product | Where-Object name -eq "Remote Desktop WebRTC Redirector Service").Version
                $WebRTCstrip = $WebRTCver -replace '[.]',''
                if ($WebRTCver) {
                    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Remote Desktop WebRTC Redirector Service version: " + $WebRTCver)
                    if ($WebRTCstrip -lt $latestWebRTCVer) {
                        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] You are not using the latest available Remote Desktop WebRTC Redirector Service version. Please consider updating. See https://docs.microsoft.com/en-us/azure/virtual-desktop/teams-on-avd#install-the-teams-websocket-service")
                    }
                } else {
                    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] The Remote Desktop WebRTC Redirector Service is not installed. Media optimization for Teams is not configured or this machine is not part of an AVD host pool. See: https://docs.microsoft.com/en-us/azure/virtual-desktop/teams-on-AVD#install-the-teams-websocket-service")
                }

                # Checking if MsRdcWebRTCSvc.exe is listening on port 9500
                $webrtcprocess = (get-ciminstance win32_process -Filter "name = 'MsRdcWebRTCSvc.exe'").ProcessId

                if ($webrtcprocess) {
                    $webrtclistener = Get-NetTCPConnection -OwningProcess $webrtcprocess -LocalPort 9500 -ErrorAction SilentlyContinue

                    if ($webrtclistener) {
                        UEXAVD_LogDiag $LogLevel.DiagFileOnly "... MsRdcWebRTCSvc is listening on TCP port 9500."
                    } else {
                        # Checking the process occupying TCP port 9500
                        $rtcprocpid = (Get-NetTCPConnection -LocalPort 9500 -LocalAddress 127.0.0.1 -ErrorAction SilentlyContinue).OwningProcess

                        if ($rtcprocpid) {
                            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] MsRdcWebRTCSvc is not listening on TCP port 9500. AVD Media Optimization may not work. The TCP port 9500 is being used by:"
                            tasklist /svc /fi "PID eq $rtcprocpid" | Out-File -Append $diagfile
                        } else {
                            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] No process is using TCP port 9500. Teams Media Optimization may not work."
                        }
                    }

                } else {
                    UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] MsRdcWebRTCSvc.exe process not found. AVD Media Optimization may not work."
                }
            }

        } else {
            UEXAVD_LogDiag $LogLevel.Warning "... AVD Agent not found. Skipping further check (not applicable)."
        }
    } else {
        UEXAVD_LogDiag $LogLevel.Warning "... Windows 10+ OS not found. Skipping check (not applicable)."
    }

#endregion Checking media optimization configuration for Teams


#region Checking multimedia configuration
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running multimedia configuration check"
    " " | Out-File -Append $diagfile

    if (!($ver -like "*Windows 7*")) {
        $Commands = @(
            "UEXAVD_CheckRegKeyValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone\' 'Value' '' '(Microphone access - general)'"
            "UEXAVD_CheckRegKeyValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone\NonPackaged\' 'Value' '' '(Microphone access - desktop apps)'"
            "UEXAVD_CheckRegKeyValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam\' 'Value' '' '(Camera access - general)'"
            "UEXAVD_CheckRegKeyValue 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam\NonPackaged\' 'Value' '' '(Camera access - desktop apps)'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True
        
        "`n`n" | Out-File -Append $diagfile
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Multimedia Redirection (MMR):")
        if (Test-Path 'HKLM:\SOFTWARE\Microsoft\RDAgentBootLoader') {
            $isMMR = Get-CimInstance -NameSpace "root\cimv2" -Query "select * from Win32_Product" | Where-Object Name -eq 'MsMmrHostMsi'
            if ($isMMR) {
                $MMRver = $isMMR.Version
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... MsMmrHostMri installation found. Multimedia Redirection extensions are installed on this machine. Check manually if the extension is enabled in Edge/Chrome.")
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... MsMmrHostMri version: $MMRver")
            } else {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... MsMmrHostMri installation not found. Multimedia Redirection extensions may not be installed on this machine or they have been installed manually or through browser policy.")
            }
        } else {
            UEXAVD_LogDiag $LogLevel.Warning ("... AVD Agent not found. Skipping check (not applicable).")
        }

        " " | Out-File -Append $diagfile
        $Commands = @(
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Google\Chrome\' 'ExtensionSettings'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Edge\' 'ExtensionSettings'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True

    } else {
        UEXAVD_LogDiag $LogLevel.Warning "... Windows 7 detected. Skipping check. (not applicable)"
    }

#endregion Checking multimedia configuration


#region Checking Printing settings
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running print settings check"
    " " | Out-File -Append $diagfile

    if (!($ver -like "*Windows 7*")) {
        $Commands = @(
            "UEXAVD_CheckRegKeyValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Print\' 'RpcAuthnLevelPrivacyEnabled'"
            "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC\' 'RpcNamedPipeAuthentication'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True

    } else {
        UEXAVD_LogDiag $LogLevel.Warning "... Windows 7 detected. Skipping check. (not applicable)"
    }

#endregion Checking Printing settings


#region Checking for settings potentially related to Black Screen logon scenarios
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running check for settings sometimes related to Black Screen logon scenarios"
    UEXAVD_LogDiag $LogLevel.DiagFileOnly "... These settings are not mandatory, but sometimes incorrect configuration of one or more of these might lead to Black Screen during logon. If you suspect any of these settings to cause issues, additional troubleshooting will be required."
    "`n`n" | Out-File -Append $diagfile

    $Commands = @(
        "UEXAVD_CheckRegKeyValue 'HKCU:\Software\Policies\Microsoft\Windows\NetCache\' 'DisableFRAdminPin'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\Software\Policies\Microsoft\Windows\NetCache\{3EB685DB-65F9-4CF6-A03A-E3EF65729F3D}\' 'DisableFRAdminPinByFolder' '' '(AppData(Roaming) folder redirection)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\Software\Policies\Microsoft\Windows\NetCache\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\' 'DisableFRAdminPinByFolder' '' '(Desktop folder redirection)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\Software\Policies\Microsoft\Windows\NetCache\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\' 'DisableFRAdminPinByFolder' '' '(Start Menu folder redirection)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\Software\Policies\Microsoft\Windows\NetCache\{FDD39AD0-238F-46AF-ADB4-6C85480369C7}\' 'DisableFRAdminPinByFolder' '' '(Documents folder redirection)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\Software\Policies\Microsoft\Windows\NetCache\{33E28130-4E1E-4676-835A-98395C3BC3BB}\' 'DisableFRAdminPinByFolder' '' '(Pictures folder redirection)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\Software\Policies\Microsoft\Windows\NetCache\{4BD8D571-6D19-48D3-BE97-422220080E43}\' 'DisableFRAdminPinByFolder' '' '(Music folder redirection)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\Software\Policies\Microsoft\Windows\NetCache\{18989B1D-99B5-455B-841C-AB7C74E4DDFC}\' 'DisableFRAdminPinByFolder' '' '(Videos folder redirection)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\Software\Policies\Microsoft\Windows\NetCache\{1777F761-68AD-4D8A-87BD-30B759FA33DD}\' 'DisableFRAdminPinByFolder' '' '(Favorites folder redirection)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\Software\Policies\Microsoft\Windows\NetCache\{56784854-C6CB-462b-8169-88E350ACB882}\' 'DisableFRAdminPinByFolder' '' '(Contacts folder redirection)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\Software\Policies\Microsoft\Windows\NetCache\{374DE290-123F-4565-9164-39C4925E467B}\' 'DisableFRAdminPinByFolder' '' '(Downloads folder redirection)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\Software\Policies\Microsoft\Windows\NetCache\{BFB9D5E0-C6A9-404C-B2B2-AE6DB6AF4968}\' 'DisableFRAdminPinByFolder' '' '(Links folder redirection)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\Software\Policies\Microsoft\Windows\NetCache\{7D1D3A04-DEBB-4115-95CF-2F29DA2920DA}\' 'DisableFRAdminPinByFolder' '' '(Searches folder redirection)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\Software\Policies\Microsoft\Windows\NetCache\{4C5C32FF-BB9D-43B0-B5B4-2D72E54EAAA4}\' 'DisableFRAdminPinByFolder' '' '(Saved Games folder redirection)'"
        "UEXAVD_CheckRegKeyValue 'HKCU:\SOFTWARE\Microsoft\Active Setup\Installed Components\{89820200-ECBD-11cf-8B85-00AA005B4340}\' 'IsInstalled'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\' 'AVCHardwareEncodePreferred' '' '(Policy: Configure H.264/AVC hardware encoding for Remote Desktop Connections)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata\' 'PreventDeviceMetadataFromNetwork' '' '(Policy: Prevent device metadata retrieval from the Internet)'"
        "UEXAVD_CheckRegKeyValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\' 'DenyUnspecified' '' '(Policy: Prevent installation of devices not described by other policy settings)'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True
    
    if (Test-path -path 'C:\Program Files\FSLogix\apps') {
        if ($frxverstrip -lt $latestFSLogixVer) {
            "`n`n" | Out-File -Append $diagfile
            UEXAVD_LogDiag $LogLevel.DiagFileOnly "... [WARNING] You are not using the latest available FSLogix release. Please consider updating. See: https://docs.microsoft.com/en-us/fslogix/whats-new"
        }
    }

    if (!($ver -like "*Windows 7*")) {
        "`n`n" | Out-File -Append $diagfile
        $servlist = "CscService", "AppXSvc", "AppReadiness"
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Services:")
        $servlist | ForEach-Object -Process {
            $service = Get-Service -Name $_ -ErrorAction SilentlyContinue
            if ($service.Length -gt 0) {
                $servstatus = (Get-Service $_).Status
                $servdispname = (Get-Service $_).DisplayName
                $servstart = (Get-Service $_).StartType
                if ($servstart -eq "Disabled") {
                    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] " + $_ + " (" + $servdispname + ") is in " + $servstatus + " state (StartType: " + $servstart + ").")
                } else {
                    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... " + $_ + " (" + $servdispname + ") is in " + $servstatus + " state (StartType: " + $servstart + ").")
                }
            }
            else {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] " + $_ + " not found.")
            }
        }
    }

#endregion Checking for settings potentially related to Black Screen logon scenarios


#region Checking for issues in event logs
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running issue events check over the past 5 days - this may take longer"
    " " | Out-File -Append $diagfile
    
    if (Test-Path $agentpath) {
        $Commands = @(
            "UEXAVD_DiagMsgIssues 'Agent' 'Application' @(3019,3277,3389,3703) @('Transport received an exception','ENDPOINT_NOT_FOUND','INVALID_FORM','INVALID_REGISTRATION_TOKEN','NAME_ALREADY_REGISTERED','DownloadMsiException','InstallationHealthCheckFailedException','InstallMsiException','AgentLoadException','BootLoader exception','Unable to retrieve DefaultAgent from registry','MissingMethodException','RD Gateway Url') 'Full'"
            "UEXAVD_DiagMsgIssues 'Agent' 'RemoteDesktopServices' @(0) @('IMDS not accessible','Monitoring Agent Launcher file path was NOT located','NOT ALL required URLs are accessible!','SessionHost unhealthy','Unable to connect to the remote server','Unhandled status [ConnectFailure] returned for url','System.ComponentModel.Win32Exception (0x80004005)','Unable to extract and validate Geneva URLs','PingHost: Could not PING url','Unable to locate running process') 'Full'"
            "UEXAVD_DiagProvIssues 'MSIXAA' 'RemoteDesktopServices' @(0) @('Microsoft.RDInfra.AppAttach.AgentAppAttachPackageListServiceImpl','Microsoft.RDInfra.AppAttach.AppAttachServiceImpl','Microsoft.RDInfra.AppAttach.SysNtfyServiceImpl','Microsoft.RDInfra.AppAttach.UserImpersonationServiceImpl','Microsoft.RDInfra.RDAgent.AppAttach.CimVolume','Microsoft.RDInfra.RDAgent.AppAttach.ImagedMsixExtractor','Microsoft.RDInfra.RDAgent.AppAttach.MsixProcessor','Microsoft.RDInfra.RDAgent.AppAttach.VhdVolume','Microsoft.RDInfra.RDAgent.AppAttach.VirtualDiskManager','Microsoft.RDInfra.RDAgent.Service.AppAttachHealthCheck') ''"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True
    
        if (UEXAVD_TestRegistryValue -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\" -value "fUseUdpPortRedirector") {
            $spKey = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\" -name "fUseUdpPortRedirector"
        }
        if (UEXAVD_TestRegistryValue -path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\" -value "ICEControl") {
            $spKey2 = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\" -name "ICEControl"
        }

        if ((UEXAVD_TestRegistryValue -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\" -value "fUseUdpPortRedirector") -or (UEXAVD_TestRegistryValue -path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\" -value "ICEControl")) {
            if (($spKey -eq 1) -or ($spKey2 -eq 2)) {
                $Commands = @(
                    "UEXAVD_DiagMsgIssues 'Shortpath' 'Microsoft-Windows-RemoteDesktopServices-RdpCoreCDV/Operational' @(135,226) @('UDP Handshake Timeout','UdpEventErrorOnMtReqComplete') 'Full'"
                )
                UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True
            } else {
                UEXAVD_LogDiag $LogLevel.Warning "... [WARNING] Shortpath not configured properly. Please review Shortpath configuration if you intend to use it. Skipping check for Shortpath events issues (not applicable)."
            }
        } else {
            UEXAVD_LogDiag $LogLevel.Warning "... Shortpath configuration not found. Skipping check for Shortpath issues (not applicable)."
        }

        if ($WinVerBuild -lt "19041") {
            UEXAVD_LogDiag $LogLevel.Warning "... [WARNING] MSIX App Attach requires Windows 10 Enterprise or Windows 10 Enterprise multi-session, version 2004 or later. If you plan on using MSIX App Attach please upgrade the operating system first."
        }
    } else {
        UEXAVD_LogDiag $LogLevel.Warning "... AVD Agent not found. Skipping check for agent issues (not applicable)."
    }

    if (Test-path -path 'C:\Program Files\FSLogix\apps') {
        $Commands = @(            
            "UEXAVD_DiagProvIssues 'FSLogix' 'Microsoft-FSLogix-Apps/Admin' '' @('Microsoft-FSLogix-Apps') ''"
            "UEXAVD_DiagProvIssues 'FSLogix' 'Microsoft-FSLogix-Apps/Operational' '' @('Microsoft-FSLogix-Apps') ''"
            "UEXAVD_DiagMsgIssues 'FSLogix' 'RemoteDesktopServices' @(0) @('The disk detach may have invalidated handles','ErrorCode: 743') 'Full'"
            "UEXAVD_DiagMsgIssues 'FSLogix' 'System' @(4) @('The Kerberos client received a KRB_AP_ERR_MODIFIED error from the server') 'Full'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True
    } else {
        UEXAVD_LogDiag $LogLevel.Warning "... FSLogix not found. Skipping check for FSLogix issues (not applicable)."
    }

    $Commands = @(            
        "UEXAVD_DiagMsgIssues 'TCP' 'System' @(4227) @('TCP/IP failed to establish') 'Full'"
        "UEXAVD_DiagMsgIssues 'BlackScreen' 'Application' @(4005) @('The Windows logon process has unexpectedly terminated') 'Full'"
        "UEXAVD_DiagMsgIssues 'BlackScreen' 'System' @(7011,10020) @('was reached while waiting for a transaction response from the AppReadiness service','The machine wide Default Launch and Activation security descriptor is invalid') 'Full'"
        "UEXAVD_DiagMsgIssues 'Crash' 'Application' @(1000) @('Faulting application name') 'Full'"
        "UEXAVD_DiagMsgIssues 'Crash' 'System' @(41,6008) @('The system rebooted without cleanly shutting down first','was unexpected') 'Full'"
        "UEXAVD_DiagMsgIssues 'ProcessHang' 'Application' @(1002) @('stopped interacting with Windows') 'Full'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$False -ShowError:$True

#endregion Checking for issues in event logs

#region Checking for presence of Citrix products
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running Citrix products check"
    " " | Out-File -Append $diagfile

    $CitrixProd = (Get-ItemProperty  hklm:\software\microsoft\windows\currentversion\uninstall\* | Where-Object {($_.DisplayName -like "*Citrix*")})
    $CitrixProd2 = (Get-ItemProperty  hklm:\software\wow6432node\microsoft\windows\currentversion\uninstall\* | Where-Object {($_.DisplayName -like "*Citrix*")})
    
    if ($CitrixProd) {
        foreach ($cprod in $CitrixProd) {
            if ($cprod.DisplayVersion) { $cprodDisplayVersion = $cprod.DisplayVersion } else { $cprodDisplayVersion = "N/A" }
            if ($cprod.InstallDate) { $cprodInstallDate = $cprod.InstallDate } else { $cprodInstallDate = "N/A" }
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... " + $cprod.DisplayName + " - Version: " + $cprodDisplayVersion + " (Installed on: " + $cprodInstallDate + ")")
            
            if (($CitrixProd -like "*Citrix Virtual Apps and Desktops*") -and (($cprodDisplayVersion -eq "1912.0.4000.4227") -or ($cprodDisplayVersion -like "2109.*") -or ($cprodDisplayVersion -like "2112.*"))) {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] An older Citrix Virtual Apps and Desktops version has been found. Please consider updating. You could be running into issues described in: https://support.citrix.com/article/CTX338807")
            }
        }
    } elseif ($CitrixProd2) {
        foreach ($cprod2 in $CitrixProd2) {
            if ($cprod2.DisplayVersion) { $cprod2DisplayVersion = $cprod2.DisplayVersion } else { $cprod2DisplayVersion = "N/A" }
            if ($cprod2.InstallDate) { $cprod2InstallDate = $cprod2.InstallDate } else { $cprod2InstallDate = "N/A" }
            UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... " + $cprod2.DisplayName + " - Version: " + $cprod2DisplayVersion + " (Installed on: " + $cprod2InstallDate + ")")

            if (($CitrixProd2 -like "*Citrix Virtual Apps and Desktops*") -and (($cprod2DisplayVersion -eq "1912.0.4000.4227") -or ($cprod2DisplayVersion -like "2109.*") -or ($cprod2DisplayVersion -like "2112.*"))) {
                UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... [WARNING] An older Citrix Virtual Apps and Desktops version has been found. Please consider updating. You could be running into issues described in: https://support.citrix.com/article/CTX338807")
            }
        }
    }
    else {
        UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Citrix products not found")
    }

#endregion Checking for presence of Citrix products


#region Checking for presence of relevant 3rd party components
    "`n======================================================================`n" | Out-File -Append $diagfile

    UEXAVD_LogDiag $LogLevel.Normal "Running other potentially relevant 3rd party products check"
    " " | Out-File -Append $diagfile
    UEXAVD_LogDiag $LogLevel.DiagFileOnly ("... Running on this system at the time of this diagnostic:")

    UEXAVD_ProcessCheck "ZSAService" "ZScaler"
    UEXAVD_ProcessCheck "DefendpointService" "BeyondTrust"
    UEXAVD_ProcessCheck "vpnagent" "Cisco"
    UEXAVD_ProcessCheck "mcshield" "McAfee"
    UEXAVD_ProcessCheck "SavService" "Sophos"
    UEXAVD_ProcessCheck "wssad" "Symantec"
    UEXAVD_ProcessCheck "NVDisplay.Container" "NVIDIA"
    UEXAVD_ProcessCheck "sgpm" "Forcepoint"
    UEXAVD_ProcessCheck "GpVpnApp" "Palo Alto"
    UEXAVD_ProcessCheck "WebCompanion" "Adaware"

#endregion Checking for presence of relevant 3rd party components


    " " | Out-File -Append $diagfile

    #Generating AVD-Diag to HTML file
    $SourceFile = ($BasicLogFolder + "AVD-Diag.txt")
    $TargetFile = ($BasicLogFolder + "AVD-Diag.html")
    $Title = "AVD-Diag : " + $env:computername

    $agentissuefile = $env:computername + "_AVD-Diag-AgentIssuesEvents.txt"
    $msixaaissuefile = $env:computername + "_AVD-Diag-MSIXAAIssuesEvents.txt"
    $fslogixissuefile = $env:computername + "_AVD-Diag-FSLogixIssuesEvents.txt"
    $crashissuefile = $env:computername + "_AVD-Diag-CrashEvents.txt"
    $hangissuefile = $env:computername + "_AVD-Diag-ProcessHangEvents.txt"
    $blackscreenissuefile = $env:computername + "_AVD-Diag-PotentialBlackScreenEvents.txt"
    $shortpathissuefile = $env:computername + "_AVD-Diag-ShortpathIssuesEvents.txt"
    $tcpissuefile = $env:computername + "_AVD-Diag-TCPIssuesEvents.txt"
    $toolerrorfile = $env:computername + "_AVD-Collect-Error.txt"

    $warncount = -split (Get-Content $SourceFile | Out-String) | Where-Object { $_ -eq "[WARNING]" } | Measure-Object | Select-Object -exp count
    if ($warncount -gt 1) {
        $warncountmsg = "$warncount warnings have been found! Some warnings may be safely ignored if you are deliberately not using the corresponding options/components. Always place the results into the right troubleshooting context."
    } elseif ($warncount -eq 1) {
        $warncountmsg = "$warncount warning has been found! Some warnings may be safely ignored if you are deliberately not using the corresponding options/components. Always place the results into the right troubleshooting context."
    } else {
        $warncountmsg = "No warnings have been found."
    }

    $File = Get-Content $SourceFile
    $FileLine = @()
    Foreach ($Line in $File) {
        $MyObject = New-Object -TypeName PSObject
        Add-Member -InputObject $MyObject -Type NoteProperty -Name "AVD CSS Diagnostics" -Value $Line
        $FileLine += $MyObject
    }

    $FileLine | ConvertTo-Html -Title $Title -body $bodyDiag -Property "AVD CSS Diagnostics" -PostContent "<h5><i>Report run $(Get-Date) - Script version $version (Get the latest version from https://aka.ms/avd-collect) </i></h5>" | ForEach-Object {

        $PSItem -replace "AVD CSS Diagnostics","<a name='TopDiag'></a><br>AVD CSS Diagnostics<br><br>" `
        -replace "Geneva url extractor was not able to run","[WARNING] Geneva url extractor was not able to run" `
        -replace "WARNING","<span style='background-color: #FFFF00'>WARNING</span>" `
        -replace "Skipping check","<span style='color: brown'>Skipping check</span>" `
        -replace "not found","<span style='color: brown'>not found</span>" `
        -replace "is in Running state","is in <span style='color: green'>Running</span> state" `
        -replace "is in Stopped state","is in <span style='color: blue'>Stopped</span> state" `
        -replace "is in Disabled state","is in <span style='background-color: #FFFF00'>Disabled</span> state" `
        -replace "NOT Accessible URLs:","<span style='background-color: #FFFF00'>[WARNING] NOT Accessible URLs:</span>" `
        -replace "======================================================================","<p style='font-size:small;text-align:right'>^<a href='#TopDiag'>top</a> </p><hr><br>" `
        -replace "https://docs.microsoft.com/en-us/fslogix/configure-cloud-cache-tutorial#configure-cloud-cache-for-smb", "<a href='https://docs.microsoft.com/en-us/fslogix/configure-cloud-cache-tutorial#configure-cloud-cache-for-smb' target='_blank'>Configure Cloud Cache for SMB</a>" `
        -replace "https://docs.microsoft.com/en-us/azure/architecture/example-scenario/wvd/windows-virtual-desktop-fslogix#antivirus-exclusions","<a href='https://docs.microsoft.com/en-us/azure/architecture/example-scenario/wvd/windows-virtual-desktop-fslogix#antivirus-exclusions' target='_blank'>Antivirus exclusions</a>" `
        -replace "https://support.microsoft.com/en-us/help/4490481","<a href='https://support.microsoft.com/en-us/help/4490481' target='_blank'>https://support.microsoft.com/en-us/help/4490481</a>" `
        -replace "https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/virtual-machine-recs#recommended-vm-sizes-for-standard-or-larger-environments","<a href='https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/virtual-machine-recs#recommended-vm-sizes-for-standard-or-larger-environments' target='_blank'>Recommended VM sizes for standard or larger environments</a>" `
        -replace "https://docs.microsoft.com/en-us/azure/virtual-desktop/teams-on-AVD#install-the-teams-websocket-service","<a href='https://docs.microsoft.com/en-us/azure/virtual-desktop/teams-on-AVD#install-the-teams-websocket-service' target='_blank'>Install the Teams WebSocket Service</a>" `
        -replace "https://docs.microsoft.com/en-us/azure/virtual-desktop/prerequisites#operating-systems-and-licenses", "<a href='https://docs.microsoft.com/en-us/azure/virtual-desktop/prerequisites#operating-systems-and-licenses' target='_blank'>Supported virtual machine OS images</a>" `
        -replace "https://docs.microsoft.com/en-us/azure/virtual-desktop/configure-vm-gpu", "<a href='https://docs.microsoft.com/en-us/azure/virtual-desktop/configure-vm-gpu' target='_blank'>Configure graphics processing unit (GPU) acceleration for Azure Virtual Desktop</a>" `
        -replace "https://docs.microsoft.com/en-us/azure/virtual-desktop/proxy-server-support", "<a href='https://docs.microsoft.com/en-us/azure/virtual-desktop/proxy-server-support' target='_blank'>Proxy server guidelines for Azure Virtual Desktop</a>" `
        -replace "https://docs.microsoft.com/en-us/fslogix/whats-new", "<a href='https://docs.microsoft.com/en-us/fslogix/whats-new' target='_blank'>What's new in FSLogix</a>" `
        -replace "Running deployment check","<a name='DeploymentCheck'></a><b>Deployment</b>" `
        -replace "Running device and resource redirection policy configuration check","<a name='Redirection'></a><b>Device and resource redirection policy configuration</b>" `
        -replace "Running graphics configuration check","<a name='GPUCheck'></a><b>Graphics configuration</b>" `
        -replace "Running Disk space check","<a name='DiskCheck'></a><b>Disk space</b>" `
        -replace "Running CPU utilization check","<a name='CPUCheck'></a><b>CPU utilization</b>" `
        -replace "Running domain secure channel connection check","<a name='SecChanCheck'></a><b>Domain secure channel connection</b>" `
        -replace "Running public IP information check","<a name='PublicIPCheck'></a><b>Public IP information</b>" `
        -replace "Running Azure AD Join configuration check","<a name='AADJCheck'></a><b>Azure AD Join configuration</b>" `
        -replace "Running AVD services URI health status check","<a name='BrokerURICheck'></a><b>AVD services URI health status</b>" `
        -replace "Running key system services status check","<a name='ServicesCheck'></a><b>Status of key system services</b>" `
        -replace "Running Windows Update configuration check","<a name='WUCheck'></a><b>Windows Update configuration</b>" `
        -replace "Running other potentially relevant 3rd party products check","<a name='3pCheck'></a><b>Other potentially relevant 3rd party products</b>" `
        -replace "Running Citrix products check","<a name='CitrixCheck'></a><b>Installed Citrix products</b>" `
        -replace "Running User Account Control configuration check","<a name='UACCheck'></a><b>User Account Control configuration</b>" `
        -replace "Running AVD Agent and SxS Stack information check","<a name='AgentStackInfoCheck'></a><b>AVD Agent and SxS Stack information</b>" `
        -replace "Running RDP and Remote Desktop Listener configuration check","<a name='ListenerCheck'></a><b>RDP and Remote Desktop Listener configuration</b>" `
        -replace "Running issue events check over the past 5 days - this may take longer","<a name='IssuesCheck'></a><b>Issue events over the past 5 days</b>" `
        -replace "Running proxy and route configuration check","<a name='ProxyCheck'></a><b>Proxy and route configuration</b>" `
        -replace "Running DNS configuration check","<a name='DNSCheck'></a><b>DNS configuration</b>" `
        -replace "Running Firewall configuration check","<a name='FWCheck'></a><b>Firewall configuration</b>" `
        -replace "Running Domain Controller information check","<a name='DCCheck'></a><b>Domain Controller informantion</b>" `
        -replace "Running SSL and TLS configuration check","<a name='SSLCheck'></a><b>SSL and TLS configuration</b>" `
        -replace "Running AVD host required URLs access check","<a name='URLCheck'></a><b>AVD host required URLs access</b>" `
        -replace "Running Session Time Limit configuration check","<a name='STLCheck'></a><b>Session Time Limit configuration</b>" `
        -replace "Running RDP Shortpath check","<a name='UDPCheck'></a><b>RDP Shortpath configuration</b>" `
        -replace "Running WinRM configuration check","<a name='WinRMCheck'></a><b>WinRM configuration</b>" `
        -replace "Running AVD Remote Desktop clients check", "<a name='RDCCheck'></a><b>AVD Remote Desktop clients</b>" `
        -replace "Running Licensing configuration check", "<a name='LicCheck'></a><b>Licensing configuration</b>" `
        -replace "Running User Rights policy configuration check", "<a name='URCheck'></a><b>User Rights policy configuration</b>" `
        -replace "Running FSLogix configuration check", "<a name='FSLogixCheck'></a><b>FSLogix configuration</b>" `
        -replace "Running check for settings sometimes related to Black Screen logon scenarios","<a name='BlackCheck'></a><b>Settings sometimes related to Black Screen logon scenarios</b>" `
        -replace "Running Antivirus software check","<a name='AntivirusCheck'></a><b>Antivirus software</b>" `
        -replace "Running recommended FSLogix Windows Defender Exclusions check","<a name='DefenderCheck'></a><b>Recommended Windows Defender Exclusions for FSLogix</b>" `
        -replace "Running recommended Server OS Windows Defender configuration check","<b>Recommended Windows Defender configuration for Server OS</b>" `
        -replace "Running Microsoft Office configuration check","<a name='OfficeCheck'></a><b>Microsoft Office configuration</b>" `
        -replace "Running OneDrive configuration check","<a name='ODCheck'></a><b>OneDrive configuration</b>" `
        -replace "Running Teams media optimization configuration check","<a name='TeamsCheck'></a><b>Media optimization configuration for Teams</b>" `
        -replace "Running PowerShell configuration check","<a name='PSCheck'></a><b>PowerShell configuration</b>" `
        -replace "Running multimedia configuration check","<a name='MultimediaCheck'></a><b>Multimedia configuration</b>" `
        -replace "Running print settings check","<a name='PrintCheck'></a><b>Print settings</b>" `
        -replace "Running Screen Capture Protection configuration check","<a name='SCPCheck'></a><b>Screen Capture Protection configuration</b>" `
        -replace "exists and has a value of","exists and has a <span style='color: blue'>value</span> of" `
        -replace "exists and has the expected value of: ","exists and has the <span style='color: green'>expected value</span> of: " `
        -replace "of: Allow","of: <span style='color: green'>Allow</span>" `
        -replace "of: Deny","of: <span style='color: red'>Deny</span>" `
        -replace "local config","<span style='color: blue'>local config</span>" `
        -replace "GPO config","<span style='color: blue'>GPO config</span>" `
        -replace "No differences found.","of: <span style='color: green'>No differences found.</span>" `
        -replace "VHDLocations","<span style='color: blue'>VHDLocations</span>" `
        -replace "not enabled","<span style='color: brown'>not enabled</span>" `
        -replace "OK - 200","<span style='color: green'>OK - 200</span>" `
        -replace ": True",": <span style='color: green'>True</span>" `
        -replace ": False",": <span style='color: red'>False</span>" `
        -replace "and analysis may be required.","and analysis may be required.<br><p style='font-size:small;text-align:center'>`
        <table><tr><td>System</td><td><a href='#DeploymentCheck'>Deployment</a> | <a href='#ServicesCheck'>Services</a> | <a href='#WUCheck'>Windows Update</a> | <a href='#GPUCheck'>Graphics</a> | <a href='#CPUCheck'>CPU</a> | <a href='#DiskCheck'>Disk</a> | <a href='#SSLCheck'>SSL/TLS</a> | <a href='#PSCheck'>PowerShell</a> | <a href='#WinRMCheck'>WinRM</a> | <a href='#UACCheck'>UAC</a></td></tr>`
        <tr><td>Infra & Network</td><td><a href='#AgentStackInfoCheck'>Agent/Stack</a> | <a href='#BrokerURICheck'>Services URI Health</a> | <a href='#URLCheck'>Required URLs</a> | <a href='#PublicIPCheck'>Public IP</a> | <a href='#ProxyCheck'>Proxy/Route</a> | <a href='#FWCheck'>Firewall</a> | <a href='#DNSCheck'>DNS</a> | <a href='#DNSCheck'>Domain Controller</a> | <a href='#SecChanCheck'>Secure Channel</a> | <a href='#AADJCheck'>Azure AD Join</a> | <a href='#UDPCheck'>RDP Shortpath</a></td></tr>`
        <tr><td>AVD/RDS</td><td><a href='#ListenerCheck'>RD Listener</a> | <a href='#RDCCheck'>RD Client</a> | <a href='#STLCheck'>Session Time Limit</a> | <a href='#Redirection'>Redirection</a> | <a href='#SCPCheck'>Screen Capture Protection</a> | <a href='#LicCheck'>Licensing</a> | <a href='#URCheck'>User Rights</a></td></tr>`
        <tr><td>Extra</td><td><a href='#FSLogixCheck'>FSLogix</a> | <a href='#AntivirusCheck'>Antivirus</a> | <a href='#DefenderCheck'>Defender</a> | <a href='#OfficeCheck'>Office</a> | <a href='#ODCheck'>OneDrive</a> | <a href='#TeamsCheck'>Teams Media Optimization</a> | <a href='#MultimediaCheck'>Multimedia</a> | <a href='#PrintCheck'>Printing</a> | <a href='#BlackCheck'>Black Screen</a> | <a href='#IssuesCheck'>Issue Events</a></td></tr>`
        <tr><td>3rd Party</td><td><a href='#CitrixCheck'>Citrix</a> | <a href='#3pCheck'>Other</a></td></tr></table><br><span style='color: red'><b>$warncountmsg</b></span></p>" `
        -replace "https://support.microsoft.com/en-us/help/4000825", "<a href='https://support.microsoft.com/en-us/help/4000825' target='_blank'>https://support.microsoft.com/en-us/help/4000825</a>" `
        -replace "https://support.microsoft.com/en-us/help/4464619", "<a href='https://support.microsoft.com/en-us/help/4464619' target='_blank'>https://support.microsoft.com/en-us/help/4464619</a>" `
        -replace "https://support.microsoft.com/en-us/help/4529964", "<a href='https://support.microsoft.com/en-us/help/4529964' target='_blank'>https://support.microsoft.com/en-us/help/4529964</a>" `
        -replace "https://support.microsoft.com/en-us/help/4581839", "<a href='https://support.microsoft.com/en-us/help/4581839' target='_blank'>https://support.microsoft.com/en-us/help/4581839</a>" `
        -replace "https://support.microsoft.com/en-us/help/5003498", "<a href='https://support.microsoft.com/en-us/help/5003498' target='_blank'>https://support.microsoft.com/en-us/help/5003498</a>" `
        -replace "https://support.microsoft.com/en-us/help/5008339", "<a href='https://support.microsoft.com/en-us/help/5008339' target='_blank'>https://support.microsoft.com/en-us/help/5008339</a>" `
        -replace "https://support.microsoft.com/en-us/help/5005454", "<a href='https://support.microsoft.com/en-us/help/5005454' target='_blank'>https://support.microsoft.com/en-us/help/5005454</a>" `
        -replace "https://support.microsoft.com/en-us/help/5006099", "<a href='https://support.microsoft.com/en-us/help/5006099' target='_blank'>https://support.microsoft.com/en-us/help/5006099</a>" `
        -replace "https://support.microsoft.com/en-us/help/4009469", "<a href='https://support.microsoft.com/en-us/help/4009469' target='_blank'>https://support.microsoft.com/en-us/help/4009469</a>" `
        -replace "https://docs.microsoft.com/en-us/lifecycle/products/windows-10-enterprise-and-education", "<a href='https://docs.microsoft.com/en-us/lifecycle/products/windows-10-enterprise-and-education' target='_blank'>Windows 10 Enterprise and Education</a>" `
        -replace "https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/security-malware-windows-defender-disableantispyware", "<a href='https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/security-malware-windows-defender-disableantispyware' target='_blank'>DisableAntiSpyware</a>" `
        -replace "https://aka.ms/avd-collect", "<a href='https://aka.ms/avd-collect' target='_blank'>https://aka.ms/avd-collect</a>" `
        -replace "https://docs.microsoft.com/en-us/azure/virtual-desktop/troubleshoot-agent", "<a href='https://docs.microsoft.com/en-us/azure/virtual-desktop/troubleshoot-agent' target='_blank'>https://docs.microsoft.com/en-us/azure/virtual-desktop/troubleshoot-agent</a>" `
        -replace "https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/clients/windowsdesktop-whatsnew", "<a href='https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/clients/windowsdesktop-whatsnew' target='_blank'>What's new in the Windows Desktop client</a>" `
        -replace "https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/clients/windows-whatsnew", "<a href='https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/clients/windows-whatsnew' target='_blank'>What's new in the Microsoft Store client</a>" `
        -replace "https://docs.microsoft.com/en-us/azure/virtual-desktop/apply-windows-license", "<a href='https://docs.microsoft.com/en-us/azure/virtual-desktop/apply-windows-license' target='_blank'>Apply Windows license to session host virtual machines</a>" `
        -replace "AVD-Diag-AgentIssuesEvents.txt", "<span style='font-weight: bold'><a href='$agentissuefile' target='_blank'>AVD-Diag-AgentIssuesEvents.txt</a></span>" `
        -replace "AVD-Diag-MSIXAAIssuesEvents.txt", "<span style='font-weight: bold'><a href='$msixaaissuefile' target='_blank'>AVD-Diag-MSIXAAIssuesEvents.txt</a></span>" `
        -replace "AVD-Diag-FSLogixIssuesEvents.txt", "<span style='font-weight: bold'><a href='$fslogixissuefile' target='_blank'>AVD-Diag-FSLogixIssuesEvents.txt</a></span>" `
        -replace "AVD-Diag-CrashEvents.txt", "<span style='font-weight: bold'><a href='$crashissuefile' target='_blank'>AVD-Diag-CrashEvents.txt</a></span>" `
        -replace "AVD-Diag-ProcessHangEvents.txt", "<span style='font-weight: bold'><a href='$hangissuefile' target='_blank'>AVD-Diag-ProcessHangEvents.txt</a></span>" `
        -replace "AVD-Diag-PotentialBlackScreenEvents.txt", "<span style='font-weight: bold'><a href='$blackscreenissuefile' target='_blank'>AVD-Diag-PotentialBlackScreenEvents.txt</a></span>" `
        -replace "AVD-Diag-ShortpathIssuesEvents.txt", "<span style='font-weight: bold'><a href='$shortpathissuefile' target='_blank'>AVD-Diag-ShortpathIssuesEvents.txt</a></span>" `
        -replace "AVD-Diag-TCPIssuesEvents.txt", "<span style='font-weight: bold'><a href='$tcpissuefile' target='_blank'>AVD-Diag-TCPIssuesEvents.txt</a></span>" `
        -replace "AVD-Collect-Error.txt", "<span style='font-weight: bold'><a href='$toolerrorfile' target='_blank'>AVD-Collect-Error.txt</a></span>" `
        -replace "FirewallRules.txt", "<span style='font-weight: bold'><a href='$fwrfile' target='_blank'>FirewallRules.txt</a></span>"
       } | Out-File $TargetFile
}

Export-ModuleMember -Function RunUEX_AVDDiag
# SIG # Begin signature block
# MIIntwYJKoZIhvcNAQcCoIInqDCCJ6QCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCklHDa3uZVoQDo
# 3W6tw82W6jQ7HfBtDietofO3EndGy6CCDYEwggX/MIID56ADAgECAhMzAAACUosz
# qviV8znbAAAAAAJSMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjEwOTAyMTgzMjU5WhcNMjIwOTAxMTgzMjU5WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDQ5M+Ps/X7BNuv5B/0I6uoDwj0NJOo1KrVQqO7ggRXccklyTrWL4xMShjIou2I
# sbYnF67wXzVAq5Om4oe+LfzSDOzjcb6ms00gBo0OQaqwQ1BijyJ7NvDf80I1fW9O
# L76Kt0Wpc2zrGhzcHdb7upPrvxvSNNUvxK3sgw7YTt31410vpEp8yfBEl/hd8ZzA
# v47DCgJ5j1zm295s1RVZHNp6MoiQFVOECm4AwK2l28i+YER1JO4IplTH44uvzX9o
# RnJHaMvWzZEpozPy4jNO2DDqbcNs4zh7AWMhE1PWFVA+CHI/En5nASvCvLmuR/t8
# q4bc8XR8QIZJQSp+2U6m2ldNAgMBAAGjggF+MIIBejAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUNZJaEUGL2Guwt7ZOAu4efEYXedEw
# UAYDVR0RBEkwR6RFMEMxKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1
# ZXJ0byBSaWNvMRYwFAYDVQQFEw0yMzAwMTIrNDY3NTk3MB8GA1UdIwQYMBaAFEhu
# ZOVQBdOCqhc3NyK1bajKdQKVMFQGA1UdHwRNMEswSaBHoEWGQ2h0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY0NvZFNpZ1BDQTIwMTFfMjAxMS0w
# Ny0wOC5jcmwwYQYIKwYBBQUHAQEEVTBTMFEGCCsGAQUFBzAChkVodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY0NvZFNpZ1BDQTIwMTFfMjAx
# MS0wNy0wOC5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAFkk3
# uSxkTEBh1NtAl7BivIEsAWdgX1qZ+EdZMYbQKasY6IhSLXRMxF1B3OKdR9K/kccp
# kvNcGl8D7YyYS4mhCUMBR+VLrg3f8PUj38A9V5aiY2/Jok7WZFOAmjPRNNGnyeg7
# l0lTiThFqE+2aOs6+heegqAdelGgNJKRHLWRuhGKuLIw5lkgx9Ky+QvZrn/Ddi8u
# TIgWKp+MGG8xY6PBvvjgt9jQShlnPrZ3UY8Bvwy6rynhXBaV0V0TTL0gEx7eh/K1
# o8Miaru6s/7FyqOLeUS4vTHh9TgBL5DtxCYurXbSBVtL1Fj44+Od/6cmC9mmvrti
# yG709Y3Rd3YdJj2f3GJq7Y7KdWq0QYhatKhBeg4fxjhg0yut2g6aM1mxjNPrE48z
# 6HWCNGu9gMK5ZudldRw4a45Z06Aoktof0CqOyTErvq0YjoE4Xpa0+87T/PVUXNqf
# 7Y+qSU7+9LtLQuMYR4w3cSPjuNusvLf9gBnch5RqM7kaDtYWDgLyB42EfsxeMqwK
# WwA+TVi0HrWRqfSx2olbE56hJcEkMjOSKz3sRuupFCX3UroyYf52L+2iVTrda8XW
# esPG62Mnn3T8AuLfzeJFuAbfOSERx7IFZO92UPoXE1uEjL5skl1yTZB3MubgOA4F
# 8KoRNhviFAEST+nG8c8uIsbZeb08SeYQMqjVEmkwggd6MIIFYqADAgECAgphDpDS
# AAAAAAADMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0
# ZSBBdXRob3JpdHkgMjAxMTAeFw0xMTA3MDgyMDU5MDlaFw0yNjA3MDgyMTA5MDla
# MH4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMT
# H01pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTEwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCr8PpyEBwurdhuqoIQTTS68rZYIZ9CGypr6VpQqrgG
# OBoESbp/wwwe3TdrxhLYC/A4wpkGsMg51QEUMULTiQ15ZId+lGAkbK+eSZzpaF7S
# 35tTsgosw6/ZqSuuegmv15ZZymAaBelmdugyUiYSL+erCFDPs0S3XdjELgN1q2jz
# y23zOlyhFvRGuuA4ZKxuZDV4pqBjDy3TQJP4494HDdVceaVJKecNvqATd76UPe/7
# 4ytaEB9NViiienLgEjq3SV7Y7e1DkYPZe7J7hhvZPrGMXeiJT4Qa8qEvWeSQOy2u
# M1jFtz7+MtOzAz2xsq+SOH7SnYAs9U5WkSE1JcM5bmR/U7qcD60ZI4TL9LoDho33
# X/DQUr+MlIe8wCF0JV8YKLbMJyg4JZg5SjbPfLGSrhwjp6lm7GEfauEoSZ1fiOIl
# XdMhSz5SxLVXPyQD8NF6Wy/VI+NwXQ9RRnez+ADhvKwCgl/bwBWzvRvUVUvnOaEP
# 6SNJvBi4RHxF5MHDcnrgcuck379GmcXvwhxX24ON7E1JMKerjt/sW5+v/N2wZuLB
# l4F77dbtS+dJKacTKKanfWeA5opieF+yL4TXV5xcv3coKPHtbcMojyyPQDdPweGF
# RInECUzF1KVDL3SV9274eCBYLBNdYJWaPk8zhNqwiBfenk70lrC8RqBsmNLg1oiM
# CwIDAQABo4IB7TCCAekwEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFEhuZOVQ
# BdOCqhc3NyK1bajKdQKVMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1Ud
# DwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFHItOgIxkEO5FAVO
# 4eqnxzHRI4k0MFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwubWljcm9zb2Z0
# LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcmwwXgYIKwYBBQUHAQEEUjBQME4GCCsGAQUFBzAChkJodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcnQwgZ8GA1UdIASBlzCBlDCBkQYJKwYBBAGCNy4DMIGDMD8GCCsGAQUFBwIB
# FjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2RvY3MvcHJpbWFyeWNw
# cy5odG0wQAYIKwYBBQUHAgIwNB4yIB0ATABlAGcAYQBsAF8AcABvAGwAaQBjAHkA
# XwBzAHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJKoZIhvcNAQELBQADggIBAGfyhqWY
# 4FR5Gi7T2HRnIpsLlhHhY5KZQpZ90nkMkMFlXy4sPvjDctFtg/6+P+gKyju/R6mj
# 82nbY78iNaWXXWWEkH2LRlBV2AySfNIaSxzzPEKLUtCw/WvjPgcuKZvmPRul1LUd
# d5Q54ulkyUQ9eHoj8xN9ppB0g430yyYCRirCihC7pKkFDJvtaPpoLpWgKj8qa1hJ
# Yx8JaW5amJbkg/TAj/NGK978O9C9Ne9uJa7lryft0N3zDq+ZKJeYTQ49C/IIidYf
# wzIY4vDFLc5bnrRJOQrGCsLGra7lstnbFYhRRVg4MnEnGn+x9Cf43iw6IGmYslmJ
# aG5vp7d0w0AFBqYBKig+gj8TTWYLwLNN9eGPfxxvFX1Fp3blQCplo8NdUmKGwx1j
# NpeG39rz+PIWoZon4c2ll9DuXWNB41sHnIc+BncG0QaxdR8UvmFhtfDcxhsEvt9B
# xw4o7t5lL+yX9qFcltgA1qFGvVnzl6UJS0gQmYAf0AApxbGbpT9Fdx41xtKiop96
# eiL6SJUfq/tHI4D1nvi/a7dLl+LrdXga7Oo3mXkYS//WsyNodeav+vyL6wuA6mk7
# r/ww7QRMjt/fdW1jkT3RnVZOT7+AVyKheBEyIXrvQQqxP/uozKRdwaGIm1dxVk5I
# RcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIZjDCCGYgCAQEwgZUwfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAlKLM6r4lfM52wAAAAACUjAN
# BglghkgBZQMEAgEFAKCBrjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgz3A9W9BR
# oIIq6PCZKe0IyhDJoExnD7SA8BWo7Tcfm+8wQgYKKwYBBAGCNwIBDDE0MDKgFIAS
# AE0AaQBjAHIAbwBzAG8AZgB0oRqAGGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbTAN
# BgkqhkiG9w0BAQEFAASCAQABRmISAwqX1X+dYGIBplMxAUj7Uu/6iV4emANULevm
# bsK/kyC2W4GTsxyC4Hu2bAIzRz9qqCtddUVAuzGYEAKJyRlvxQ6ABvFa5EaJcazY
# g/ouN/PRsoTniEZ6E1h3HP8KWlpq+WGb0lbIVQQR2EBMOh9Miu/MGDQvCexTdgnw
# dGJ/pgwp1ToBYnXDKhilYY+aTIa85FKM+oeqvZo2pyv7jpJC3o0rCS15yurPy20H
# nw3xSqPzCt3QjU+SNqnuAgiayVB0q9RL8nKoovbCUNL7lh1Uy2dqGA2s1gEolHKE
# tx4jAHg6oSFOnqFFIJriVyy8PlEN13SQTgiHQ5USCMOAoYIXFjCCFxIGCisGAQQB
# gjcDAwExghcCMIIW/gYJKoZIhvcNAQcCoIIW7zCCFusCAQMxDzANBglghkgBZQME
# AgEFADCCAVkGCyqGSIb3DQEJEAEEoIIBSASCAUQwggFAAgEBBgorBgEEAYRZCgMB
# MDEwDQYJYIZIAWUDBAIBBQAEII+Esn5EHwE0vj817dxQXKkjwUoyCMhHktHe0M3d
# RKEvAgZics8gdxIYEzIwMjIwNTE5MDUzODQzLjU3N1owBIACAfSggdikgdUwgdIx
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1p
# Y3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEmMCQGA1UECxMdVGhh
# bGVzIFRTUyBFU046RDA4Mi00QkZELUVFQkExJTAjBgNVBAMTHE1pY3Jvc29mdCBU
# aW1lLVN0YW1wIFNlcnZpY2WgghFlMIIHFDCCBPygAwIBAgITMwAAAY/zUajrWnLd
# zAABAAABjzANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0Eg
# MjAxMDAeFw0yMTEwMjgxOTI3NDZaFw0yMzAxMjYxOTI3NDZaMIHSMQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQg
# SXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxlcyBUU1Mg
# RVNOOkQwODItNEJGRC1FRUJBMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFt
# cCBTZXJ2aWNlMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAmVc+/rXP
# Fx6Fk4+CpLrubDrLTa3QuAHRVXuy+zsxXwkogkT0a+XWuBabwHyqj8RRiZQQvdvb
# Oq5NRExOeHiaCtkUsQ02ESAe9Cz+loBNtsfCq846u3otWHCJlqkvDrSr7mMBqwcR
# Y7cfhAGfLvlpMSojoAnk7Rej+jcJnYxIeN34F3h9JwANY360oGYCIS7pLOosWV+b
# xug9uiTZYE/XclyYNF6XdzZ/zD/4U5pxT4MZQmzBGvDs+8cDdA/stZfj/ry+i0XU
# YNFPhuqc+UKkwm/XNHB+CDsGQl+ZS0GcbUUun4VPThHJm6mRAwL5y8zptWEIocbT
# eRSTmZnUa2iYH2EOBV7eCjx0Sdb6kLc1xdFRckDeQGR4J1yFyybuZsUP8x0dOsEE
# oLQuOhuKlDLQEg7D6ZxmZJnS8B03ewk/SpVLqsb66U2qyF4BwDt1uZkjEZ7finIo
# UgSz4B7fWLYIeO2OCYxIE0XvwsVop9PvTXTZtGPzzmHU753GarKyuM6oa/qaTzYv
# rAfUb7KYhvVQKxGUPkL9+eKiM7G0qenJCFrXzZPwRWoccAR33PhNEuuzzKZFJ4De
# aTCLg/8uK0Q4QjFRef5n4H+2KQIEibZ7zIeBX3jgsrICbzzSm0QX3SRVmZH//Aqp
# 8YxkwcoI1WCBizv84z9eqwRBdQ4HYcNbQMMCAwEAAaOCATYwggEyMB0GA1UdDgQW
# BBTzBuZ0a65JzuKhzoWb25f7NyNxvDAfBgNVHSMEGDAWgBSfpxVdAF5iXYP05dJl
# pxtTNRnpcjBfBgNVHR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIwMjAx
# MCgxKS5jcmwwbAYIKwYBBQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRpbWUtU3Rh
# bXAlMjBQQ0ElMjAyMDEwKDEpLmNydDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoG
# CCsGAQUFBwMIMA0GCSqGSIb3DQEBCwUAA4ICAQDNf9Oo9zyhC5n1jC8iU7NJY39F
# izjhxZwJbJY/Ytwn63plMlTSaBperan566fuRojGJSv3EwZs+RruOU2T/ZRDx4VH
# esLHtclE8GmMM1qTMaZPL8I2FrRmf5Oop4GqcxNdNECBClVZmn0KzFdPMqRa5/0R
# 6CmgqJh0muvImikgHubvohsavPEyyHQa94HD4/LNKd/YIaCKKPz9SA5fAa4phQ4E
# vz2auY9SUluId5MK9H5cjWVwBxCvYAD+1CW9z7GshJlNjqBvWtKO6J0Aemfg6z28
# g7qc7G/tCtrlH4/y27y+stuwWXNvwdsSd1lvB4M63AuMl9Yp6au/XFknGzJPF6n/
# uWR6JhQvzh40ILgeThLmYhf8z+aDb4r2OBLG1P2B6aCTW2YQkt7TpUnzI0cKGr21
# 3CbKtGk/OOIHSsDOxasmeGJ+FiUJCiV15wh3aZT/VT/PkL9E4hDBAwGt49G88gSC
# O0x9jfdDZWdWGbELXlSmA3EP4eTYq7RrolY04G8fGtF0pzuZu43A29zaI9lIr5ul
# KRz8EoQHU6cu0PxUw0B9H8cAkvQxaMumRZ/4fCbqNb4TcPkPcWOI24QYlvpbtT9p
# 31flYElmc5wjGplAky/nkJcT0HZENXenxWtPvt4gcoqppeJPA3S/1D57KL3667ep
# Ir0yV290E2otZbAW8DCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUw
# DQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5n
# dG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhv
# cml0eSAyMDEwMB4XDTIxMDkzMDE4MjIyNVoXDTMwMDkzMDE4MzIyNVowfDELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAw
# ggIKAoICAQDk4aZM57RyIQt5osvXJHm9DtWC0/3unAcH0qlsTnXIyjVX9gF/bErg
# 4r25PhdgM/9cT8dm95VTcVrifkpa/rg2Z4VGIwy1jRPPdzLAEBjoYH1qUoNEt6aO
# RmsHFPPFdvWGUNzBRMhxXFExN6AKOG6N7dcP2CZTfDlhAnrEqv1yaa8dq6z2Nr41
# JmTamDu6GnszrYBbfowQHJ1S/rboYiXcag/PXfT+jlPP1uyFVk3v3byNpOORj7I5
# LFGc6XBpDco2LXCOMcg1KL3jtIckw+DJj361VI/c+gVVmG1oO5pGve2krnopN6zL
# 64NF50ZuyjLVwIYwXE8s4mKyzbnijYjklqwBSru+cakXW2dg3viSkR4dPf0gz3N9
# QZpGdc3EXzTdEonW/aUgfX782Z5F37ZyL9t9X4C626p+Nuw2TPYrbqgSUei/BQOj
# 0XOmTTd0lBw0gg/wEPK3Rxjtp+iZfD9M269ewvPV2HM9Q07BMzlMjgK8QmguEOqE
# UUbi0b1qGFphAXPKZ6Je1yh2AuIzGHLXpyDwwvoSCtdjbwzJNmSLW6CmgyFdXzB0
# kZSU2LlQ+QuJYfM2BjUYhEfb3BvR/bLUHMVr9lxSUV0S2yW6r1AFemzFER1y7435
# UsSFF5PAPBXbGjfHCBUYP3irRbb1Hode2o+eFnJpxq57t7c+auIurQIDAQABo4IB
# 3TCCAdkwEgYJKwYBBAGCNxUBBAUCAwEAATAjBgkrBgEEAYI3FQIEFgQUKqdS/mTE
# mr6CkTxGNSnPEP8vBO4wHQYDVR0OBBYEFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMFwG
# A1UdIARVMFMwUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93
# d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTATBgNV
# HSUEDDAKBggrBgEFBQcDCDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNV
# HQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo
# 0T2UkFvXzpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29m
# dC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5j
# cmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jv
# c29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNydDAN
# BgkqhkiG9w0BAQsFAAOCAgEAnVV9/Cqt4SwfZwExJFvhnnJL/Klv6lwUtj5OR2R4
# sQaTlz0xM7U518JxNj/aZGx80HU5bbsPMeTCj/ts0aGUGCLu6WZnOlNN3Zi6th54
# 2DYunKmCVgADsAW+iehp4LoJ7nvfam++Kctu2D9IdQHZGN5tggz1bSNU5HhTdSRX
# ud2f8449xvNo32X2pFaq95W2KFUn0CS9QKC/GbYSEhFdPSfgQJY4rPf5KYnDvBew
# VIVCs/wMnosZiefwC2qBwoEZQhlSdYo2wh3DYXMuLGt7bj8sCXgU6ZGyqVvfSaN0
# DLzskYDSPeZKPmY7T7uG+jIa2Zb0j/aRAfbOxnT99kxybxCrdTDFNLB62FD+Cljd
# QDzHVG2dY3RILLFORy3BFARxv2T5JL5zbcqOCb2zAVdJVGTZc9d/HltEAY5aGZFr
# DZ+kKNxnGSgkujhLmm77IVRrakURR6nxt67I6IleT53S0Ex2tVdUCbFpAUR+fKFh
# bHP+CrvsQWY9af3LwUFJfn6Tvsv4O+S3Fb+0zj6lMVGEvL8CwYKiexcdFYmNcP7n
# tdAoGokLjzbaukz5m/8K6TT4JDVnK+ANuOaMmdbhIurwJ0I9JZTmdHRbatGePu1+
# oDEzfbzL6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZqELQdVTNYs6Fw
# ZvKhggLUMIICPQIBATCCAQChgdikgdUwgdIxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJh
# dGlvbnMgTGltaXRlZDEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046RDA4Mi00QkZE
# LUVFQkExJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2WiIwoB
# ATAHBgUrDgMCGgMVAD5NL4IEdudIBwdGoCaV0WBbQZpqoIGDMIGApH4wfDELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9z
# b2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwDQYJKoZIhvcNAQEFBQACBQDmL8HgMCIY
# DzIwMjIwNTE5MDMwNTA0WhgPMjAyMjA1MjAwMzA1MDRaMHQwOgYKKwYBBAGEWQoE
# ATEsMCowCgIFAOYvweACAQAwBwIBAAICAyQwBwIBAAICEUAwCgIFAOYxE2ACAQAw
# NgYKKwYBBAGEWQoEAjEoMCYwDAYKKwYBBAGEWQoDAqAKMAgCAQACAwehIKEKMAgC
# AQACAwGGoDANBgkqhkiG9w0BAQUFAAOBgQCEqd/3fUbTFp6WUZitXPTSPLGXwaFs
# TBZR48hnPSPSxfDSLq39dYXtAELl9K1xYS2NqWt7YYGhNoZ1r4RDtKaiX6P8K8+n
# 6Fp1pWZe9Wbn8NtfrCKMXv46aQW/JfY8LsQV5ZmUVsUKWrG9kFmdF2LaP6xZbh/n
# wL08WOEXQvH5fDGCBA0wggQJAgEBMIGTMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBD
# QSAyMDEwAhMzAAABj/NRqOtact3MAAEAAAGPMA0GCWCGSAFlAwQCAQUAoIIBSjAa
# BgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJKoZIhvcNAQkEMSIEICidlIEA
# h2iHaqhliLHZ+ncIktn8yAGeElJmZc2vlK/bMIH6BgsqhkiG9w0BCRACLzGB6jCB
# 5zCB5DCBvQQgl3IFT+LGxguVjiKm22ItmO6dFDWW8nShu6O6g8yFxx8wgZgwgYCk
# fjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
# Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAY/zUajrWnLdzAAB
# AAABjzAiBCBOdp10xRSIZGk6Jkz0OTzv6OXDvf6pXcZ4Aa7Rr9VYXjANBgkqhkiG
# 9w0BAQsFAASCAgBp1KS6RzMcr3+d8pp6aUoPpkhZaMR+OKxEA0HNhv+w6+RU0eJj
# 8uiY9hPUtEqGyRX2+OIMrZWCo5PG0qa6zVbOgnK7z8uaXen+jfLszmVdPdD+HK89
# 2ex6MSkz9sQwHy94NFUNZ68ds89bHKPnz6jaJReI+8leVhYlU8TM6bidBOQJe5pZ
# yDK/Lzs+i+2jZeMxE9ofwNdwlPZRHxx37d+F0kQlTcs6Rl5zu7Q6yZnAZbEG+KyV
# OO0OFDc0LdbQa8tDk96jpNNNFive56utatZPFUEhCNGyW9lLoh7/1ry1Ys/wOagr
# x371T3qgeQfecpwWJ1sKLTEgcMyLGyjsG91kbD7U2qAIinO+t8RTzj9HeIrPP0g6
# Ju+mMVo0x9U0SDk3y7cXWGGGHZzgOR8FPyq+y5G2V/EYJEr8T99O6jrFNVO1+bsR
# uaKFpZom3fnoPMWDo3UrTSjHWfqjZBY7FCVvEAmr4IWghuB6tmSuyCqXLxvq2FQT
# DsGNuyl+IdkXDZKOHELyEV6pqY2k/Rz5l0vhKyMOnF7CjBpjksKIzWg6mt5OtDlv
# Ql/aehTVdqcxVkmnyvSO4VMgQ2xMaBocA8YDzhNMBUthBTcrUtkQZ8N2jt0FcP06
# oukytuApAY5Z3PZrRaORPc9g2Y5/Hte4ozoyzjfFss1PS6g1spCavLPzig==
# SIG # End signature block
