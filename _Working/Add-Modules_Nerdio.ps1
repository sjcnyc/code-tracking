## Description: This script installs the required modules for Nerdio Manager for Enterprise and
## registers scheduled tasks for updating modules and removing FSLogix profiles.

# Set the execution policy to allow script execution with powersehll 7
Set-PSResourceRepository -Name PSGallery -Trusted

# Import the required modules
$installModuleSplat = @{
    Name = 'Update-AllPSModules', 'MicrosoftTeams', 'Microsoft.Online.SharePoint.PowerShell', 'Microsoft.Graph', 'ExchangeOnlineManagement', 'Az', 'PSReadline', 'Terminal-Icons'
}
# Install the required modules in c:\program files\windowspowershell\modules
Install-Module @installModuleSplat -Scope AllUsers -Force -AllowClobber -Verbose -SkipPublisherCheck
# Install the required modules in c:program files\powershell\7\modules
pwsh.exe -NoLogo -NoProfile -Command "
Set-PSResourceRepository -Name PSGallery -Trusted;
Install-Module 'Update-AllPSModules', 'MicrosoftTeams', 'Microsoft.Online.SharePoint.PowerShell', 'Microsoft.Graph', 'ExchangeOnlineManagement', 'Az', 'PSReadline', 'Terminal-Icons' -Scope AllUsers -Force -AllowClobber -Verbose -SkipPublisherCheck;
Exit
"

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

Register-ScheduledTask -Xml $xml1 -TaskName "Remove-FSL-Profiles.xml" -TaskPath "\"
Register-ScheduledTask -Xml $xml2 -TaskName "Update-AllPSModules.xml" -TaskPath "\"

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install gsudo
choco install gsudo -y #--Force