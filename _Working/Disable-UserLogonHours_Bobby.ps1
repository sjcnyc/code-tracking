$cred = Get-AutomationPSCredential -Name 'T2_Cred'

$GroupName = 'T2_ZeroLogonHours'

$Users = Get-ADGroup -Identity $GroupName -Credential $cred | Get-ADGroupMember -Recursive -Credential $cred

function Clear-UserLogonHours {
  [CmdletBinding(SupportsShouldProcess = $true)]

  Param(
    [String]
    $User
  )
  
  [byte[]]$hoursFalse = @(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

  try {
    $User = Get-ADUser -Identity $User -Credential $cred -ErrorAction Stop
    Write-Output $User

    Write-Output 'Replaceing logonhours'
    $User | Set-ADUser -Replace @{logonhours = $hoursFalse } -Credential $cred -ErrorAction Stop
    
  }
  catch [Microsoft.ActiveDirectory.Management.ADException] {
    Write-Output $Error[0].Exception
  }
  finally {
    $ErrorActionPreference = 'Continue'
  }
}

foreach ($User in $Users) {
  Clear-UserLogonHours -User $User
}