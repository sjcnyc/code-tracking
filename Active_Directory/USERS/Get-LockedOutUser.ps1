#requires -Version 2 -Modules ActiveDirectory
function Get-LockedOutUser {
  Param(
  [parameter(Mandatory)][string]$username,
  [parameter(Mandatory)][string]$DomainController
  )

  $UserInfo = Get-ADUser -Identity $username -Server $DomainController -Properties AccountLockoutTime, LastBadPasswordAttempt, BadPwdCount, LockedOut -ErrorAction Stop
  $LockedOutEvents = Get-WinEvent -ComputerName $DomainController -FilterHashtable @{
    LogName = 'Security'
    Id      = 4740
  } -ErrorAction Stop -MaxEvents 10

  $result = New-Object -TypeName System.Collections.ArrayList

  Foreach($Event in $LockedOutEvents)
  {
    If($Event | Where-Object -FilterScript {$_.Properties[2].value -match $UserInfo.SID.Value}) 
    {               
      $lockouts = [pscustomobject] @{
        'User'               = $Event.Properties[0].Value
        'DomainController'   = $Event.MachineName
        'EventID'            = $Event.Id
        'LockedOutTimeStamp' = $Event.TimeCreated
        'Message'            = $Event.Message -split "`r" | Select-Object -First 1
        'LockedOutLocation'  = $Event.Properties[1].Value
      }
      $null = $result.Add($lockouts)
    }
  }
  $result | Format-Table -AutoSize
}