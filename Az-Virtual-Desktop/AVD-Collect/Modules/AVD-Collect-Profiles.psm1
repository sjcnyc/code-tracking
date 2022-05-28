<#
.SYNOPSIS
   Scenario module for collecting AVD Profiles data

.DESCRIPTION
   Collect Profiles related troubleshooting data (incl. FSLogix, OneDrive).

.NOTES  
   Authors    : Robert Klemencz (Microsoft CSS) & Alexandru Olariu (Microsoft CSS)
   Requires   : At least PowerShell 5.1 (This module is not for stand-alone use. It is used automatically from within the main AVD-Collect.ps1 script)
   Version    : See AVD-Collect.ps1 version
   Feedback   : Send an e-mail to AVDCollectTalk@microsoft.com
#>

$LogPrefix = "Profiles"

if ($SkipCore) {
    Try {
        UEXAVD_CreateLogFolder $SysInfoLogFolder
        UEXAVD_CreateLogFolder $RegLogFolder
        UEXAVD_CreateLogFolder $EventLogFolder
    } Catch {
        UEXAVD_LogMessage $LogLevel.Error ("Unable to create log folder." + $_.Exception.Message)
        Return
    }
}

Function global:UEXAVD_GetFSLogixLogFiles {
    Param([Parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string]$LogFilePath)

    if (Test-path -path "$LogFilePath") {
        Copy-Item $LogFilePath $FSLogixLogFolder -Recurse -ErrorAction Continue 2>&1 | Out-Null
    } else {
        UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] '$LogFilePath' folder not found."
    }
}

Function CollectUEX_AVDProfilesLog{
    " " | Out-File -Append $OutputLogFile
    UEXAVD_LogMessage $LogLevel.Info ('Collecting Profiles information (incl. FSLogix if present)')

    if (Test-path -path 'C:\Program Files\FSLogix') {

        Try {
            UEXAVD_CreateLogFolder $FSLogixLogFolder
        } Catch {
            UEXAVD_LogMessage $LogLevel.Error ("Unable to create log folder." + $_.Exception.Message)
            Return
        }

        #Collecting FSLogix Logs
        $Commands = @(
            "UEXAVD_GetFSLogixLogFiles 'C:\ProgramData\FSLogix\Logs\*'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True

        $cmd = "c:\program files\fslogix\apps\frx.exe"

        if (Test-path -path 'C:\Program Files\FSLogix\apps') {
            UEXAVD_LogMessage $LogLevel.Normal ("[$LogPrefix] Running frx.exe version")
            Invoke-Expression "& '$cmd' + 'version'" | Out-File -FilePath ($FSLogixLogFolder + $LogFilePrefix + "frx-list.txt") -Append

            "`n====================================================================================`n" | Out-File -FilePath ($FSLogixLogFolder + $LogFilePrefix + "Frx-list.txt") -Append

            UEXAVD_LogMessage $LogLevel.Normal ("[$LogPrefix] Running frx.exe list-redirects")
            Invoke-Expression "& '$cmd' + 'list-redirects'" | Out-File -FilePath ($FSLogixLogFolder + $LogFilePrefix + "frx-list.txt") -Append

            "`n====================================================================================`n" | Out-File -FilePath ($FSLogixLogFolder + $LogFilePrefix + "Frx-list.txt") -Append

            UEXAVD_LogMessage $LogLevel.Normal ("[$LogPrefix] Running frx.exe list-rules")
            Invoke-Expression "& '$cmd' + 'list-rules'" | Out-File -FilePath ($FSLogixLogFolder + $LogFilePrefix + "frx-list.txt") -Append
        } else {
            UEXAVD_LogMessage $LogLevel.WarnLogFileOnly ("[$LogPrefix] 'C:\Program Files\FSLogix\apps' folder not found.")
        }

        $Commands = @(
            "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\FSLogix' 'SW-FSLogix'"
            "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Policies\FSLogix' 'SW-Policies-FSLogix'"
            "UEXAVD_GetRegKeys 'HKLM' 'SYSTEM\CurrentControlSet\Services\frxccd' 'System-CCS-Svc-frxccd'"
            "UEXAVD_GetRegKeys 'HKLM' 'SYSTEM\CurrentControlSet\Services\frxccds' 'System-CCS-Svc-frxccds'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True

        #if applicable, removing accountname and account key from the exported CCDLocations reg key for security reasons
        $ccdRegOutP = $RegLogFolder + $LogFilePrefix + "HKLM-SW-FSLogix.txt"
        $ccdContentP = Get-Content -Path $ccdRegOutP
        $ccdReplaceP = foreach ($ccdItemP in $ccdContentP) {
            if ($ccdItemP -like "*CCDLocations*") {
                $var1P = $ccdItemP -split ";"
                $var2P = foreach ($varItemP in $var1P) {
                            if ($varItemP -like "AccountName=*") { $varItemP = "AccountName=xxxxxxxxxxxxxxxx"; $varItemP }
                            elseif ($varItemP -like "AccountKey=*") { $varItemP = "AccountKey=xxxxxxxxxxxxxxxx"; $varItemP }
                            else { $varItemP }
                        }
                $var3P = $var2P -join ";"
                $var3P
            } else {
                $ccdItemP
            }
        }
        $ccdReplaceP | Set-Content -Path $ccdRegOutP

        $ccdRegOutO = $RegLogFolder + $LogFilePrefix + "HKLM-SW-Policies-FSLogix.txt"
        $ccdContentO = Get-Content -Path $ccdRegOutO
        $ccdReplaceO = foreach ($ccdItemO in $ccdContentO) {
            if ($ccdItemO -like "*CCDLocations*") {
                $var1O = $ccdItemO -split ";"
                $var2O = foreach ($varItemO in $var1O) {
                            if ($varItemO -like "AccountName=*") { $varItemO = "AccountName=xxxxxxxxxxxxxxxx"; $varItemO }
                            elseif ($varItemO -like "AccountKey=*") { $varItemO = "AccountKey=xxxxxxxxxxxxxxxx"; $varItemO }
                            else { $varItemO }
                        }
                $var3O = $var2O -join ";"
                $var3O
            } else {
                $ccdItemO
            }
        }
        $ccdReplaceO | Set-Content -Path $ccdRegOutO

    } else {
        UEXAVD_LogMessage $LogLevel.WarnLogFileOnly ("[$LogPrefix] 'C:\Program Files\FSLogix' folder not found.")
    }

    #Collecting profile reg keys
    $Commands = @(
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Microsoft\Windows Defender\Exclusions' 'SW-MS-WinDef-Exclusions'"
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions' 'SW-GPO-MS-WinDef-Exclusions'"
        "UEXAVD_GetRegKeys 'HKCU' 'SOFTWARE\Microsoft\Office' 'SW-MS-Office'"
        "UEXAVD_GetRegKeys 'HKCU' 'SOFTWARE\Policies\Microsoft\office' 'SW-Policies-MS-Office'"
        "UEXAVD_GetRegKeys 'HKCU' 'SOFTWARE\Microsoft\OneDrive' 'SW-MS-OneDrive'"
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Microsoft\OneDrive' 'SW-MS-OneDrive'"
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Policies\Microsoft\OneDrive' 'SW-Pol-MS-OneDrive'"
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Microsoft\Windows Search' 'SW-MS-WindowsSearch'"
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList' 'SW-MS-WinNT-CV-ProfileList'"
        "UEXAVD_GetRegKeys 'HKCU' 'Volatile Environment' 'VolatileEnvironment'"
        "UEXAVD_GetRegKeys 'HKLM' 'SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers' 'SW-MS-Win-CV-Auth-CredProviders'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True

    #Collecting user/profile information
    $Commands = @(
        "Whoami /all 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "WhoAmI-all.txt'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True

    #Collecting profiles event logs
    $Commands = @(
        "UEXAVD_GetEventLogs 'Microsoft-Windows-GroupPolicy/Operational' 'GroupPolicy-Operational'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-User Profile Service/Operational' 'UserProfileService-Operational'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-VHDMP-Operational' 'VHDMP-Operational'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-SMBClient/Operational' 'SMBClient-Operational'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-SMBClient/Connectivity' 'SMBClient-Connectivity'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-SMBClient/Security' 'SMBClient-Security'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-SMBServer/Operational' 'SMBServer-Operational'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-SMBServer/Connectivity' 'SMBServer-Connectivity'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-SMBServer/Security' 'SMBServer-Security'"
        "UEXAVD_GetEventLogs 'Microsoft-FSLogix-Apps/Admin' 'FSLogix-Apps-Admin'"
        "UEXAVD_GetEventLogs 'Microsoft-FSLogix-Apps/Operational' 'FSLogix-Apps-Operational'"
        "UEXAVD_GetEventLogs 'Microsoft-FSLogix-CloudCache/Admin' 'FSLogix-CloudCache-Admin'"
        "UEXAVD_GetEventLogs 'Microsoft-FSLogix-CloudCache/Operational' 'FSLogix-CloudCache-Operational'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True


    #Collecting FSLogix group memberships
    if ([ADSI]::Exists("WinNT://localhost/FSLogix ODFC Exclude List")) {
        $Commands = @(
            "net localgroup 'FSLogix ODFC Exclude List' 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "LocalGroupsMembership.txt'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True
    } else {
        UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] 'FSLogix ODFC Exclude List' group not found."
    }

    if ([ADSI]::Exists("WinNT://localhost/FSLogix ODFC Include List")) {
        $Commands = @(
            "net localgroup 'FSLogix ODFC Include List' 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "LocalGroupsMembership.txt'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True
    } else {
        UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] 'FSLogix ODFC Include List' group not found."
    }

    if ([ADSI]::Exists("WinNT://localhost/FSLogix Profile Exclude List")) {
        $Commands = @(
            "net localgroup 'FSLogix Profile Exclude List' 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "LocalGroupsMembership.txt'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True
    } else {
        UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] 'FSLogix Profile Exclude List' group not found."
    }

    if ([ADSI]::Exists("WinNT://localhost/FSLogix Profile Include List")) {
        $Commands = @(
            "net localgroup 'FSLogix Profile Include List' 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "LocalGroupsMembership.txt'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True
    } else {
        UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] 'FSLogix Profile Include List' group not found."
    }

    #folder permissions
    if (UEXAVD_TestRegistryValue -path "HKLM:\SOFTWARE\FSLogix\Profiles\" -value "VHDLocations") {
        $pvhd = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\FSLogix\Profiles\" -name "VHDLocations"

        $Commands = @(
            "icacls $pvhd 2>&1 | Out-File -Append " + $FSLogixLogFolder + $LogFilePrefix + "folderPermissions.txt"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True
    }

    if (UEXAVD_TestRegistryValue -path "HKLM:\SOFTWARE\Policies\FSLogix\ODFC\" -value "VHDLocations") {
        $ovhd = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Policies\FSLogix\ODFC\" -name "VHDLocations"

        $Commands = @(
            "icacls $ovhd 2>&1 | Out-File -Append " + $FSLogixLogFolder + $LogFilePrefix + "folderPermissions.txt"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True
    }
}

Export-ModuleMember -Function CollectUEX_AVDProfilesLog
# SIG # Begin signature block
# MIIntwYJKoZIhvcNAQcCoIInqDCCJ6QCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBpLVq2fxsO9nMa
# Eu0Ik+Uzk4zfYHV/1ft4XwZNin/O0KCCDYEwggX/MIID56ADAgECAhMzAAACUosz
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
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg0M1PoTdV
# rRnPaHwccrQ+5EuQeuugoC6Cq2S3Kmry3lowQgYKKwYBBAGCNwIBDDE0MDKgFIAS
# AE0AaQBjAHIAbwBzAG8AZgB0oRqAGGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbTAN
# BgkqhkiG9w0BAQEFAASCAQBP0EF+GOFLHt5QEmNP/zwQ+j64ItQ/yMQtS7cBMpkm
# yRsgJEhECDHYE41/1+EuJBp44ivTVifQeuA2RAQNT3fQ9GkyNQwQhaoXdZpFfUTU
# MdVJfY9k6i30I44PXD2WUo+0SP2xSHfOn0jCiMmg+VViMXjW7TYtKYNL874Itref
# 74chGkOlruJKk5F6mI/70G5Y2CCkaWLDvAwdCroHrGGnhabUC7LYcummn9iJpQIz
# v9Iclc7HDAOV/CL6kZ2HK/F+FP563Fzq/csHQhRIJZAACawlbudDj8z4mHa5XZMq
# jSYev3G1r9X/uy2jHn5t6oUR32VkgH5s3ADy2bmzkv+MoYIXFjCCFxIGCisGAQQB
# gjcDAwExghcCMIIW/gYJKoZIhvcNAQcCoIIW7zCCFusCAQMxDzANBglghkgBZQME
# AgEFADCCAVkGCyqGSIb3DQEJEAEEoIIBSASCAUQwggFAAgEBBgorBgEEAYRZCgMB
# MDEwDQYJYIZIAWUDBAIBBQAEIOKsrvYFZwu35m1hkpNRn5ZtOK4DkO+isxYEiPxd
# 92o5AgZics8gdqcYEzIwMjIwNTE5MDUzODQyLjExOVowBIACAfSggdikgdUwgdIx
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
# BgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJKoZIhvcNAQkEMSIEIFx11GAP
# 2LRq4lcrnUL1SUf6Yj2MBZ8DEVwBFlbrCaLhMIH6BgsqhkiG9w0BCRACLzGB6jCB
# 5zCB5DCBvQQgl3IFT+LGxguVjiKm22ItmO6dFDWW8nShu6O6g8yFxx8wgZgwgYCk
# fjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
# Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAY/zUajrWnLdzAAB
# AAABjzAiBCBOdp10xRSIZGk6Jkz0OTzv6OXDvf6pXcZ4Aa7Rr9VYXjANBgkqhkiG
# 9w0BAQsFAASCAgAScVM/bbXN2Q3Co+uKi3tNRQo6OJO4EyTL8NIxSX9SgY/afjhZ
# I8LghGjk8GS4V7A6ZrcKIhq6p2PqlQUqUrZ7CnK+oh+Q3jya/sjCI76Q/y9HLaQQ
# ByjkvTbGD3EVQuL+4AwThfwfgJ8Bj1Urt6+fmkDJNnAtk58uc8NVMUUogEL1uDkh
# tjsnQpCqLCvgAoZD0NmlcZeSEQ7d+67+wZ0rsYy/XLIRQnCKogbp+dYyAycPfH0a
# CI6hJjhR0BSH/8HazgbYE3DsEd9YEvpW5k93PFlQG4Fo2ElA8L6N1Bm5JjdoJ8Jc
# 1xq1F4mdGlpbh2wTHs6+VBN9pdGgpF6E8ggekQ/8NQ42R9fW59C5V1IMJ04zLnSH
# wCUWQmwztsJjDaZ/S7Gz6cfvqPTvphco1DJ18sHYNFHIVRz4kNLpZQWbYi1aOXFz
# 4ocdmBWLnYuKvrWWFLOxB+LLhewW0DcFlUikOfrXfieOn/0cplf/m+Y8QW+QANHx
# 5XbkaQkf3Q3SDc5EMyf3els7/jqY0geTBLtoV1v/RcK1ZXbb4HALGCZ74EjU2HpE
# LpPvT7/GIbrF8lfUUXD7amEoXaw/WQ1Vz5UZmW8IRX1W0pQK1mXP5vfhXx2e2I3x
# bhwe6+4SxIgBIMTR/XcsUahdPsj0Q4Z4PxeMr+JGz7eQJp9a1PfRsTrvng==
# SIG # End signature block
