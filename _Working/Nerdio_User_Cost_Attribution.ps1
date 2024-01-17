$THUMBPRINT = "E63310F5BE89B43200220F17077733B0FF249989"
$CONNECTOR_BLOB = "https://nmwextensions.blob.core.windows.net/cloud-clarity/NerdioReportingSigned_v2.pqx?sv=2021-10-04&st=2023-09-14T14%3A24%3A55Z&se=2123-09-15T14%3A24%3A00Z&sr=b&sp=r&sig=ugCaSfg%2BbxHWcyp%2BM7iZVQXcvKXF3%2B7SzpTaDTJ7FwY%3D"
$TEMPLATE_BLOB = "https://nmwextensions.blob.core.windows.net/cloud-clarity/Nerdio%20User%20Cost%20Attribution%20PowerBi%20v5.5.pbix?sv=2021-10-04&st=2023-11-13T09%3A32%3A29Z&se=2123-11-14T09%3A32%3A00Z&sr=b&sp=r&sig=lYxY6u9cJhcPKXbSTDQwe55emNLio1SrXMIU%2FEQVWP0%3D"
$CONNECTOR_NAME = "NerdioReporting.pqx"
$TEMPLATE_NAME = "Nerdio User Cost Attribution.pbix"

function Start-AsAdministrator() {
    $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    if (!$CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        $ElevatedProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell"
        $ElevatedProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"
        $ElevatedProcess.Verb = "runas"
        [System.Diagnostics.Process]::Start($ElevatedProcess)
        exit
    }
}

function Test-PowerBiIsRunning() {
    $process = Get-Process PBIDesktop -ErrorAction SilentlyContinue
    if ($process) {
        Write-Host "Failed" -ForegroundColor Red
        Write-Host "Power BI Desktop process is running. Please close it before using this script" -ForegroundColor Red
        Pause
        exit
    }
}

function Add-RegistryThumbprint() {
    $RegistryPath = 'HKLM:\Software\Policies\Microsoft\Power BI Desktop'
    $Name = 'TrustedCertificateThumbprints'

    if (-NOT(Test-Path $RegistryPath)) {
        New-Item -Path $RegistryPath -Force | Out-Null
    }

    try {
        $Value = Get-ItemPropertyValue -Path $RegistryPath -Name $Name
        if ( $Value.Contains($THUMBPRINT)) {
            return
        }
        $Value += $THUMBPRINT
    }
    catch {
        $Value = $THUMBPRINT
    }

    New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType MultiString -Force | Out-Null
}

function Copy-PowerBiConnector() {
    $Path = [IO.Path]::Combine([Environment]::GetFolderPath("MyDocuments"), "Power BI Desktop", "Custom Connectors")

    if (-NOT(Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }

    Invoke-WebRequest -URI $CONNECTOR_BLOB -OutFile ([IO.Path]::Combine($Path, $CONNECTOR_NAME))
}

function Copy-PowerBiTemplate() {
    $Path = [IO.Path]::Combine([Environment]::GetFolderPath("MyDocuments"), "Power BI Desktop")

    if (-NOT(Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }

    Invoke-WebRequest -URI $TEMPLATE_BLOB -OutFile ([IO.Path]::Combine($Path, $TEMPLATE_NAME))
}

$ErrorActionPreference = "Stop"

Write-Host
Write-Host "================== Nerdio Manager for Enterprise ==================" -ForegroundColor Yellow
Write-Host "==================     User Cost Attribution     ==================" -ForegroundColor Yellow
Write-Host "=================  Power BI connector installer  ==================" -ForegroundColor Yellow
Write-Host

Write-Host "1. Check administrative privileges...`t`t" -NoNewline
Start-AsAdministrator
Write-Host "OK" -ForegroundColor Green

Write-Host "2. Check Power BI Desktop is not running...`t" -NoNewline
Test-PowerBiIsRunning
Write-Host "OK" -ForegroundColor Green

Write-Host "3. Add thumbprint to the registry...`t`t" -NoNewline
Add-RegistryThumbprint
Write-Host "OK" -ForegroundColor Green

Write-Host "4. Download and copy Power BI connector...`t" -NoNewline
Copy-PowerBiConnector
Write-Host "OK" -ForegroundColor Green

Write-Host "5. Download and copy Power BI template...`t" -NoNewline
Copy-PowerBiTemplate
Write-Host "OK" -ForegroundColor Green

Write-Host
Write-Host "Completed" -ForegroundColor Green
Write-Host

Pause
