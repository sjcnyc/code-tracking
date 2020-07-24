function Get-AccountLockoutLocation 
{
  [CmdletBinding()]
  param(
    [Parameter(Position = 0, Mandatory = $true)]
    [System.String]
    $UserName
  )
  begin 
  {		
    $DomainControllers = Get-ADDomainController -Filter *

    $PDCEmulator = $DomainControllers | Where-Object -FilterScript {
      $_.OperationMasterRoles -like '*PDCEmulator*'
    }
		
    $Events = Get-WinEvent -ComputerName $PDCEmulator.HostName -FilterHashtable @{
      Logname = 'Security'
      Id      = 4740
    }
		
    $UserEvents = $Events | Where-Object -FilterScript {
      $_.Message -like "*$UserName*"
    }

  }
  process
  {
    $DomainControllers |
    ForEach-Object -Process {
      $DC = $_
      Get-ADUser -Identity $UserName -Server $_.HostName -Properties AccountLockOutTime, LastBadPasswordAttempt, BadPwdCount, LockedOut |
      Select-Object -Property Name, LockedOut, @{
        Name       = 'DC'
        Expression = {
          $DC.Name
        }
      }, BadPwdCount, AccountLockoutTime, LastBadPasswordAttempt
    } |
    Select-Object -Property *
		
    $UserEvents | ForEach-Object -Process {
      $_ | Select-Object -Property @{
        Name       = 'UserName'
        Expression = {
          $_.Properties.Value[0]
        }
      }, @{
        Name       = 'LockoutLocation'
        Expression = {
          $_.Properties.Value[1]
        }
      }
    }
  }
  end 
  {
  }
}

$LockedAccounts = Search-ADAccount -LockedOut -UsersOnly | Select-Object -Property SAMAccountName

ForEach ($Account in $LockedAccounts)
{
  Get-AccountLockoutLocation -UserName $Account.SamAccountName
}
