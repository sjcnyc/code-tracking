# Ensure TLS 1.2 is used for secure connections
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072


# Install module in PowerShell 5.1
$modules = @('Update-AllPSModules', 'MicrosoftTeams', 'Microsoft.Online.SharePoint.PowerShell', 'Microsoft.Graph', 'ExchangeOnlineManagement', 'PSReadline', 'Terminal-Icons', 'Az*')

foreach ($ModuleName in $modules) {
    if (-not (Get-Module -ListAvailable -Name $ModuleName | Where-Object { $_.ModuleBase -like "C:\Program Files\WindowsPowerShell\Modules\*" }).Count -gt 0) {
        try {

            Write-Output "Installing $ModuleName in PowerShell 5.1..."
            Install-Module -Name $ModuleName -Force -Scope AllUsers -SkipPublisherCheck -ErrorAction Stop
            Write-Output "$ModuleName installed successfully in PowerShell 5.1."
        }
        catch {
            Write-Error "Failed to install $ModuleName in PowerShell 5.1: $_"
        }
    }
    else {
        Write-Output "$ModuleName is already installed in PowerShell 5.1."
    }
}

# Install module in PowerShell 7
pwsh.exe -command {
    $modules = @('Update-AllPSModules', 'MicrosoftTeams', 'Microsoft.Online.SharePoint.PowerShell', 'Microsoft.Graph', 'ExchangeOnlineManagement', 'PSReadline', 'Terminal-Icons', 'Az*')
    foreach ($ModuleName in $modules) {
        if (-not (Get-Module -ListAvailable -Name $ModuleName | Where-Object { $_.ModuleBase -like "C:\Program Files\PowerShell\Modules\*" }).Count -gt 0) {
            try {
                Write-Output "Installing $ModuleName in PowerShell 7..."
                Install-Module -Name $ModuleName -Force -Scope AllUsers -SkipPublisherCheck -ErrorAction Stop
                Write-Output "$ModuleName installed successfully in PowerShell 7."
            }
            catch {
                Write-Error "Failed to install $ModuleName in PowerShell 7: $_"
            }
        }
        else {
            Write-Output "$ModuleName is already installed in PowerShell 7."
        }
    }
}


# Register the Remove-FSL-Profiles scheduled task
$xml1 = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2024-03-01T22:14:38.8525727</Date>
    <Author>ME\sconnea</Author>
    <URI>\Remove-FSL-Profiles</URI>
  </RegistrationInfo>
  <Triggers>
    <BootTrigger>
      <Enabled>true</Enabled>
    </BootTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-18</UserId>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
    <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell</Command>
      <Arguments>-file c:\support\Remove-OrphanedFSLProfiles.ps1</Arguments>
    </Exec>
  </Actions>
</Task>
"@

# register the Updatee-allPSModules scheduled task
$xml2 = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2025-01-19T17:24:30.4431705</Date>
    <Author>ME\sconnea</Author>
    <URI>\Update-AllPSModules.xml</URI>
  </RegistrationInfo>
  <Triggers>
    <CalendarTrigger>
      <StartBoundary>2025-01-19T17:00:00</StartBoundary>
      <Enabled>true</Enabled>
      <ScheduleByDay>
        <DaysInterval>1</DaysInterval>
      </ScheduleByDay>
    </CalendarTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-18</UserId>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession>
    <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell</Command>
      <Arguments>-command &amp;{update-allpsmodules}</Arguments>
    </Exec>
    <Exec>
      <Command>"C:\Program Files\PowerShell\7\pwsh.exe"</Command>
      <Arguments>&amp;{update-allpsmodules}</Arguments>
    </Exec>
  </Actions>
</Task>
"@

$tasks = @([PSCustomObject]@{Xml = $xml1; TaskName = "Remove-FSL-Profiles" }, [PSCustomObject]@{Xml = $xml2; TaskName = "Update-AllPSModules" })
foreach ($task in $tasks) {
    if (-not (Get-ScheduledTask -TaskName $task.TaskName -ErrorAction SilentlyContinue)) {
        try {
            Register-ScheduledTask -Xml $task.Xml -TaskName $task.TaskName -TaskPath "\"
            Write-Output "Scheduled task $($task.TaskName) registered successfully."
        }
        catch {
            Write-Error "Failed to register scheduled task $($task.TaskName): $_"
        }
    }
    else {
        Write-Output "Scheduled task $($task.TaskName) is already registered."
    }
}

# Install Chocolatey
# Check if Chocolatey is already installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    try {
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Output "Chocolatey installed successfully."
    }
    catch {
        Write-Error "Failed to install Chocolatey: $_"
    }
}
else {
    Write-Output "Chocolatey is already installed."
}

# Check if gsudo is already installed
if (-not (Get-Command gsudo -ErrorAction SilentlyContinue)) {
    try {
        # Install gsudo using Chocolatey
        choco install gsudo -y
        Write-Output "gsudo installed successfully."
    }
    catch {
        Write-Error "Failed to install gsudo: $_"
    }
}
else {
    Write-Output "gsudo is already installed."
}