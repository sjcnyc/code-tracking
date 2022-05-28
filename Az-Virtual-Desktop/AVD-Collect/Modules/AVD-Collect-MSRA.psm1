<#
.SYNOPSIS
   Scenario module for collecting AVD Remote Assistance data

.DESCRIPTION
   Collect Remote Assistance related troubleshooting data.

.NOTES  
   Authors    : Robert Klemencz (Microsoft CSS) & Alexandru Olariu (Microsoft CSS)
   Requires   : At least PowerShell 5.1 (This module is not for stand-alone use. It is used automatically from within the main AVD-Collect.ps1 script)
   Version    : See AVD-Collect.ps1 version
   Feedback   : Send an e-mail to AVDCollectTalk@microsoft.com
#>

$LogPrefix = "MSRA"

if ($SkipCore) {
    Try {
        UEXAVD_CreateLogFolder $SysInfoLogFolder
        UEXAVD_CreateLogFolder $EventLogFolder
        UEXAVD_CreateLogFolder $RegLogFolder
        UEXAVD_CreateLogFolder $SchtaskFolder
    } Catch {
        UEXAVD_LogMessage $LogLevel.Error ("Unable to create log folder." + $_.Exception.Message)
        Return
    }
}

Function CollectUEX_AVDMSRALog {

    " " | Out-File -Append $OutputLogFile
    UEXAVD_LogMessage $LogLevel.Info ('Collecting Remote Assistance information')

    if ([ADSI]::Exists("WinNT://localhost/Offer Remote Assistance Helpers")) {
        $Commands = @(
            "net localgroup 'Offer Remote Assistance Helpers' 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "LocalGroupsMembership.txt'"
        )
        UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True

        if ([ADSI]::Exists("WinNT://localhost/Distributed COM Users")) {
            $Commands = @(
                "net localgroup 'Distributed COM Users' 2>&1 | Out-File -Append '" + $SysInfoLogFolder + $LogFilePrefix + "LocalGroupsMembership.txt'"
            )
            UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True
        } else {
            UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] 'Distributed COM Users' group not found."
        }

    } else {
        UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] 'Offer Remote Assistance Helpers' group not found."
    }

    $Commands = @(
        "UEXAVD_GetEventLogs 'Microsoft-Windows-RemoteAssistance/Operational' 'RemoteAssistance-Operational'"
        "UEXAVD_GetEventLogs 'Microsoft-Windows-RemoteAssistance/Admin' 'RemoteAssistance-Admin'"
        "UEXAVD_GetRegKeys 'HKLM' 'SYSTEM\CurrentControlSet\Control\Remote Assistance' 'System-CCS-Control-MSRA'"
    )
    UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True

    $Reg = [WMIClass]"\\.\root\default:StdRegProv"
    $DCOMMachineLaunchRestriction = $Reg.GetBinaryValue(2147483650,"software\microsoft\ole","MachineLaunchRestriction").uValue
    $DCOMMachineAccessRestriction = $Reg.GetBinaryValue(2147483650,"software\microsoft\ole","MachineAccessRestriction").uValue
    $DCOMDefaultLaunchPermission = $Reg.GetBinaryValue(2147483650,"software\microsoft\ole","DefaultLaunchPermission").uValue
    $DCOMDefaultAccessPermission = $Reg.GetBinaryValue(2147483650,"software\microsoft\ole","DefaultAccessPermission").uValue

    # Convert the current permissions to SDDL
    $converter = new-object system.management.ManagementClass Win32_SecurityDescriptorHelper
    "Default Access Permission = " + ($converter.BinarySDToSDDL($DCOMDefaultAccessPermission)).SDDL | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "COMSecurity.txt")
    "Default Launch Permission = " + ($converter.BinarySDToSDDL($DCOMDefaultLaunchPermission)).SDDL | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "COMSecurity.txt")
    "Machine Access Restriction = " + ($converter.BinarySDToSDDL($DCOMMachineAccessRestriction)).SDDL | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "COMSecurity.txt")
    "Machine Launch Restriction = " + ($converter.BinarySDToSDDL($DCOMMachineLaunchRestriction)).SDDL | Out-File -Append ($SysInfoLogFolder + $LogFilePrefix + "COMSecurity.txt")

    # Remote Assistance scheduled task
    if (!($ver -like "*Windows 7*")) {
        if (Get-ScheduledTask RemoteAssistance* -ErrorAction Ignore) {
            (Get-ScheduledTask RemoteAssistance*).TaskName | ForEach-Object -Process {
                $Commands = @(
                    "Export-ScheduledTask -TaskName $_ -TaskPath '\Microsoft\Windows\RemoteAssistance' 2>&1 | Out-File -Append '" + $SchtaskFolder + $LogFilePrefix + "schtasks_" + $_ + ".xml'"
                    "Get-ScheduledTaskInfo -TaskName $_ -TaskPath '\Microsoft\Windows\RemoteAssistance' 2>&1 | Out-File -Append '" + $SchtaskFolder + $LogFilePrefix + "schtasks_" + $_ + "_Info.txt'"
                )
                UEXAVD_RunCommands $LogPrefix $Commands -ThrowException:$False -ShowMessage:$True -ShowError:$True
            }
        } else {
            UEXAVD_LogMessage $LogLevel.WarnLogFileOnly "[$LogPrefix] Remote Assistance Scheduled Tasks not found."
        }
    }
}

Export-ModuleMember -Function CollectUEX_AVDMSRALog
# SIG # Begin signature block
# MIInqwYJKoZIhvcNAQcCoIInnDCCJ5gCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBkNn462Utj1y6N
# ybuCaJ3vKMd7kxQi0Z1r1y1nd+LkaKCCDYEwggX/MIID56ADAgECAhMzAAACUosz
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
# RcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIZgDCCGXwCAQEwgZUwfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAlKLM6r4lfM52wAAAAACUjAN
# BglghkgBZQMEAgEFAKCBrjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgar1rcLtU
# H2MKrzUoQCGfZ18vnA4Eftfi6eLDz2bzhj4wQgYKKwYBBAGCNwIBDDE0MDKgFIAS
# AE0AaQBjAHIAbwBzAG8AZgB0oRqAGGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbTAN
# BgkqhkiG9w0BAQEFAASCAQB3DySCGEYGc0HC2QlCjFSUiTi0Nse/iQMRNWOtWAFe
# 7Svo4HYjn+5TuscCI4ZSbWPCDFU0Gr0fgs0x38RJ06SR975rH7o7zDu6OnaoKFZN
# k5iy0/hbFFS59q0wPB4PNeuc/K45fiMwK4vs/XGeawXMoiumH4SIOln4OFxGZuwV
# EXuQ2b7M8T1LIlZJTDs5+nAXIsTxtxxHjV/2Iu4YNI2u7aUR7ddjQlyEx+ri+TTX
# f1bRbdhN3v2Yti+3M1agrPONeGwJToojoq1sG1yBYw2kQNLS425wZ4829BC613ZT
# cJjcEhpHN7ZtYVOZ1GUhZ7+uV0uwr4UGD4U2noB0vQYnoYIXCjCCFwYGCisGAQQB
# gjcDAwExghb2MIIW8gYJKoZIhvcNAQcCoIIW4zCCFt8CAQMxDzANBglghkgBZQME
# AgEFADCCAVMGCyqGSIb3DQEJEAEEoIIBQgSCAT4wggE6AgEBBgorBgEEAYRZCgMB
# MDEwDQYJYIZIAWUDBAIBBQAEIPoG5Hl6nCUH4KysCqGb4IkMMMsP2UObAX5aQOov
# dwGVAgZifCxEUQgYETIwMjIwNTE5MDUzODQ4LjdaMASAAgH0oIHUpIHRMIHOMQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSkwJwYDVQQLEyBNaWNy
# b3NvZnQgT3BlcmF0aW9ucyBQdWVydG8gUmljbzEmMCQGA1UECxMdVGhhbGVzIFRT
# UyBFU046NEQyRi1FM0RELUJFRUYxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0
# YW1wIFNlcnZpY2WgghFfMIIHEDCCBPigAwIBAgITMwAAAbCh44My6I07wAABAAAB
# sDANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAe
# Fw0yMjAzMDIxODUxNDJaFw0yMzA1MTExODUxNDJaMIHOMQswCQYDVQQGEwJVUzET
# MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMSkwJwYDVQQLEyBNaWNyb3NvZnQgT3BlcmF0
# aW9ucyBQdWVydG8gUmljbzEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046NEQyRi1F
# M0RELUJFRUYxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Uw
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCcxm07DNfSgp0HOUQu1aIJ
# cklzCi7rf8llj0Fg+lQJSYAXsVSsdp9c4F96P8QNmYGfzRRnIDQ0Qie5iYjnlu8X
# h56DVz5YOxI2FrpX5N6DgI+muzteRr3JKWLLy3MfqPEnvAq3yG+NBCfFtEMeEyF3
# 9Mg8ACeP6jveHSf4Rmm3iWIOBqdBtLkJocBaLwFkx5Q9XIvrKd+gMU/cCIR6sP+9
# LczL65wxe45kI2lVD54zoDzshVmYla+3uq5EpeGp09bS79t0loV6jLNeMKJb+GXk
# HFj/OK1dha69Sm8JCGtL5R45b+MRvWup5U0X6NAmFEA362TjFwiOSnADdgWen1W9
# ParQnbFnTTcQdMuJcDI57jZsfORTX8z3DGY5sABfWkVFDCx7+tuiOu7dfnWaFT6S
# qn0jZhrVbfQxE1pJg4qZxoOPgXU6Zb4BlavRdymTwxR2m8Wy6Uln11vdDGVzrhR/
# MgjMwyTVM3sgKsrRRci2Yq94+E9Rse5UXgjlD8Nablc21irKVezKHWY7TfyFFnVS
# HZNxz6eEDdcMHVb3VzrGHYRvJIIxsgGSA+aK+wv++YcikG+RdGfhHtOLmPSvrA2d
# 5d8/E0GVgH2Lq22QjFlp5iVbLuVeD0eTzvlOg+7QLTLzFCzWIm0/frMVWSv1kHq9
# iSfat2e5YxbOJYKZn3OgFQIDAQABo4IBNjCCATIwHQYDVR0OBBYEFDrfASQ3ASZu
# HcugEmR61yBH1jY/MB8GA1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8G
# A1UdHwRYMFYwVKBSoFCGTmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMv
# Y3JsL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBs
# BggrBgEFBQcBAQRgMF4wXAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0
# LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUy
# MDIwMTAoMSkuY3J0MAwGA1UdEwEB/wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwgw
# DQYJKoZIhvcNAQELBQADggIBAN1z4oebDbVHwMi55V6ujGUqQodExfrhvp4SCeOP
# /3DHEBhFYmdjdutzcL60IwhTp4v/qMX++o3JlIXCli15PYYXe73xQYWWc3BeWjbN
# O1JYoLNuKb3mrBboZieMvNjmJtRtTkWLBZ3WXbxf/za2BsWl6lDZUR0JbJFf6ZnH
# KjtzousCx3Dwdf1kUyybWGyIosBP7kxRBRC+OcFg/9ZkwjxJBV94ZYlxMqcV83Wd
# ZOl6hk8rBgLS11AeyAugh9umMoCkLlxvEI3CQQFBv/Rd8jWTnWxb5+xYp2cjXCFS
# 8ZXe4dGxC30M4SI3pY/ubASoS3GhVNL2425n9FhDYBZp8iTYjKy+/9hWDi7IIkA2
# yceg6ctRH77kRrHS+X/o1VXbOaDGiq4cYFe6BKG6wOmeep51mDeO7MMKLrnB39Mp
# tQ0Fh8tgxzhUUTe8r/vs3rNBkgjo0UWDyu669UHPjt57HetODoJuZ0fUKoTjnNjk
# E677UoFwUrbubxelvAz3LJ7Od3EOIHXEdWPTYOSGBMMQmc82LKvaGpcZR/mR/wOi
# e2THkjSjZK1z8eqaRV1MR7gt5OJs1cmTRlj/2YHFDotqldN5uiJsrb4tZHxnumHQ
# od9jzoFnjR/ZXyrfndTPquCISS5l9BNmWSAmBG/UNK6JnjF/BmfnG4bjbBYpiYGv
# 3447MIIHcTCCBVmgAwIBAgITMwAAABXF52ueAptJmQAAAAAAFTANBgkqhkiG9w0B
# AQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
# BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAG
# A1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIwMTAw
# HhcNMjEwOTMwMTgyMjI1WhcNMzAwOTMwMTgzMjI1WjB8MQswCQYDVQQGEwJVUzET
# MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV
# TWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1T
# dGFtcCBQQ0EgMjAxMDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAOTh
# pkzntHIhC3miy9ckeb0O1YLT/e6cBwfSqWxOdcjKNVf2AX9sSuDivbk+F2Az/1xP
# x2b3lVNxWuJ+Slr+uDZnhUYjDLWNE893MsAQGOhgfWpSg0S3po5GawcU88V29YZQ
# 3MFEyHFcUTE3oAo4bo3t1w/YJlN8OWECesSq/XJprx2rrPY2vjUmZNqYO7oaezOt
# gFt+jBAcnVL+tuhiJdxqD89d9P6OU8/W7IVWTe/dvI2k45GPsjksUZzpcGkNyjYt
# cI4xyDUoveO0hyTD4MmPfrVUj9z6BVWYbWg7mka97aSueik3rMvrg0XnRm7KMtXA
# hjBcTyziYrLNueKNiOSWrAFKu75xqRdbZ2De+JKRHh09/SDPc31BmkZ1zcRfNN0S
# idb9pSB9fvzZnkXftnIv231fgLrbqn427DZM9ituqBJR6L8FA6PRc6ZNN3SUHDSC
# D/AQ8rdHGO2n6Jl8P0zbr17C89XYcz1DTsEzOUyOArxCaC4Q6oRRRuLRvWoYWmEB
# c8pnol7XKHYC4jMYctenIPDC+hIK12NvDMk2ZItboKaDIV1fMHSRlJTYuVD5C4lh
# 8zYGNRiER9vcG9H9stQcxWv2XFJRXRLbJbqvUAV6bMURHXLvjflSxIUXk8A8Fdsa
# N8cIFRg/eKtFtvUeh17aj54WcmnGrnu3tz5q4i6tAgMBAAGjggHdMIIB2TASBgkr
# BgEEAYI3FQEEBQIDAQABMCMGCSsGAQQBgjcVAgQWBBQqp1L+ZMSavoKRPEY1Kc8Q
# /y8E7jAdBgNVHQ4EFgQUn6cVXQBeYl2D9OXSZacbUzUZ6XIwXAYDVR0gBFUwUzBR
# BgwrBgEEAYI3TIN9AQEwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5taWNyb3Nv
# ZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMBMGA1UdJQQMMAoGCCsG
# AQUFBwMIMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQEAwIBhjAP
# BgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFNX2VsuP6KJcYmjRPZSQW9fOmhjE
# MFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kv
# Y3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNybDBaBggrBgEF
# BQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9w
# a2kvY2VydHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3J0MA0GCSqGSIb3DQEB
# CwUAA4ICAQCdVX38Kq3hLB9nATEkW+Geckv8qW/qXBS2Pk5HZHixBpOXPTEztTnX
# wnE2P9pkbHzQdTltuw8x5MKP+2zRoZQYIu7pZmc6U03dmLq2HnjYNi6cqYJWAAOw
# Bb6J6Gngugnue99qb74py27YP0h1AdkY3m2CDPVtI1TkeFN1JFe53Z/zjj3G82jf
# ZfakVqr3lbYoVSfQJL1AoL8ZthISEV09J+BAljis9/kpicO8F7BUhUKz/AyeixmJ
# 5/ALaoHCgRlCGVJ1ijbCHcNhcy4sa3tuPywJeBTpkbKpW99Jo3QMvOyRgNI95ko+
# ZjtPu4b6MhrZlvSP9pEB9s7GdP32THJvEKt1MMU0sHrYUP4KWN1APMdUbZ1jdEgs
# sU5HLcEUBHG/ZPkkvnNtyo4JvbMBV0lUZNlz138eW0QBjloZkWsNn6Qo3GcZKCS6
# OEuabvshVGtqRRFHqfG3rsjoiV5PndLQTHa1V1QJsWkBRH58oWFsc/4Ku+xBZj1p
# /cvBQUl+fpO+y/g75LcVv7TOPqUxUYS8vwLBgqJ7Fx0ViY1w/ue10CgaiQuPNtq6
# TPmb/wrpNPgkNWcr4A245oyZ1uEi6vAnQj0llOZ0dFtq0Z4+7X6gMTN9vMvpe784
# cETRkPHIqzqKOghif9lwY1NNje6CbaUFEMFxBmoQtB1VM1izoXBm8qGCAtIwggI7
# AgEBMIH8oYHUpIHRMIHOMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3Rv
# bjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
# aW9uMSkwJwYDVQQLEyBNaWNyb3NvZnQgT3BlcmF0aW9ucyBQdWVydG8gUmljbzEm
# MCQGA1UECxMdVGhhbGVzIFRTUyBFU046NEQyRi1FM0RELUJFRUYxJTAjBgNVBAMT
# HE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2WiIwoBATAHBgUrDgMCGgMVAAKe
# L5Dd3w+RTQVWGZJWXkvyRTwYoIGDMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# UENBIDIwMTAwDQYJKoZIhvcNAQEFBQACBQDmL+TrMCIYDzIwMjIwNTE5MDEzNDM1
# WhgPMjAyMjA1MjAwMTM0MzVaMHcwPQYKKwYBBAGEWQoEATEvMC0wCgIFAOYv5OsC
# AQAwCgIBAAICHpUCAf8wBwIBAAICERAwCgIFAOYxNmsCAQAwNgYKKwYBBAGEWQoE
# AjEoMCYwDAYKKwYBBAGEWQoDAqAKMAgCAQACAwehIKEKMAgCAQACAwGGoDANBgkq
# hkiG9w0BAQUFAAOBgQB6ZzLoZKJ/JERWO4WrP1avyMGC9MOV3Ne+A36t4/l+9MgX
# uolLYLz6vRzclvlaxreMCS7x79NYWAptzurNs4+lNvQFSarafWt1pZqnfRMGuuZ+
# 488rzxdvcQQrdpGMWHNRwTo3d1EFt0lgBt3OG3jAkbnjktbko/T3XcmXQNbFzzGC
# BA0wggQJAgEBMIGTMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAB
# sKHjgzLojTvAAAEAAAGwMA0GCWCGSAFlAwQCAQUAoIIBSjAaBgkqhkiG9w0BCQMx
# DQYLKoZIhvcNAQkQAQQwLwYJKoZIhvcNAQkEMSIEIHfIJ+4KgdQWre6SR1trT9rm
# NF4iyf+3TzDa03gTYGHTMIH6BgsqhkiG9w0BCRACLzGB6jCB5zCB5DCBvQQgzQYL
# Q3fLn/Sk4xn9RuuyHypnDRSZnlk3eopQMucVhKAwgZgwgYCkfjB8MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQg
# VGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAbCh44My6I07wAABAAABsDAiBCBLvcL3
# tcnORz9CO85jG8zkQgoNDqsFm0tI+MX8RHOswjANBgkqhkiG9w0BAQsFAASCAgA5
# O49SWNx3jFLwopY7fgmo76XXUKIUW7e5UeFDBOoaLH5N9BU5w1ksAwvybRYiI7sc
# fZxFSUxzee9imj2pp5pfBEKReDxKdImyX44lkOBMKNKiO5szfvknihvOvkXddTHD
# xk0PreGGEk4wE7ydkzARsiLC54cmZzOpfp72xnC3ZZq6YSoXIkr0pM8Sp2MPRme8
# ENXIJO5Hemd/KPjQ6zL7dPjmvm9ITzPlUmBQYL7Wqgt0IJDvSFmniFbW/68ED1fx
# Zh5ZdUlblfRrG3hf8XuMsEr6QgOM6FQpGxxZKjItqD15FZxye50jZSCx2bmfW2/q
# zz+AjUfl9aZuvug/iBvf1XWPYVcj0/5edsrvbPvz2GqN3bsnFRZ/yhC7ZF/l130i
# PS+O9+n1ddWwtC8X3Qzeb4lNfzauxehUuPet5TRvKEGLH7Zv+za0Qn769YF1hXit
# mrA7Spl31x5sQGYI8sj7GLYNO6cs9Z8rIhwVdeQ2tUsfwjpi5XE3YnF8WNPV5F6x
# JjyQIpoE5dL3HaBxOmflVzLhNqPGrd5WOACMBFRHu8eNMt6uZptQTqZRpPqkg47/
# rL5u9XfmvhcaTQj+JajlX/h4dh1D5u3Lmmry/evzFef71rmEP52Q9kI5rJQpGsyN
# Zx7srN+kD8CR3msXj5g9p7D0ZabVqEISuGGGfJid7Q==
# SIG # End signature block
