﻿Function Get-LastReboot {
  Param (
    [Parameter(Position=0,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$true)]
    [alias('Name','ComputerName')]$Computer=@($env:ComputerName),
    [switch] $Output
  )
  
  process{
    if (Test-Connection -ComputerName $Computer -Count 1 -Quiet){
      write-host "Getting Uptime for $Computer" -foregroundcolor green
      $Result = GetUpTime $Computer
      $Global:objOut += $Result
    }
    else {
      Write-Output $("$($Computer) cannot be reached")
    }
  }
  
  begin{
    $Global:objOut = @()
    
    Function GetUpTime {
      param
      (
        [System.Object]
        $HostName
      )
      
      try{
        $UpTime = [System.Management.ManagementDateTimeconverter]::ToDateTime((Get-WmiObject -Class Win32_OperatingSystem -Computer $HostName).LastBootUpTime)
        $UpTimeSpan = New-TimeSpan -start $UpTime -end $(Get-Date -Hour 8 -Minute 0 -second 0)
        $Filter = @{ProviderName= 'USER32';LogName = 'system'}
        $Reason = (Get-WinEvent -ComputerName $HostName -FilterHashtable $Filter | Where-Object {$_.Id -eq 1074} | Select-Object -First 1)
        $Result = New-Object PSObject -Property @{
    		Date = $(Get-Date -Format d)
    		ComputerName = [string]$HostName
    		LastBoot = $UpTime
    		Reason = $Reason.Message
    		Days = $($UpTimeSpan.Days)
    		Hours = $($UpTimeSpan.Hours)
    		Minutes = $($UpTimeSpan.Minutes)
    		Seconds = $($UpTimeSpan.Seconds)
    		}
        return $Result
      }
      catch{
        write-error $error[0]
        return $null
      }
    }
    
  }
  
  end{
    if ($Output){
      [string]$OutputLog = ([environment]::getfolderpath('mydocuments')) + '\' + 'Servers_Uptime.csv'
      $Global:objOut | ConvertTo-Csv -Delimiter ';' -NoTypeInformation | out-file $OutputLog
    }
    else{
      $Global:objOut | Select-Object Date, Servername, Lastboot, Reason, Days, Hours, Minutes, Seconds | Format-List
    }
  }
  
}


Get-LastReboot -Computer localhost
