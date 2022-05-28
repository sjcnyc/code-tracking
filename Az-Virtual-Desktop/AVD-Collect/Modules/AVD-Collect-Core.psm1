<#
.SYNOPSIS
   Scenario module for collecting AVD Core data

.DESCRIPTION
   Collect 'Core' troubleshooting data, suitable for generic AVD troubleshooting.

.NOTES  
   Authors    : Robert Klemencz (Microsoft CSS) & Alexandru Olariu (Microsoft CSS)
   Requires   : At least PowerShell 5.1 (This module is not for stand-alone use. It is used automatically from within the main AVD-Collect.ps1 script)
   Version    : See AVD-Collect.ps1 version
   Feedback   : Send an e-mail to AVDCollectTalk@microsoft.com
#>

$LogPrefix = "Core"

$bodyRDLS = '<style>
BODY { background-color:#E0E0E0; font-family: sans-serif; font-size: small; }
table { background-color: white; border-collapse:collapse; border: 1px solid black; padding: 10px; }
td { padding-left: 10px; padding-right: 10px; }
</style>'

Function UEXAVD_GetPackagesLogFiles {
    Param([Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string]$LogFilePath, [Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string]$LogFolderID)

    if (Test-path -path $LogFilePath) {
        $verfolder = get-ChildItem $LogFilePath -recurse | Foreach-Object {If ($_.psiscontainer) {$_.fullname}} | Select-Object -first 1
        $filepath = $verfolder + "\Status\"

        if (Test-path -path $filepath) {
            Try{
                Copy-Item $filepath "$LogFileLogFolder\$LogFolderID" -Recurse -ErrorAction Continue 2>&1 | Out-Null
            } Catch {
                UEXAVD_LogException ("Error: An exception occurred in UEXAVD_GetPackagesLogFiles $filepath.") -ErrObj $_ $fLogFileOnly
                Continue
            }
        } else {
            UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] '$LogFolderID' log not found."
        }
    } else {
        UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] '$LogFilePath' folder not found."
    }
}

Function UEXAVD_GetAVDLogFiles {
    Param([Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string]$LogFilePath, [Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string]$LogFileID)

    $LogFile = $LogFileLogFolder + $env:computername + "_" + $LogFileID + ".txt"

    if (Test-path -path "$LogFilePath") {
        Try{
            Copy-Item $LogFilePath $LogFile -ErrorAction Continue 2>&1 | Out-Null
        } Catch {
            UEXAVD_LogException ("Error: An exception occurred in UEXAVD_GetAVDLogFiles $LogFilePath.") -ErrObj $_ $fLogFileOnly
            Continue
        }
    } else {
        UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] '$LogFilePath' log not found."
    }
}

Function UEXAVD_GetMonTables {
    $MTfolder = 'C:\Windows\System32\config\systemprofile\AppData\Roaming\Microsoft\Monitoring\Tables'

    if (Test-path -path $MTfolder) {
        Try {
            UEXAVD_CreateLogFolder $MonTablesFolder
        } Catch {
            UEXAVD_LogMessage $LogLevel.Error ("Unable to create log folder." + $_.Exception.Message)
            Return
        }

        Try {
            Switch(Get-ChildItem -Path "C:\Program Files\Microsoft RDInfra\") {
                {$_.Name -match "RDMonitoringAgent"} {
                    $convertpath = "C:\Program Files\Microsoft RDInfra\" + $_.Name + "\Agent\table2csv.exe"
                }
            }
        } Catch {
            UEXAVD_LogException ("ERROR: An error occurred during preparing Monitoring Tables conversion") -ErrObj $_ $fLogFileOnly
            Continue
        }

        Try {
            Switch(Get-ChildItem -Path $MTfolder) {
                {($_.Name -notmatch "00000") -and ($_.Name -match ".tsf")} {
                    $monfile = $MTfolder + "\" + $_.name
                    cmd /c $convertpath -path $MonTablesFolder $monfile 2>&1 | Out-Null
                }
            }
        } Catch {
            UEXAVD_LogException ("ERROR: An error occurred during getting Monitoring Tables data") -ErrObj $_ $fLogFileOnly
            Continue
        }

    } else {
        UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] Monitoring\Tables folder not found."
    }
}

Function global:UEXAVD_GetWinRMConfig {

    if ((get-service -name WinRM).status -eq "Running") {
        Try {
            $config = Get-ChildItem WSMan:\localhost\ -Recurse -ErrorAction Continue 2>&1 | Out-Null
            if (!($config)) {
                UEXAVD_LogMessage $LogLevel.WarnLogFileOnly ("[$LogPrefix] Cannot connect to localhost, trying with FQDN " + $fqdn)
                Connect-WSMan -ComputerName $fqdn -ErrorAction Continue 2>&1 | Out-Null
                $config = Get-ChildItem WSMan:\$fqdn -Recurse -ErrorAction Continue 2>&1 | Out-Null
                Disconnect-WSMan -ComputerName $fqdn -ErrorAction Continue 2>&1 | Out-Null
            }
            $config | out-file -Append ($SysInfoLogFolder + $LogFilePrefix + "WinRM-Config.txt")
        } Catch {
            UEXAVD_LogException ("ERROR: An error occurred during getting WinRM configuration") -ErrObj $_ $fLogFileOnly
            Continue
        }

        winrm get winrm/config 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "WinRM-Config.txt")
        winrm e winrm/config/listener 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "WinRM-Config.txt")

    } else {
        UEXAVD_LogMessage $LogLevel.Error ("[$LogPrefix] WinRM service is not running. Skipping collection of WinRM configuration data.")
    }
}

Function global:UEXAVD_GetNBDomainName {
    $pNameBuffer = [IntPtr]::Zero
    $joinStatus = 0
    $apiResult = [Win32Api.NetApi32]::NetGetJoinInformation(
        $null,               # lpServer
        [Ref] $pNameBuffer,  # lpNameBuffer
        [Ref] $joinStatus    # BufferType
    )
    if ($apiResult -eq 0) {
        [Runtime.InteropServices.Marshal]::PtrToStringAuto($pNameBuffer)
        [Void] [Win32Api.NetApi32]::NetApiBufferFree($pNameBuffer)
    }
}

Function global:UEXAVD_GetRdClientAutoTrace {
    $MSRDCfolder = $env:USERPROFILE + '\AppData\Local\Temp\DiagOutputDir\RdClientAutoTrace\*'

    if (Test-path -path $MSRDCfolder) {
        Try {
            UEXAVD_CreateLogFolder $RDCTraceFolder
        } Catch {
            UEXAVD_LogMessage $LogLevel.Error ("Unable to create log folder." + $_.Exception.Message)
            Return
        }

        #Getting only traces from over the past 5 days
        (Get-ChildItem $MSRDCfolder).LastWriteTime | ForEach-Object {
            if (([datetime]::Now - $_).Days -le "5") {
                Copy-Item $MSRDCfolder $RDCTraceFolder -Recurse -ErrorAction Continue 2>&1 | Out-Null
            }
        }
    } else {
        UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] '$MSRDCfolder' folder not found."
    }
}

function UEXAVD_GetRDLSDB {

    $RDSLSKP = UEXAVD_GetRDRoleInfo Win32_TSLicenseKeyPack "root\cimv2"
    if ($RDSLSKP) {
        $KPtitle = "Installed RDS license packs"
        $RDSLSKP | ConvertTo-Html -Title $KPtitle -body $bodyRDLS -Property PSComputerName, ProductVersion, Description, TypeAndModel, TotalLicenses, AvailableLicenses, IssuedLicenses, KeyPackId, KeyPackType, ProductVersionId, AccessRights, ExpirationDate | Out-File -Append ($RDSLogFolder + $LogFilePrefix + "rdls_LicenseKeyPacks.html")
    } else {
        UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] [WARNING] Failed to get Win32_TSLicenseKeyPack."
    }

    $RDSLSIL = UEXAVD_GetRDRoleInfo Win32_TSIssuedLicense "root\cimv2"
    if ($RDSLSIL) {
        $KPtitle = "Issued RDS licenses"
        $RDSLSIL | ConvertTo-Html -Title $KPtitle -body $bodyRDLS -Property PSComputerName, LicenseId, sIssuedToUser, sIssuedToComputer, IssueDate, ExpirationDate, LicenseStatus, KeyPackId, sHardwareId | Out-File -Append ($RDSLogFolder + $LogFilePrefix + "rdls_IssuedLicenses.html")
    } else {
        UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] [WARNING] Failed to get Win32_TSIssuedLicense."
    }
}

Function UEXAVD_GetStore($store) {
    $certlist = Get-ChildItem ("Cert:\LocalMachine\" + $store)

    foreach ($cert in $certlist) {
        $EKU = ""
        foreach ($item in $cert.EnhancedKeyUsageList) {
            if ($item.FriendlyName) {
                $EKU += $item.FriendlyName + " / "
            } else {
                $EKU += $item.ObjectId + " / "
            }
        }

        $row = $tbcert.NewRow()

        foreach ($ext in $cert.Extensions) {
            if ($ext.oid.value -eq "2.5.29.14") {
                $row.SubjectKeyIdentifier = $ext.SubjectKeyIdentifier.ToLower()
            }
            if (($ext.oid.value -eq "2.5.29.35") -or ($ext.oid.value -eq "2.5.29.1")) {
                $asn = New-Object Security.Cryptography.AsnEncodedData ($ext.oid,$ext.RawData)
                $aki = $asn.Format($true).ToString().Replace(" ","")
                $aki = (($aki -split '\n')[0]).Replace("KeyID=","").Trim()
                $row.AuthorityKeyIdentifier = $aki
            }
        }

        if ($EKU) {$EKU = $eku.Substring(0, $eku.Length-3)}
        $row.Store = $store
        $row.Thumbprint = $cert.Thumbprint.ToLower()
        $row.Subject = $cert.Subject
        $row.Issuer = $cert.Issuer
        $row.NotAfter = $cert.NotAfter
        $row.EnhancedKeyUsage = $EKU
        $row.SerialNumber = $cert.SerialNumber.ToLower()
        $tbcert.Rows.Add($row)
    }
}

Add-Type -MemberDefinition @"
[DllImport("netapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
public static extern uint NetApiBufferFree(IntPtr Buffer);
[DllImport("netapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
public static extern int NetGetJoinInformation(
    string server,
    out IntPtr NameBuffer,
    out int BufferType);
"@ -Namespace Win32Api -Name NetApi32


Function CollectUEX_AVDCoreLog {
    " " | Out-File -Append $OutputLogFile
    UEXAVD_LogMessage $LogLevel.Info "Running data collection - please wait ...`n" -Color "Cyan"
    " " | Out-File -Append $OutputLogFile

    #Collecting process dumps
    if ($dpid) {
        Try {
            UEXAVD_CreateLogFolder $DumpFolder
        } Catch {
            UEXAVD_LogMessage $LogLevel.Error ("Unable to create log folder." + $_.Exception.Message)
            Return
        }
        $procname = Get-Process -id $dpid | Select-Object -ExpandProperty Name
        UEXAVD_LogMessage $LogLevel.Info ('Collecting Process Dump for PID ' + $dpid + ' (' + $procname + ')')
        $DumpFile = $DumpFolder + "$procname-$dpid.dmp"
        Powershell -c rundll32.exe C:\Windows\System32\comsvcs.dll, MiniDump $dpid $DumpFile full
    }

    #Collecting RDS/AVD information
    UEXAVD_LogMessage $LogLevel.Info ('Collecting RDS/AVD information')
    Try {
        UEXAVD_CreateLogFolder $LogFileLogFolder
        UEXAVD_CreateLogFolder $NetLogFolder
        UEXAVD_CreateLogFolder $SysInfoLogFolder
    } Catch {
        UEXAVD_LogMessage $LogLevel.Error ("Unable to create log folder." + $_.Exception.Message)
        Return
    }
    
    UEXAVD_LogMessage $LogLevel.Normal ("[$LogPrefix] Collecting 'C:\WindowsAzure\Logs\Plugins\*'")
    if (Test-path -path 'C:\WindowsAzure\Logs\Plugins') {
        Copy-Item 'C:\WindowsAzure\Logs\Plugins\*' $LogFileLogFolder -Recurse -ErrorAction Continue 2>>$global:ErrorLogFile
    } else {
        UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] WindowsAzure Plugins logs not found."
    }

    $Commands = @(
        "UEXAVD_GetPackagesLogFiles 'c:\Packages\Plugins\microsoft.powershell.dsc' 'Microsoft.PowerShell.DSC'"
        "UEXAVD_GetPackagesLogFiles 'c:\Packages\Plugins\Microsoft.EnterpriseCloud.Monitoring.MicrosoftMonitoringAgent' 'Microsoft.EnterpriseCloud.Monitoring.MicrosoftMonitoringAgent'"
        "UEXAVD_GetPackagesLogFiles 'c:\Packages\Plugins\Microsoft.Compute.JsonADDomainExtension' 'Microsoft.Compute.JsonADDomainExtension'"
        "UEXAVD_GetPackagesLogFiles 'c:\Packages\Plugins\Microsoft.Azure.ActiveDirectory.AADLoginForWindows' 'Microsoft.Azure.ActiveDirectory.AADLoginForWindows'"
        "UEXAVD_GetAVDLogFiles 'C:\WindowsAzure\Logs\WaAppAgent.log' WaAppAgent"
        "UEXAVD_GetAVDLogFiles 'C:\WindowsAzure\Logs\MonitoringAgent.log' MonitoringAgent"
        "UEXAVD_GetAVDLogFiles 'C:\Windows\debug\NetSetup.LOG' NetSetup"
        "UEXAVD_GetAVDLogFiles 'C:\Users\AgentInstall.txt' AgentInstall_initial"
        "UEXAVD_GetAVDLogFiles 'C:\Users\AgentBootLoaderInstall.txt' AgentBootLoaderInstall_initial"
        "UEXAVD_GetAVDLogFiles 'C:\Program Files\Microsoft RDInfra\AgentInstall.txt' AgentInstall_updates"
        "UEXAVD_GetAVDLogFiles 'C:\Program Files\Microsoft RDInfra\GenevaInstall.txt' GenevaInstall"
        "UEXAVD_GetAVDLogFiles 'C:\Program Files\Microsoft RDInfra\SXSStackInstall.txt' SXSStackInstall"
        "UEXAVD_GetAVDLogFiles 'C:\Program Files\MsRDCMMRHost\MsRDCMMRHostInstall.log' MsRDCMMRHostInstall"
        "UEXAVD_GetAVDLogFiles 'C:\Windows\Temp\ScriptLog.log' ScriptLog"
        "UEXAVD_GetRdClientAutoTrace"
        "qwinsta /counter 2>&1 | Out-File -Append '" + $NetLogFolder + $LogFilePrefix + "Qwinsta.txt'"
        "dxdiag /whql:off /t '" + $SysInfoLogFolder + $LogFilePrefix + "DxDiag.txt'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True

    Try {
        $vmdomain = [System.Directoryservices.Activedirectory.Domain]::GetComputerDomain()
        $Commands = @(
            "nltest /sc_query:$vmdomain 2>&1 | Out-File -Append '" + $NetLogFolder + $LogFilePrefix + "Nltest-scquery.txt'"
            "nltest /dnsgetdc:$vmdomain 2>&1 | Out-File -Append '" + $NetLogFolder + $LogFilePrefix + "Nltest-dnsgetdc.txt'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True
    } Catch {
        UEXAVD_LogException ("Error: An error occurred in $vmdomain") -ErrObj $_ $fLogFileOnly
    }

    if ($ver -like "*Windows 7*") {
        $Commands = @("UEXAVD_GetAVDLogFiles 'C:\Program Files\Microsoft RDInfra\WVDAgentManagerInstall.txt' AVDAgentManagerInstall")
    } else {
        $Commands = @("dsregcmd /status 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "Dsregcmd.txt'")
    }
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True

    if ([ADSI]::Exists("WinNT://localhost/Remote Desktop Users")) {
        $Commands = @(
            "net localgroup 'Remote Desktop Users' 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "LocalGroupsMembership.txt'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True
    } else {
        UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] 'Remote Desktop Users' group not found."
    }


    #Collecting <BrokerURI>api/health and <BrokerURIGlobal>api/health status
    UEXAVD_LogMessage $LogLevel.Normal ("[$LogPrefix] Collecting <BrokerURI>api/health and <BrokerURIGlobal>api/health status")
    $brokerURIregpath = "HKLM:\SOFTWARE\Microsoft\RDInfraAgent\"

    #Extra for Windows 7
    if ($ver -like "*Windows 7*") { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 }

    $brokerout = $NetLogFolder + $LogFilePrefix + "AVDServicesURIHealth.txt"
    $brokerURIregkey = "BrokerURI"
        if (UEXAVD_TestRegistryValue -path $brokerURIregpath -value $brokerURIregkey) {
            $brokerURI = (Get-ItemPropertyValue -Path $brokerURIregpath -name $brokerURIregkey) + "api/health"
            "$brokerURI" | Out-File -Append $brokerout
            Invoke-WebRequest $brokerURI -UseBasicParsing | Out-File -Append $brokerout
        } else {
            UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] Reg key '$brokerURIregpath$brokerURIregkey' not found."
        }

    $brokerURIGlobalregkey = "BrokerURIGlobal"
        if (UEXAVD_TestRegistryValue -path $brokerURIregpath -value $brokerURIGlobalregkey) {
            $brokerURIGlobal = (Get-ItemPropertyValue -Path $brokerURIregpath -name $brokerURIGlobalregkey) + "api/health"
            "$brokerURIGlobal" | Out-File -Append $brokerout
            Invoke-WebRequest $brokerURIGlobal -UseBasicParsing | Out-File -Append $brokerout
        } else {
            UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] Reg key '$brokerURIregpath$brokerURIGlobalregkey' not found."
        }

    $diagURIregkey = "DiagnosticsUri"
        if (UEXAVD_TestRegistryValue -path $brokerURIregpath -value $diagURIregkey) {
            $diagURI = (Get-ItemPropertyValue -Path $brokerURIregpath -name $diagURIregkey) + "api/health"
            "$diagURI" | Out-File -Append $brokerout
            Invoke-WebRequest $diagURI -UseBasicParsing | Out-File -Append $brokerout
        } else {
            UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] Reg key '$brokerURIregpath$diagURIregkey' not found."
        }

    $brokerResURIGlobalregkey = "BrokerResourceIdURIGlobal"
        if (UEXAVD_TestRegistryValue -path $brokerURIregpath -value $brokerResURIGlobalregkey) {
            $brokerResURIGlobal = (Get-ItemPropertyValue -Path $brokerURIregpath -name $brokerResURIGlobalregkey) + "api/health"
            "$brokerResURIGlobal" | Out-File -Append $brokerout
            Invoke-WebRequest $brokerResURIGlobal -UseBasicParsing | Out-File -Append $brokerout
        } else {
            UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] Reg key '$brokerURIregpath$brokerResURIGlobalregkey' not found."
        }

    #Collecting Geneva Monitoring information
    " " | Out-File -Append $OutputLogFile
    UEXAVD_LogMessage $LogLevel.Info ('Collecting Geneva Monitoring information')

    if (!($ver -like "*Windows 7*")) {
        Try {
            UEXAVD_CreateLogFolder $GenevaLogFolder
            UEXAVD_CreateLogFolder $SchtaskFolder
        } Catch {
            UEXAVD_LogMessage $LogLevel.Error ("Unable to create log folder." + $_.Exception.Message)
            Return
        }

        Try {
            UEXAVD_LogMessage $LogLevel.Normal "[$LogPrefix] Collecting Azure Instance Metadata Service (IMDS) endpoint accessibility information"
            $request = [System.Net.WebRequest]::Create("http://169.254.169.254/metadata/instance/network?api-version=2021-10-01")
            $request.Proxy = [System.Net.WebProxy]::new()
            $request.Headers.Add("Metadata","True")
            $request.Timeout = 10000
            $request.GetResponse() | Out-File -Append ($GenevaLogFolder + $LogFilePrefix + "IMDSRequestInfo.txt")
        } Catch {
            UEXAVD_LogException ("Error: An error occurred in $request") -ErrObj $_ $fLogFileOnly
        }

        if (Get-ScheduledTask GenevaTask* -ErrorAction Ignore) {
            (Get-ScheduledTask GenevaTask*).TaskName | ForEach-Object -Process {
                $Commands = @(
                    "Export-ScheduledTask -TaskName $_ 2>&1 | Out-File -Append '" + $SchtaskFolder + $LogFilePrefix + "schtasks_" + $_ + ".xml'"
                    "Get-ScheduledTaskInfo -TaskName $_ 2>&1 | Out-File -Append '" + $SchtaskFolder + $LogFilePrefix + "schtasks_" + $_ + "_Info.txt'"
                )
                UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True
            }
        } else {
            UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] Geneva Scheduled Task not found."
        }
    } else {
        UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] Windows 7 detected. Geneva Monitoring information will not be collected."
    }

    $Commands = @(
        "UEXAVD_GetMonTables"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True

    $tccpath = "C:\Program Files\Microsoft Monitoring Agent"
    if (Test-Path $tccpath) {
        $Commands = @(
            "cmd /c set mon 2>&1 | Out-File -Append '" + $GenevaLogFolder + $LogFilePrefix + "setMON.txt'"
            "cmd /c `"C:\Program Files\Microsoft Monitoring Agent\Agent\TestCloudConnection.exe`" 2>&1 | Out-File -Append '" + $GenevaLogFolder + $LogFilePrefix + "AMA-TestCloudConnection.txt'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True
    } else {
        UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] Microsoft Monitoring Agent components not found."
    }


    #Collecting event logs
    " " | Out-File -Append $OutputLogFile
    UEXAVD_LogMessage $LogLevel.Info ('Collecting event log information')
    Try {
        UEXAVD_CreateLogFolder $EventLogFolder
    } Catch {
        UEXAVD_LogMessage $LogLevel.Error ("Unable to create log folder." + $_.Exception.Message)
        Return
    }
    
    $Commands = @(
        "UEXAVD_GetEventLogs 'System' 'System'"
        "UEXAVD_GetEventLogs 'Application' 'Application'"
        "UEXAVD_GetEventLogs 'Security' 'Security'"
        "UEXAVD_GetEventLogs 'Setup' 'Setup'"
        "UEXAVD_GetEventLogs 'RemoteDesktopServices' 'RemoteDesktopServices'"
        "UEXAVD_GetEventLogs 'Microsoft-WindowsAzure-Diagnostics/Bootstrapper' 'WindowsAzure-Diag-Bootstrapper'"
        "UEXAVD_GetEventLogs 'Microsoft-WindowsAzure-Diagnostics/GuestAgent' 'WindowsAzure-Diag-GuestAgent'"
        "UEXAVD_GetEventLogs 'Microsoft-WindowsAzure-Diagnostics/Heartbeat' 'WindowsAzure-Diag-Heartbeat'"
        "UEXAVD_GetEventLogs 'Microsoft-WindowsAzure-Diagnostics/Runtime' 'WindowsAzure-Diag-Runtime'"
        "UEXAVD_GetEventLogs 'Microsoft-WindowsAzure-Status/GuestAgent' 'WindowsAzure-Status-GuestAgent'"
        "UEXAVD_GetEventLogs 'Microsoft-WindowsAzure-Status/Plugins' 'WindowsAzure-Status-Plugins'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-AAD/Operational' 'AAD-Operational'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-CAPI2/Operational' 'CAPI2-Operational'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-Diagnostics-Performance/Operational' 'DiagnosticsPerformance-Operational'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-DSC/Operational' 'DSC-Operational'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-WinRM/Operational' 'WinRM-Operational'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-PowerShell/Operational' 'PowerShell-Operational'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-RemoteDesktopServices-RdpCoreTS/Operational' 'RemoteDesktopServicesRdpCoreTS-Operational'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-RemoteDesktopServices-RdpCoreTS/Admin' 'RemoteDesktopServicesRdpCoreTS-Admin'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-RemoteDesktopServices-RdpCoreCDV/Admin' 'RemoteDesktopServicesRdpCoreCDV-Admin'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-RemoteDesktopServices-RdpCoreCDV/Operational' 'RemoteDesktopServicesRdpCoreCDV-Operational'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-TaskScheduler/Operational' 'TaskScheduler-Operational'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-TerminalServices-RDPClient/Operational' 'RDPClient-Operational'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-TerminalServices-LocalSessionManager/Operational' 'TerminalServicesLocalSessionManager-Operational'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-TerminalServices-LocalSessionManager/Admin' 'TerminalServicesLocalSessionManager-Admin'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-TerminalServices-RemoteConnectionManager/Admin' 'TerminalServicesRemoteConnectionManager-Admin'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational' 'TerminalServicesRemoteConnectionManager-Operational'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-TerminalServices-PnPDevices/Admin' 'TerminalServicesPnPDevices-Admin'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-TerminalServices-PnPDevices/Operational' 'TerminalServicesPnPDevices-Operational'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-WinINet-Config/ProxyConfigChanged' 'WinHttp-ProxyConfigChanged'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-Winlogon/Operational' 'Winlogon-Operational'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True


    #Collecting reg keys
    " " | Out-File -Append $OutputLogFile
    UEXAVD_LogMessage $LogLevel.Info ('Collecting reg key information')
    Try {
        UEXAVD_CreateLogFolder $RegLogFolder
    } Catch {
        UEXAVD_LogMessage $LogLevel.Error ("Unable to create log folder." + $_.Exception.Message)
        Return
    }
    
    $Commands = @(
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Microsoft\Azure\DSC' 'SW-MS-Azure-DSC'"
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Microsoft\MSRDC' 'SW-MS-MSRDC'"
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Microsoft\NET Framework Setup\NDP' 'SW-MS-NetFS-NDP'"
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Microsoft\RDMonitoringAgent' 'SW-MS-RDMonitoringAgent'"
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Microsoft\RDInfraAgent' 'SW-MS-RDInfraAgent'"
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Microsoft\Terminal Server Client' 'SW-MS-TerminalServerClient'"
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Microsoft\MSLicensing' 'SW-MS-MSLicensing'"
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters' 'SW-MS-VM-GuestParams'"
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Microsoft\Windows\CurrentVersion\Policies' 'SW-MS-Win-CV-Policies'"
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Microsoft\Windows\CurrentVersion\Run' 'SW-MS-Win-CV-Run'"
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' 'SW-MS-Win-CV-RunOnce'"
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Microsoft\Windows\Windows Error Reporting' 'SW-MS-Win-WindowsErrorReporting'"
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Terminal Server' 'SW-MS-WinNT-CV-TerminalServer'"
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers' 'SW-MS-WinNT-CV-AppCompatFlags-Layers'"
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Policies\Microsoft\Cryptography' 'SW-Policies-MS-Cryptography'"
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation' 'SW-Policies-MS-Win-CredentialsDelegation'"
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' 'SW-Policies-MS-WinNT-TerminalServices'"
        "UEXAVD_GetRegKeys 'HKLM' 'SYSTEM\CurrentControlSet\Control\CrashControl' 'System-CCS-Control-CrashControl'"
        "UEXAVD_GetRegKeys 'HKLM' 'SYSTEM\CurrentControlSet\Control\Cryptography' 'System-CCS-Control-Cryptography'"
        "UEXAVD_GetRegKeys 'HKLM' 'SYSTEM\CurrentControlSet\Control\CloudDomainJoin' 'System-CCS-Control-CloudDomainJoin'"
        "UEXAVD_GetRegKeys 'HKLM' 'SYSTEM\CurrentControlSet\Control\Lsa' 'System-CCS-Control-LSA'"
        "UEXAVD_GetRegKeys 'HKLM' 'SYSTEM\CurrentControlSet\Control\SecurityProviders' 'System-CCS-Control-SecurityProviders'"
        "UEXAVD_GetRegKeys 'HKLM' 'SYSTEM\CurrentControlSet\Control\Terminal Server' 'System-CCS-Control-TerminalServer'"
        "UEXAVD_GetRegKeys 'HKLM' 'SYSTEM\CurrentControlSet\Enum\TERMINPUT_BUS' 'System-CCS-Enum-TERMINPUT_BUS'"
        "UEXAVD_GetRegKeys 'HKLM' 'SYSTEM\CurrentControlSet\Services\RdAgent' 'System-CCS-Svc-RdAgent'"
        "UEXAVD_GetRegKeys 'HKLM' 'SYSTEM\CurrentControlSet\Services\Tcpip' 'System-CCS-Svc-Tcpip'"
        "UEXAVD_GetRegKeys 'HKLM' 'SYSTEM\CurrentControlSet\Services\TermService' 'System-CCS-Svc-TermService'"
        "UEXAVD_GetRegKeys 'HKLM' 'SYSTEM\CurrentControlSet\Services\UmRdpService' 'System-CCS-Svc-UmRdpService'"
        "UEXAVD_GetRegKeys 'HKLM' 'SYSTEM\CurrentControlSet\Services\WinRM' 'System-CCS-Svc-WinRM'"
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Microsoft\Ole' 'SW-MS-Ole'"
        "UEXAVD_GetRegKeys 'HKCU' 'SOFTWARE\Microsoft\RdClientRadc' 'SW-MS-RdClientRadc'"
        "UEXAVD_GetRegKeys 'HKCU' 'SOFTWARE\Microsoft\Remote Desktop' 'SW-MS-RemoteDesktop'"
        "UEXAVD_GetRegKeys 'HKCU' 'SOFTWARE\Microsoft\Windows\CurrentVersion\Run' 'SW-MS-Win-CV-Run'"
        "UEXAVD_GetRegKeys 'HKCU' 'SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' 'SW-MS-Win-CV-RunOnce'"
        "UEXAVD_GetRegKeys 'HKCU' 'SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings' 'SW-MS-Win-CV-InternetSettings'"
        "UEXAVD_GetRegKeys 'HKU' '.DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings' 'Def-SW-MS-Win-CV-InternetSettings'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True

    if (!($ver -like "*Windows 7*")) {
    $Commands = @(
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Microsoft\RDAgentBootLoader' 'SW-MS-RDAgentBootLoader'"
        "UEXAVD_GetRegKeys 'HKLM' 'SYSTEM\CurrentControlSet\Services\RDAgentBootLoader' 'System-CCS-Svc-RDAgentBootLoader'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True
    } else {
        $Commands = @(
            "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Microsoft\WVDAgentManager' 'SW-MS-WVDAgentManager'"
            "UEXAVD_GetRegKeys 'HKLM' 'SYSTEM\CurrentControlSet\Services\WVDAgent' 'System-CCS-Svc-WVDAgent'"
            "UEXAVD_GetRegKeys 'HKLM' 'SYSTEM\CurrentControlSet\Services\WVDAgentManager' 'System-CCS-Svc-WVDAgentManager'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True
    }


    #Collecting RDP and Net info
    " " | Out-File -Append $OutputLogFile
    UEXAVD_LogMessage $LogLevel.Info ('Collecting networking information')

    if (!($ver -like "*Windows 7*")) {
        $Commands = @(
            "Get-NetConnectionProfile | Out-File -Append '" + $NetLogFolder + $LogFilePrefix + "NetConnectionProfile.txt'"
            "Get-NetIPInterface | Out-File -Append '" + $NetLogFolder + $LogFilePrefix + "NetIPInterface.txt'"
            "Get-NetIPInterface | fl | Out-File -Append '" + $NetLogFolder + $LogFilePrefix + "NetIPInterface.txt'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True
    }

    $Commands = @(
        "netsh advfirewall firewall show rule name=all 2>&1 | Out-File -Append '" + $NetLogFolder + $LogFilePrefix + "FirewallRules.txt'"
        "netstat -anob 2>&1 | Out-File -Append '" + $NetLogFolder + $LogFilePrefix + "Netstat.txt'"
        "ipconfig /all 2>&1 | Out-File -Append '" + $NetLogFolder + $LogFilePrefix + "Ipconfig.txt'"
        "netsh winhttp show proxy 2>&1 | Out-File -Append '" + $NetLogFolder + $LogFilePrefix + "Proxy.txt'"
        "netsh winsock show catalog 2>&1 | Out-File -Append '" + $NetLogFolder + $LogFilePrefix + "WinsockCatalog.txt'"
        "netsh interface Teredo show state 2>&1 | Out-File -Append '" + $NetLogFolder + $LogFilePrefix + "Teredo.txt'"
        "nslookup wpad 2>&1 | Out-File -Append '" + $NetLogFolder + $LogFilePrefix + "Nslookup.txt'"
        "nslookup rdweb.wvd.microsoft.com 2>&1 | Out-File -Append '" + $NetLogFolder + $LogFilePrefix + "Nslookup.txt'"
        "bitsadmin /util /getieproxy LOCALSYSTEM 2>&1 | Out-File -Append '" + $NetLogFolder + $LogFilePrefix + "Proxy.txt'"
        "bitsadmin /util /getieproxy NETWORKSERVICE 2>&1 | Out-File -Append '" + $NetLogFolder + $LogFilePrefix + "Proxy.txt'"
        "bitsadmin /util /getieproxy LOCALSERVICE 2>&1 | Out-File -Append '" + $NetLogFolder + $LogFilePrefix + "Proxy.txt'"
        "route print 2>&1 | Out-File -Append '" + $NetLogFolder + $LogFilePrefix + "Route.txt'"
        "tree 'C:\Windows\RemotePackages' /f 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "tree_Win-RemotePackages.txt'"
        "tree 'C:\Program Files\Microsoft RDInfra' /f 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "tree_ProgFiles-MicrosoftRDInfra.txt'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True

    # Remote Desktop scheduled tasks
    if (!($ver -like "*Windows 7*")) {
        if (Get-ScheduledTask -TaskPath '\RemoteDesktop\*' -ErrorAction Ignore) {
            $rdschedUser = "\RemoteDesktop\" + [System.Environment]::UserName
            $Commands = @(
                "Get-ScheduledTask -TaskPath '\RemoteDesktop\*' | Export-ScheduledTask 2>&1 | Out-File -Append '" + $SchtaskFolder + $LogFilePrefix + "schtasks_RemoteDesktop.xml'"
                "Get-ScheduledTaskInfo -TaskName 'Remote Desktop Feed Refresh Task' -TaskPath '$rdschedUser' 2>&1 | Out-File -Append '" + $SchtaskFolder + $LogFilePrefix + "schtasks_RemoteDesktop_Info.txt'"
            )
            UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True
        } else {
            UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] Remote Desktop Scheduled Tasks not found."
        }
    }

    #Collecting system information
    " " | Out-File -Append $OutputLogFile
    UEXAVD_LogMessage $LogLevel.Info ('Collecting system information')

    UEXAVD_LogMessage $LogLevel.Normal "[$LogPrefix] Collecting details about currently running processes"
    $proc = Get-CimInstance -Namespace "root\cimv2" -Query "select Name, CreationDate, ProcessId, ParentProcessId, WorkingSetSize, UserModeTime, KernelModeTime, ThreadCount, HandleCount, CommandLine, ExecutablePath from Win32_Process" -ErrorAction Continue 2>>$global:ErrorLogFile
    if ($PSVersionTable.psversion.ToString() -ge "3.0") {
        $StartTime= @{e={$_.CreationDate.ToString("yyyyMMdd HH:mm:ss")};n="Start time"}
    } else {
        $StartTime= @{n='StartTime';e={$_.ConvertToDateTime($_.CreationDate)}}
    }

    if ($proc) {
        $proc | Sort-Object Name | Format-Table -AutoSize -property @{e={$_.ProcessId};Label="PID"}, @{e={$_.ParentProcessId};n="Parent"}, Name,
        @{N="WorkingSet";E={"{0:N0}" -f ($_.WorkingSetSize/1kb)};a="right"},
        @{e={[DateTime]::FromFileTimeUtc($_.UserModeTime).ToString("HH:mm:ss")};n="UserTime"}, @{e={[DateTime]::FromFileTimeUtc($_.KernelModeTime).ToString("HH:mm:ss")};n="KernelTime"},
        @{N="Threads";E={$_.ThreadCount}}, @{N="Handles";E={($_.HandleCount)}}, $StartTime, CommandLine | Out-String -Width 500 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "RunningProcesses.txt")

        UEXAVD_LogMessage $LogLevel.Normal "[$LogPrefix] Collecting file version of running and key system binaries"
        $binlist = $proc | Group-Object -Property ExecutablePath
        foreach ($file in $binlist) {
            if ($file.Name) {
                UEXAVD_FileVersion -Filepath ($file.name) -Log $true 2>&1 | Out-Null
            }
        }

        $pad = 27
        $OS = Get-CimInstance -Namespace "root\cimv2" -Query "select Caption, CSName, OSArchitecture, BuildNumber, InstallDate, LastBootUpTime, LocalDateTime, TotalVisibleMemorySize, FreePhysicalMemory, SizeStoredInPagingFiles, FreeSpaceInPagingFiles from Win32_OperatingSystem" -ErrorAction Continue 2>>$global:ErrorLogFile
        $CS = Get-CimInstance -Namespace "root\cimv2" -Query "select Model, Manufacturer, SystemType, NumberOfProcessors, NumberOfLogicalProcessors, TotalPhysicalMemory, DNSHostName, Domain, DomainRole from Win32_ComputerSystem" -ErrorAction Continue 2>>$global:ErrorLogFile
        $BIOS = Get-CimInstance -Namespace "root\cimv2" -query "select BIOSVersion, Manufacturer, ReleaseDate, SMBIOSBIOSVersion from Win32_BIOS" -ErrorAction Continue 2>>$global:ErrorLogFile
        $TZ = Get-CimInstance -Namespace "root\cimv2" -Query "select Description from Win32_TimeZone" -ErrorAction Continue 2>>$global:ErrorLogFile
        $PR = Get-CimInstance -Namespace "root\cimv2" -Query "select Name, Caption from Win32_Processor" -ErrorAction Continue 2>>$global:ErrorLogFile

        $ctr = Get-Counter -Counter "\Memory\Pool Paged Bytes" -ErrorAction Continue 2>>$global:ErrorLogFile
        $PoolPaged = $ctr.CounterSamples[0].CookedValue
        $ctr = Get-Counter -Counter "\Memory\Pool Nonpaged Bytes" -ErrorAction Continue 2>>$global:ErrorLogFile
        $PoolNonPaged = $ctr.CounterSamples[0].CookedValue

        "Computer name".PadRight($pad) + " : " + $OS.CSName 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
        "Model".PadRight($pad) + " : " + $CS.Model 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
        "Manufacturer".PadRight($pad) + " : " + $CS.Manufacturer 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
        "BIOS Version".PadRight($pad) + " : " + $BIOS.BIOSVersion 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
        "BIOS Manufacturer".PadRight($pad) + " : " + $BIOS.Manufacturer 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
        "BIOS Release date".PadRight($pad) + " : " + $BIOS.ReleaseDate 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
        "SMBIOS Version".PadRight($pad) + " : " + $BIOS.SMBIOSBIOSVersion 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
        "SystemType".PadRight($pad) + " : " + $CS.SystemType 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
        "Processor".PadRight($pad) + " : " + $PR.Name + " / " + $PR.Caption 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
        "Processors physical/logical".PadRight($pad) + " : " + $CS.NumberOfProcessors + " / " + $CS.NumberOfLogicalProcessors 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
        "Memory physical/visible".PadRight($pad) + " : " + ("{0:N0}" -f ($CS.TotalPhysicalMemory/1mb)) + " MB / " + ("{0:N0}" -f ($OS.TotalVisibleMemorySize/1kb)) + " MB" 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
        "Pool Paged / NonPaged".PadRight($pad) + " : " + ("{0:N0}" -f ($PoolPaged/1mb)) + " MB / " + ("{0:N0}" -f ($PoolNonPaged/1mb)) + " MB" 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
        "Free physical memory".PadRight($pad) + " : " + ("{0:N0}" -f ($OS.FreePhysicalMemory/1kb)) + " MB" 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
        "Paging files size / free".PadRight($pad) + " : " + ("{0:N0}" -f ($OS.SizeStoredInPagingFiles/1kb)) + " MB / " + ("{0:N0}" -f ($OS.FreeSpaceInPagingFiles/1kb)) + " MB" 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
        "Operating System".PadRight($pad) + " : " + $OS.Caption + " " + $OS.OSArchitecture 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")

        [string]$WinVerBuild = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion' CurrentBuild).CurrentBuild
        [string]$WinVerRevision = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion' UBR).UBR

        if (!($ver -like "*Windows 7*")) {
            [string]$WinVerMajor = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion' CurrentMajorVersionNumber).CurrentMajorVersionNumber
            [string]$WinVerMinor = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion' CurrentMinorVersionNumber).CurrentMinorVersionNumber
            "Build Number".PadRight($pad) + " : " + $WinVerMajor + "." + $WiNVerMinor + "." + $WinVerBuild + "." + $WinVerRevision 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
        } else {
            "Build Number".PadRight($pad) + " : " + $WinVerBuild + "." + $WinVerRevision 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
        }

        "Installation type".PadRight($pad) + " : " + (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").InstallationType 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
        "Time zone".PadRight($pad) + " : " + $TZ.Description 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
        "Install date".PadRight($pad) + " : " + $OS.InstallDate 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
        "Last boot time".PadRight($pad) + " : " + $OS.LastBootUpTime 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
        "Local time".PadRight($pad) + " : " + $OS.LocalDateTime 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
        "DNS Hostname".PadRight($pad) + " : " + $CS.DNSHostName 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
        "DNS Domain name".PadRight($pad) + " : " + $CS.Domain 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
        "NetBIOS Domain name".PadRight($pad) + " : " + (UEXAVD_GetNBDomainName) 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
        $roles = "Standalone Workstation", "Member Workstation", "Standalone Server", "Member Server", "Backup Domain Controller", "Primary Domain Controller"
        "Domain role".PadRight($pad) + " : " + $roles[$CS.DomainRole] 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")

        " " | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")

        $drives = @()
        $drvtype = "Unknown", "No Root Directory", "Removable Disk", "Local Disk", "Network Drive", "Compact Disc", "RAM Disk"
        $Vol = Get-CimInstance -NameSpace "root\cimv2" -Query "select * from Win32_LogicalDisk" -ErrorAction Continue 2>>$global:ErrorLogFile
        foreach ($disk in $vol) {
                $drv = New-Object PSCustomObject
                $drv | Add-Member -type NoteProperty -name Letter -value $disk.DeviceID
                $drv | Add-Member -type NoteProperty -name DriveType -value $drvtype[$disk.DriveType]
                $drv | Add-Member -type NoteProperty -name VolumeName -value $disk.VolumeName
                $drv | Add-Member -type NoteProperty -Name TotalMB -Value ($disk.size)
                $drv | Add-Member -type NoteProperty -Name FreeMB -value ($disk.FreeSpace)
                $drives += $drv
            }
        $drives | Format-Table -AutoSize -property Letter, DriveType, VolumeName, @{N="TotalMB";E={"{0:N0}" -f ($_.TotalMB/1MB)};a="right"}, @{N="FreeMB";E={"{0:N0}" -f ($_.FreeMB/1MB)};a="right"} 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
    } else {
        $proc = Get-Process | Where-Object {$_.Name -ne "Idle"}
        $proc | Format-Table -AutoSize -property id, name, @{N="WorkingSet";E={"{0:N0}" -f ($_.workingset/1kb)};a="right"},
        @{N="VM Size";E={"{0:N0}" -f ($_.VirtualMemorySize/1kb)};a="right"},
        @{N="Proc time";E={($_.TotalProcessorTime.ToString().substring(0,8))}}, @{N="Threads";E={$_.threads.count}},
        @{N="Handles";E={($_.HandleCount)}}, StartTime, Path | Out-String -Width 300 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "RunningProcesses.txt")
    }

    $Commands = @(
        "Get-DscConfiguration 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "DscConfiguration.txt'"
        "Get-DscConfigurationStatus -all 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "DscConfiguration.txt'"
        "Test-DscConfiguration -Detailed 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "DscConfiguration.txt'"
        "gpresult /h '" + $SysInfoLogFolder + $LogFilePrefix + "Gpresult.html'" + " 2>&1 | Out-Null"
        "gpresult /r /z 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "Gpresult-rz.txt'"
        "Get-HotFix -ErrorAction SilentlyContinue | Sort-Object -Property InstalledOn -Descending -ErrorAction SilentlyContinue | Select-Object Description, HotfixID, Caption, InstalledBy, InstalledOn | ft 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "Hotfixes.txt'"
        "(Get-Item -Path 'C:\Windows\System32\*.dll').VersionInfo | Format-List -Force 2>&1 | Out-File '" + $SysInfoLogFolder + $LogFilePrefix + "ver_System32_DLL.txt'"
        "(Get-Item -Path 'C:\Windows\System32\*.exe').VersionInfo | Format-List -Force 2>&1 | Out-File '" + $SysInfoLogFolder + $LogFilePrefix + "ver_System32_EXE.txt'"
        "(Get-Item -Path 'C:\Windows\System32\*.sys').VersionInfo | Format-List -Force 2>&1 | Out-File '" + $SysInfoLogFolder + $LogFilePrefix + "ver_System32_SYS.txt'"
        "(Get-Item -Path 'C:\Windows\System32\drivers\*.sys').VersionInfo | Format-List -Force 2>&1 | Out-File '" + $SysInfoLogFolder + $LogFilePrefix + "ver_Drivers.txt'"
        "msinfo32 /nfo '" + $SysInfoLogFolder + $LogFilePrefix + "Msinfo32.nfo'" + " 2>&1 | Out-Null"
        "msinfo32 /report '" + $SysInfoLogFolder + $LogFilePrefix + "Msinfo32.txt'" + " 2>&1 | Out-Null"
        "fltmc filters 2>&1 | Out-File '" + $SysInfoLogFolder + $LogFilePrefix + "Fltmc.txt'"
        "fltmc volumes 2>&1 | Out-File '" + $SysInfoLogFolder + $LogFilePrefix + "Fltmc.txt'"
        "Get-Process | Sort-Object CPU -desc | Select-Object -first 10 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "RunningProcesses-Top10CPU.txt'"
        "tasklist /v 2>&1 | Out-File '" + $SysInfoLogFolder + $LogFilePrefix + "Tasklist.txt'"
        "UEXAVD_GetWinRMConfig"
        "Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "AntiVirusProducts.txt'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True

    if (!($ver -like "*Windows 7*")) {
        $Commands = @(
            "Get-MpComputerStatus 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "AntiVirusProducts.txt'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True
    }

    #List of installed software
    UEXAVD_LogMessage $LogLevel.Normal "[$LogPrefix] Collecting list of installed software - HKLM/HKCU"
    
    $InstalledSoftwareM = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall" -ErrorAction SilentlyContinue
    if ($InstalledSoftwareM) {
        foreach ($objM in $InstalledSoftwareM) {
            if ($objM.GetValue('DisplayName') -or $objM.GetValue('DisplayVersion') -or $objM.GetValue('Publisher')) {
                If (!($objM.GetValue('InstallDate'))) { $InstallDateM = "N/A" } else { $InstallDateM = $objM.GetValue('InstallDate') }
                $addlineM = $objM.GetValue('DisplayName') + " - " + $objM.GetValue('DisplayVersion') + " (Installed on: " + $InstallDateM + ") - " + $objM.GetValue('Publisher')
                $addlineM 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "InstalledApps-HKLM.txt")
            }
        }
    } else {
        UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] Software installed under 'HKLM' not found."
    }

    $InstalledSoftwareU = Get-ChildItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall" -ErrorAction SilentlyContinue
    if ($InstalledSoftwareU) {
        foreach ($objU in $InstalledSoftwareU) {
            if ($objU.GetValue('DisplayName') -or $objU.GetValue('DisplayVersion') -or $objU.GetValue('Publisher')) {
                If (!($objU.GetValue('InstallDate'))) { $InstallDateU = "N/A" } else { $InstallDateU = $objU.GetValue('InstallDate') }
                $addlineU = $objU.GetValue('DisplayName') + " - " + $objU.GetValue('DisplayVersion') + " (Installed on: " + $InstallDateU + ") - " + $objU.GetValue('Publisher')
                $addlineU 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "InstalledApps-HKCU.txt")
            }
        }
    } else {
        UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] Software installed under 'HKCU' not found."
    }

    $hfhtml = Get-HotFix -ErrorAction SilentlyContinue | Sort-Object -Property InstalledOn -Descending -ErrorAction SilentlyContinue | Select-Object Description, HotfixID, Caption, InstalledBy, InstalledOn | ConvertTo-Html -Fragment


    #Hoftix list in html format with hyperlinks
    [regex]$rx = "http(s)?:\/\/[a-zA-Z0-9\.\/\?\%=&\$-]+"

    $outhf = '<style>
    BODY { background-color:#E0E0E0; font-family: sans-serif; font-size: small;}
    table { background-color: white; border-collapse:collapse; border: 1px solid black; padding: 10px;}
    td { padding-left: 10px; padding-right: 10px; }
    </style>'

    foreach ($line in $hfhtml) {
        if ($rx.IsMatch($line)) {
            $value = $rx.Match($line).value
            $link = "<a href = ""$value"" target = ""_blank"">$value</a>"
            $outhf += $rx.Replace($line, $link)
        } else {
            $outhf += $line
        }
    }
    $TitleHF = "Updates : " + $env:computername
    ConvertTo-Html -Title $TitleHF -Body $outhf | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "Hotfixes.html")


    $nvidiasmiPath = "C:\Program Files\NVIDIA Corporation\NVSMI\nvidia-smi.exe"
    if (Test-Path $nvidiasmiPath) {
        $Commands = @(
            "cmd /c '$nvidiasmiPath' 2>&1 | Out-File '" + $SysInfoLogFolder + $LogFilePrefix + "nvidia-smi.txt'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True
    }

    UEXAVD_LogMessage $LogLevel.Normal "[$LogPrefix] Collecting PowerShell and .Net version information"
    "PowerShell Information:" 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
    $PSVersionTable | Format-Table Name, Value 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
    ".Net Framework Information:" 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")
    Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name version -EA 0 | Where-Object { $_.PSChildName -Match '^(?!S)\p{L}'} | Select-Object PSChildName, version 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "SystemInfo.txt")

    UEXAVD_LogMessage $LogLevel.Normal "[$LogPrefix] Collecting service details"
    $svc = Get-CimInstance -NameSpace "root\cimv2" -Query "select  ProcessId, DisplayName, StartMode,State, Name, PathName, StartName from Win32_Service" -ErrorAction Continue
    if ($svc) {
        $svc | Sort-Object DisplayName | Format-Table -AutoSize -Property ProcessId, DisplayName, StartMode,State, Name, PathName, StartName | Out-String -Width 400 2>&1 | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "Services.txt")
    }

    UEXAVD_LogMessage $LogLevel.Info "Collecting certificates information"
    Try {
        UEXAVD_CreateLogFolder $CertLogFolder
    } Catch {
        UEXAVD_LogMessage $LogLevel.Error ("Unable to create log folder." + $_.Exception.Message)
        Return
    }
    $Commands = @(
        "certutil -verifystore -v MY 2>&1 | Out-File -Append '" + $CertLogFolder + $LogFilePrefix + "Certificates-My.txt'"
        "certutil -verifystore -v 'AAD Token Issuer' 2>&1 | Out-File -Append '" + $CertLogFolder + $LogFilePrefix + "Certificates-AAD.txt'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True

    UEXAVD_LogMessage $LogLevel.Normal "[$LogPrefix] Exporting additional certificates information"
    $tbCert = New-Object system.Data.DataTable
    $col = New-Object system.Data.DataColumn Store,([string]); $tbCert.Columns.Add($col)
    $col = New-Object system.Data.DataColumn Thumbprint,([string]); $tbCert.Columns.Add($col)
    $col = New-Object system.Data.DataColumn Subject,([string]); $tbCert.Columns.Add($col)
    $col = New-Object system.Data.DataColumn Issuer,([string]); $tbCert.Columns.Add($col)
    $col = New-Object system.Data.DataColumn NotAfter,([DateTime]); $tbCert.Columns.Add($col)
    $col = New-Object system.Data.DataColumn IssuerThumbprint,([string]); $tbCert.Columns.Add($col)
    $col = New-Object system.Data.DataColumn EnhancedKeyUsage,([string]); $tbCert.Columns.Add($col)
    $col = New-Object system.Data.DataColumn SerialNumber,([string]); $tbCert.Columns.Add($col)
    $col = New-Object system.Data.DataColumn SubjectKeyIdentifier,([string]); $tbCert.Columns.Add($col)
    $col = New-Object system.Data.DataColumn AuthorityKeyIdentifier,([string]); $tbCert.Columns.Add($col)
    UEXAVD_GetStore "My"
    $aCert = $tbCert.Select("Store = 'My' ")
    foreach ($cert in $aCert) {
        $aIssuer = $tbCert.Select("SubjectKeyIdentifier = '" + ($cert.AuthorityKeyIdentifier).tostring() + "'")
        if ($aIssuer.Count -gt 0) {
        $cert.IssuerThumbprint = ($aIssuer[0].Thumbprint).ToString()
        }
    }
    $tbcert | Export-Csv ($CertLogFolder + $LogFilePrefix + "Certificates-My.csv") -noType -Delimiter "`t" -Append


    ##### Collecting SPN information

    UEXAVD_LogMessage $LogLevel.Info "Collecting SPN information"

    $Commands = @(
        "setspn -L " + $env:computername + " 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "SPN.txt'"
        "setspn -Q WSMAN/" + $env:computername + " 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "SPN.txt'"
        "setspn -Q WSMAN/" + $fqdn + " 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "SPN.txt'"
        "setspn -F -Q WSMAN/" + $env:computername + " 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "SPN.txt'"
        "setspn -F -Q WSMAN/" + $fqdn + " 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "SPN.txt'"
        "setspn -Q TERMSRV/" + $env:computername + " 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "SPN.txt'"
        "setspn -Q TERMSRV/" + $fqdn + " 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "SPN.txt'"
        "setspn -F -Q TERMSRV/" + $env:computername + " 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "SPN.txt'"
        "setspn -F -Q TERMSRV/" + $fqdn + " 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "SPN.txt'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True

    
    if ($ver -like "*Windows Server*") {
        UEXAVD_LogMessage $LogLevel.Info ('Collecting Remote Desktop Services deployment information')

        $isRDLS = (Get-WindowsFeature -Name RDS-Licensing).InstallState
        $isRDSH = (Get-WindowsFeature -Name RDS-RD-Server).InstallState

        if (($isRDLS -eq "Installed") -or ($isRDSH -eq "Installed")) {
            Try {
                UEXAVD_CreateLogFolder $RDSLogFolder
            } Catch {
                UEXAVD_LogMessage $LogLevel.Error ("Unable to create log folder." + $_.Exception.Message)
                Return
            }
        }

        #Collecting RDLS information
        if ($isRDLS -eq "Installed") {
            " " | Out-File -Append $OutputLogFile
            UEXAVD_LogMessage $LogLevel.Normal "[$LogPrefix] Collecting Remote Desktop License Server database information"
            UEXAVD_GetRDLSDB
        }

        #Collecting RDSH information
        if ($isRDSH -eq "Installed") {
            " " | Out-File -Append $OutputLogFile
            UEXAVD_LogMessage $LogLevel.Normal "[$LogPrefix] Collecting Remote Desktop Session Host information"

            $Commands = @(
                "cmd /c 'wmic /namespace:\\root\CIMV2\TerminalServices PATH Win32_TerminalServiceSetting WHERE (__CLASS !=`"`") CALL GetGracePeriodDays' 2>&1 | Out-File -Append '" + $RDSLogFolder + $LogFilePrefix + "rdsh_GracePeriod.txt'"
            )
            UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True
        }
    }
}

Export-ModuleMember -Function CollectUEX_AVDCoreLog, UEXAVD_GetPackagesLogFiles, UEXAVD_GetMonTables, UEXAVD_GetAVDLogFiles
# SIG # Begin signature block
# MIIntwYJKoZIhvcNAQcCoIInqDCCJ6QCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDnVg6erR21G0ij
# vPUUJ16wM5avw98WyUEatojlPc/cZ6CCDYEwggX/MIID56ADAgECAhMzAAACUosz
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
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgUF2vOhrB
# AGulSsXMLzoium/pPkWjIzyNbROfeLRFd04wQgYKKwYBBAGCNwIBDDE0MDKgFIAS
# AE0AaQBjAHIAbwBzAG8AZgB0oRqAGGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbTAN
# BgkqhkiG9w0BAQEFAASCAQB5bclKwNAwk15hmUiNFF0GaXrvcu42ahxIZ3rgaPnc
# NkkzbkJvTHGXuyrk0V9uJq8HAkt4MB4yHqlnzJTbcnjsTHtvpH+V0lMuonxJNZ1S
# qmE2VrKNQQ9Xdjq32D6+IczHBe4KlGIiHu7oOeHxAf+uteLktuC15UT+R/JWCq+e
# sbiykpVByxKOtgfn0auBI6/V+IrauF8jeW0+7LTvYC96BPdlQOrSTu71PW9vLDQX
# Y85+v4i1I5J3P7wYoLHZ2TpxXjPWuR+MyF2IZCjnDrsUDsj7vGso3llcejuQDjqP
# dQTVuFF/eZNVp4Mv/gFvi+JVHsX/3Yuvgchv095PL9y5oYIXFjCCFxIGCisGAQQB
# gjcDAwExghcCMIIW/gYJKoZIhvcNAQcCoIIW7zCCFusCAQMxDzANBglghkgBZQME
# AgEFADCCAVkGCyqGSIb3DQEJEAEEoIIBSASCAUQwggFAAgEBBgorBgEEAYRZCgMB
# MDEwDQYJYIZIAWUDBAIBBQAEILt37jF8ZQlg6FMPjhF1t6ItAffjrg/sR137mi+j
# pUqDAgZics8gdnQYEzIwMjIwNTE5MDUzODQxLjQ1NFowBIACAfSggdikgdUwgdIx
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
# BgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJKoZIhvcNAQkEMSIEIC/pAv8e
# VjF4PrcpqGirKuAyWAGcHQAP68lUTd71ImPWMIH6BgsqhkiG9w0BCRACLzGB6jCB
# 5zCB5DCBvQQgl3IFT+LGxguVjiKm22ItmO6dFDWW8nShu6O6g8yFxx8wgZgwgYCk
# fjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
# Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAY/zUajrWnLdzAAB
# AAABjzAiBCBOdp10xRSIZGk6Jkz0OTzv6OXDvf6pXcZ4Aa7Rr9VYXjANBgkqhkiG
# 9w0BAQsFAASCAgB9g2ZrHlTBC0nC5MMwexkbmf8TKBC4+64QaY1fvqFWi1kWSG/X
# pjAMADZw6dFgTJ9VhukuPNRFPc9ymb00o/jdyIkj1JaORCyUO8dJZEC/9k8JV7B4
# x1JIwW5/D6dSjXBh5+lw9qtERjOzjdvLPngUVmtAqgmx5q0/b/+WB8yFYsBubT6N
# zn02agdOJw84rifyOKqyOQqHzD9dYIFWLS9cOQuDvMp37/akNA46JB7VgxDTTGbs
# OnzOYlzxCUEf8ntIHY/IRSqVHQ9CEVasE8UCaiBoRDamT2CUXzrQiZtk8FaKCaBg
# YV6ic4uGhxM4LvL0s9uzF4dcwuu6QRKFLPe5TZoknalFgs53hvnjfMBQcR5OCj/t
# aZlU3S9ltsNF22oXHjfrzPLtJWckiRHTmRQD2KaIwWPNHlKXicHhJ5zOq6CbfvzP
# 8XknUglmGuTau4pAVT8Co8oND/DP3RJP2D6g+j6B68b372341i7uCqPhatN6rhJK
# ezC+8bCbVnIA4ORLyelDfssU5x7+4FvZp8G6bDS81OIktVqcvBhb6e1e2fQG0s0h
# X4s4N4skAcvsv6XFKt/K2wRQ5DKh849FPtSyHAHyDzS8spITjw39sCf77KqkyjFs
# CSYIQcgdaQIvORBQ5JbXaL0/AkTLHvsqCdzvo/RWB8I7fsPhbKgY7Q2jGA==
# SIG # End signature block
