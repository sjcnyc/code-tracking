
<#PSScriptInfo

.VERSION 1.1

.GUID ff901998-923d-49d2-accf-9ad9717c2634

.AUTHOR sconnea

.COMPANYNAME 

.COPYRIGHT 

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#> 



<# 

.DESCRIPTION 
Loads Exchange Online MFA

#> 

Param()


function Install-ClickOnce {
    [CmdletBinding()]
    Param(
        $Manifest = "https://cmdletpswmodule.blob.core.windows.net/exopsmodule/Microsoft.Online.CSE.PSModule.Client.application",
        $ElevatePermissions = $true
    )
    Try {
        Add-Type -AssemblyName System.Deployment

        Write-Verbose "Start installation of ClockOnce Application $Manifest "

        $RemoteURI = [URI]::New( $Manifest , [UriKind]::Absolute)
        if (-not  $Manifest) {
            throw "Invalid ConnectionUri parameter '$ConnectionUri'"
        }
        $HostingManager = New-Object System.Deployment.Application.InPlaceHostingManager -ArgumentList $RemoteURI , $False
        Register-ObjectEvent -InputObject $HostingManager -EventName GetManifestCompleted -Action {
            new-event -SourceIdentifier "ManifestDownloadComplete"
        } | Out-Null

        Register-ObjectEvent -InputObject $HostingManager -EventName DownloadApplicationCompleted -Action {
            new-event -SourceIdentifier "DownloadApplicationCompleted"
        } | Out-Null

        $HostingManager.GetManifestAsync()

        $event = Wait-Event -SourceIdentifier "ManifestDownloadComplete" -Timeout 5
        if ($event ) {
            $event | Remove-Event
            Write-Verbose "ClickOnce Manifest Download Completed"

            $HostingManager.AssertApplicationRequirements($ElevatePermissions)
            $HostingManager.DownloadApplicationAsync()
            $event = Wait-Event -SourceIdentifier "DownloadApplicationCompleted" -Timeout 15
            if ($event ) {
                $event | Remove-Event
                Write-Verbose "ClickOnce Application Download Completed"
            }
            else {
                Write-error "ClickOnce Application Download did not complete in time (15s)"
            }
        }
        else {
            Write-error "ClickOnce Manifest Download did not complete in time (5s)"
        }
    } finally {
        Get-EventSubscriber| Where-Object {$_.SourceObject.ToString() -eq 'System.Deployment.Application.InPlaceHostingManager'} | Unregister-Event
    }
}

function Get-ClickOnce {
    [CmdletBinding()]
    Param(
        $ApplicationName = "Microsoft Exchange Online Powershell Module"
    )
    $InstalledApplicationNotMSI = Get-ChildItem HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall | foreach-object {Get-ItemProperty $_.PsPath}
    return $InstalledApplicationNotMSI | Where-Object { $_.displayname -match $ApplicationName } | Select-Object -First 1
}

Function Test-ClickOnce {
    [CmdletBinding()]
    Param(
        $ApplicationName = "Microsoft Exchange Online Powershell Module"
    )
    return ( (Get-ClickOnce -ApplicationName $ApplicationName) -ne $null)
}

function Uninstall-ClickOnce {
    [CmdletBinding()]
    Param(
        $ApplicationName = "Microsoft Exchange Online Powershell Module"
    )
    $app = Get-ClickOnce -ApplicationName $ApplicationName

    if ($App) {
        $selectedUninstallString = $App.UninstallString
        $parts = $selectedUninstallString.Split(' ', 2)
        Start-Process -FilePath $parts[0] -ArgumentList $parts[1] -Wait
        $app = Get-ClickOnce -ApplicationName $ApplicationName
        if ($app) {
            Write-verbose 'De-installation aborted'
        }
        else {
            Write-verbose 'De-installation completed'
        }
    }
    else {
    }
}

Function Start-ExchangeMFAModule {
    [CmdletBinding()]
    Param ()
    $Modules = @(Get-ChildItem -Path "$($env:LOCALAPPDATA)\Apps\2.0" -Filter "Microsoft.Exchange.Management.ExoPowershellModule.manifest" -Recurse )
    if ($Modules.Count -ne 1 ) {
        throw "No or Multiple Modules found : Count = $($Modules.Count )"
    }
    else {
        $ModuleName = Join-path $Modules[0].Directory.FullName "Microsoft.Exchange.Management.ExoPowershellModule.dll"
        Write-Verbose "Start Importing MFA Module"
        if ($PSVersionTable.PSVersion -ge "5.0") {
            Import-Module -FullyQualifiedName $ModuleName  -Force
        }
        else {
            Import-Module $ModuleName  -Force
        }
        $ScriptName = Join-path $Modules[0].Directory.FullName "CreateExoPSSession.ps1"
        if (Test-Path $ScriptName) {
            return $ScriptName
        }
        else {
            throw "Script not found"
            return $null
        }
    }
}

if ((Test-ClickOnce -ApplicationName "Microsoft Exchange Online Powershell Module" ) -eq $false) {
    Install-ClickOnce -Manifest "https://cmdletpswmodule.blob.core.windows.net/exopsmodule/Microsoft.Online.CSE.PSModule.Client.application"
}
$script = Start-ExchangeMFAModule -Verbose

. $Script

$ProxySetting = New-PSSessionOption -ProxyAccessType IEConfig
Connect-EXOPSSession -PSSessionOption $ProxySetting
