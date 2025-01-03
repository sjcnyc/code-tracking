<#
.SYNOPSIS
Rapid fast multi package installer for chocolatey packages
.DESCRIPTION
Installs/upgrades programs super fast with chocolatey and installs chocolatey if needed.
More than one program can be given to as param -package to run the installation in different threads.
This script needs to be run as administrator.
.PARAMETER package
A list of packages which should be installed/upgraded. Seperate it with a ",".
.PARAMETER removeChocoAfterwards
Removes Chocolatey afterwards when this parameter is given.
.PARAMETER keepChocoAfterwards
Keeps Chocolatey afterwards when this parameter is given.
.PARAMETER threads
Maximum numbers of threads (Default=256)
.EXAMPLE
.\choco-runner -package 7zip.install,firefoxesr -removeChocoAfterwards
Installs 7zip & firefox and removes Chocolatey afterwards.
.NOTES
Author: Neocky
Version: 1.3.0
.LINK
https://github.com/Neocky/choco-runner
#>
#Requires -RunAsAdministrator

[CmdletBinding()]
param (
    [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline = $True)][array]$package,
    [Parameter(Mandatory = $False)][switch]$removeChocoAfterwards,
    [Parameter(Mandatory = $False)][switch]$keepChocoAfterwards,
    [Parameter(Mandatory = $False)][Int32]$threads = 256
)

Process {

    # Writes the title screen to the console
    function Write-ScriptTitle {
        Write-Host "      ┌────────────────────────────────────────┐"
        Write-Host "      │              " -NoNewline; Write-Host "CHOCO RUNNER" -ForegroundColor Yellow -NoNewline; Write-Host "              │"
        Write-Host "      │ " -NoNewline; Write-Host "https://github.com/Neocky/choco-runner" -ForegroundColor Cyan -NoNewline; Write-Host " │"
        Write-Host "      └────────────────────────────────────────┘"
    }


    # Checks the given parameters and writes a help message if no package was given
    function Test-Params {
        [CmdletBinding()]
        param (
            [Parameter()][array]$programsToInstall,
            [Parameter()][Boolean]$removeChocolateyAfter,
            [Parameter()][Boolean]$keepChocolateyAfter
        )

        if (($programsToInstall).Count -eq 0) {
            Write-Warning "Package name is required. Please use the parameter: -package PACKAGENAME1,PACKAGENAME2"
            Write-Output "Here is a list with all available packages to install: https://community.chocolatey.org/packages"
            @(
                "POPULAR PACKAGES:"
                "├─ adobereader",
                "├─ googlechrome",
                "├─ firefoxesr",
                "├─ 7zip.install",
                "└─ office365business"
            ) -join "`n" | Write-Output
            Exit 1
        }

        if (($removeChocolateyAfter -eq $True) -and ($keepChocolateyAfter -eq $True)) {
            Write-Warning "Can't use both parameters 'removeChocoAfterwards' & 'keepChocoAfterwards' at once"
            Exit 1
        }
    }


    # Installs Chocolatey with the Chocolatey install script
    function Install-Chocolatey {
        Write-Output "Installing Chocolatey..."
        try {
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) -ErrorAction Stop
        }
        catch {
            Write-Error "Couldn't install Chocolatey. Check your network connection and try again!"
            Exit 1
        }
    }


    # Removes the default Install direcotry for Chocolatey
    function Remove-Chocolatey {
        Write-Output "Removing Chocolatey..."
        try {
            Remove-Item -Path "C:\ProgramData\chocolatey" -Force -Recurse -ErrorAction Stop
        }
        catch {
            Write-Error "Couldn't remove Chocolatey from the system. Check if Chocolatey is installed under C:\ProgramData\chocolatey and try again!"
            Exit 1
        }
        Write-Output "Chocolatey successfully removed"
    }


    # Checks if chocolatey was installed successfully and if not will run installer again
    function Get-ChocolateyInstall {
        try {
            $chocoInstalled = Test-Path $env:ChocolateyInstall -ErrorAction Stop
        }
        catch {
            $chocoInstalled = $False
        }

        if ($chocoInstalled -eq $False) {
            Write-Output "Chocolatey wasn't found on the system."
            Install-Chocolatey

            if (-not (Test-Path $env:ChocolateyInstall)) {
                Write-Output "Chocolatey couldn't be installed correctly. Exiting program..."
                Exit 1
            }
        }
    }


    # chocolatey package installer which will run in different threads
    $installer = {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $True)][String]$chocoProgram
        )
        
        # Installs/Upgrades the chocolatey package
        function Install-ChocoPackage {
            [CmdletBinding()]
            param (
                [Parameter()][array]$programsToInstall
            )
            choco upgrade $programsToInstall -y --limitoutput --no-progress
        }

        try {
            Install-ChocoPackage -programsToInstall $chocoProgram -ErrorAction Stop
        }
        catch {
            Write-Host "● " -ForegroundColor Red -NonewLine; Write-Host "Couldn't install: " -ForegroundColor Red -NoNewline; Write-Host "$chocoProgram"
            Exit
        }
        Write-Host "● " -ForegroundColor Green -NonewLine; Write-Host "Successfully installed: " -ForegroundColor Green -NoNewline; Write-Host "$chocoProgram"
    }


    Test-Params -programsToInstall $package -removeChocolateyAfter $removeChocoAfterwards -keepChocolateyAfter $keepChocoAfterwards
    Write-ScriptTitle
    Get-ChocolateyInstall
    Write-Host ""
    Write-Host "Packages to install: " -ForegroundColor Green
    Write-Output $package
    Write-Host ""

    $RunspacePool = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, $threads, $Host)
    $RunspacePool.Open()
    [System.Collections.ArrayList]$jobs = @()
    Foreach ($packageToInstall in $package) {
        $scriptParams = @{
            chocoProgram = $packageToInstall
        }
        $job = [System.Management.Automation.PowerShell]::Create().AddScript($installer).AddParameters($scriptParams)
        $job.RunspacePool = $RunspacePool
        $jobObj = [pscustomobject] @{
            Pipe   = $job
            Result = $job.BeginInvoke()
        }
            
        [void]$jobs.Add($jobObj)
    }


    $i = 0 # needed for progress bar
    Do {
        Write-Progress -Activity "Installing choco packages..." -Status ("[ $i / " + $package.Count + " ] Packages finished") -PercentComplete ($i / $package.Count * 100)
        $unfinishedJobs = $jobs | Where-Object -FilterScript { $_.Result.IsCompleted }

        if ($null -eq $unfinishedJobs) {
            Start-Sleep -Milliseconds 250
            continue
        }

        foreach ($job in $unfinishedJobs) {
            $jobOutput = $job.Pipe.EndInvoke($job.Result)
            $job.Pipe.Dispose()
            $jobs.Remove($job)
            Write-Output $jobOutput
            $i++
        }
    } While ($jobs.Count -gt 0)

    # close all threads
    $RunspacePool.Close()
    $RunspacePool.Dispose()

    if (($removeChocoAfterwards -ne $True) -and ($keepChocoAfterwards -ne $True)) {
        $removeChocolateyConfirmation = Read-Host "Remove Chocolatey? (y/n)"
    }
    if (($removeChocolateyConfirmation -eq "y") -or ($removeChocoAfterwards -eq $True) -and ($keepChocoAfterwards -ne $True)) {
        Remove-Chocolatey
    }        
}