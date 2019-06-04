#Requires -Version 2 
<# 
    .SYNOPSIS 

    .DESCRIPTION 
 
    .NOTES 
       File Name  : Get-SystemInfo
       Author     : Sean Connealy
       Requires   : PowerShell Version 3.0 
       Date       : 4/3/2014

    .LINK 
    This script posted to: http://www.github/sjcnyc

    .EXAMPLE

    .EXAMPLE

#>

function script:Get-SystemInfo {
  # Requires -Version 3.0
  [CmdletBinding()]
  Param 
  (
    [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [String[]]$ComputerName = ($Env:COMPUTERNAME),
    [Parameter(Position = 1)]
    [PSCredential]$Credential,
    [ValidateScript({Test-Path -Path $_})]
    [String]$LogDir = "$Home\Documents"
  )
  Begin
  {
    Write-Verbose -Message 'Retrieving Computer Info . . .'
    if ($Credential)
    {
      $PSDefaultParameterValues = $Global:PSDefaultParameterValues.Clone()
      $PSDefaultParameterValues['Get-WmiObject:Credential'] = $Credential  
    }
  }
  Process
  {

    $result = New-Object System.Collections.ArrayList

    $ComputerName | 
    ForEach-Object -Process {
      Write-Verbose -Message ">> ComputerName: $_"

      $ErrorActionPreference = 'SilentlyContinue'
    
      $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $_
      $sys = Get-WmiObject -Class win32_Computersystem -ComputerName $_
      $bios = Get-WmiObject -Class win32_Bios -ComputerName $_
      $PageFile = Get-WmiObject -Class Win32_PageFileSetting -ComputerName $_ |
      Select-Object -Property Name, InitialSize, MaximumSize |
      Format-Table -AutoSize |
      Out-String
      $Volume = Get-VolumeWin32 -ComputerName $_ |
      Select-Object -Property Name, VolumeName, CapacityGB, UsedGB, FreeGB, FreePC |
      Format-Table -AutoSize |
      Out-String
      $Network = (Get-WmiObject -Class win32_NetworkAdapterConfiguration -ComputerName $_  |
        ForEach-Object -Process { $_.DefaultIPGateway } |
      Out-String).Split("`n")[0]
      $CPU = @(Get-WmiObject -Class Win32_Processor -ComputerName $_ )[0]

      if (($os -eq $Null) -and ($sys -eq $Null) -and ($bios -eq $Null))
      {$_ | Out-File -FilePath $LogDir\nowmiHosts.txt -NoClobber -Append}
      if ($os.LastBootupTime){$LastBoot = $os.ConvertToDateTime($os.LastBootupTime)}
      if ($os.InstallDate){$InstallDate = $os.ConvertToDateTime($os.InstallDate)}
      if ($sys.Name){$CompName = $sys.Name.toUpper()}
      if ($sys.TotalPhysicalMemory){$Memory = ($sys.TotalPhysicalMemory)/1MB -as [int]}
      if ($Volume){$Volume = $Volume.Substring(2,$Volume.length-9)}
      else
      {
        $Volume = @"
Get-VolumeWin32
"@
      }

      if ($PageFile){$PageFile = $PageFile.Substring(1,$PageFile.length-5)}
      else {$PageFile = 'Automatic'}

      #$info=
      [PSCustomObject][Ordered]@{
        Computername    = $CompName
        OperatingSystem = $os.Caption
        OSVersion       = $os.Version
        OSArchitecture  = $os.OSArchitecture
        CPUName         = $CPU.Name
        CPUDescription  = $CPU.Description
        CPUAddressWidth = $CPU.AddressWidth
        WindowsDir      = $os.WindowsDirectory
        LastBoot        = $LastBoot
        InstallDate     = $InstallDate
        BiosVersion     = $bios.version
        SerialNumber    = $bios.SerialNumber
        TotalPhysMemMB  = $Memory
        Vendor          = $sys.Manufacturer
        Model           = $sys.Model
        Owner           = $sys.PrimaryOwnerName
        DefaultGateway  = $Network
        PageFileInfo    = $PageFile
        Volume          = $Volume
      }    
      $ErrorActionPreference = 'Continue'
      #$result.Add($info) | Out-Null
    }

   # $result | Out-File -FilePath c:\temp\wusDiskSpace.txt -Append -Force
  }
}

function script:Get-VolumeWin32 {
  # Requires Version 2.0
  [CmdletBinding()]
  Param 
  ([Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [String[]]$ComputerName
  )
  Begin {
    $Query = "Select SystemName,Name,VolumeName,Size,DriveType,FreeSpace from Win32_LogicalDisk WHERE DriveType = '3'"
    $NameSpace = 'root\cimv2'
    Write-Verbose -Message 'Retrieving Volume Info . . .'
    Write-Verbose -Message $Query
    Write-Verbose -Message "from NameSpace: $NameSpace `n"
  }
  Process {
    $ComputerName | 
    ForEach-Object -Process {
      $Computer = $_
      Write-Verbose -Message "Connecting to:--> $Computer"
      Get-WmiObject -Query $Query -Namespace $NameSpace -ComputerName $Computer |
      Where-Object -FilterScript {$_.name -notmatch '\\\\' -and $_.DriveType -eq '3'} |
      ForEach-Object -Process {$RAW = $_ |
        Select-Object -Property SystemName, Name, DriveType, VolumeName, Size, FreeSpace 
        Write-Verbose -Message $RAW 
        $_
      } |
      Select-Object -Property SystemName, Name, VolumeName, DriveType, `
      @{
        name       = 'CapacityGB'
        Expression = {'{0:N2}'  -f ($_.size / 1gb)}
      }, `
      @{
        name       = 'UsedGB'
        Expression = {'{0:N2}'  -f ($($_.size-$_.freespace) / 1gb)}
      }, `
      @{
        name       = 'FreeGB'
        Expression = {'{0:N2}'  -f ($_.freespace / 1gb)}
      }, `
      @{
        name       = 'FreePC'
        Expression = {'{0:N2}'  -f ($_.freespace / $_.size * 100)}
    }} | 
    Sort-Object -Property SystemName, Name
  } 
  End {}
}


get-systeminfo -ComputerName usnaspwfs01 -Verbose
