$UserInfo = Get-ADUser -Identity 'sconnea' -Server 'bmg.bagint.com' -Properties AccountLockoutTime,LastBadPasswordAttempt,BadPwdCount,LockedOut -ErrorAction Stop
$LockedOutEvents = Get-WinEvent -ComputerName 'bmg.bagint.com' -FilterHashtable @{LogName='Security';Id=4740} -ErrorAction Stop -MaxEvents 10

$result = New-Object System.Collections.ArrayList

Foreach($Event in $LockedOutEvents)
{             
      $lockouts = [pscustomobject] @{
        'User' = $Event.Properties[0].Value
        'DomainController' =   $Event.MachineName
        'EventID' = $Event.Id
        'LockedOutTimeStamp' = $Event.TimeCreated
        'Message' = $Event.Message -split "`r" | Select-Object -First 1
        'LockedOutLocation' = $Event.Properties[1].Value
      }

      $result.Add($lockouts) | Out-Null

    }

$result | ft -auto