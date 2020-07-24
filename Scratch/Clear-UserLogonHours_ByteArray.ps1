function Clear-UserLogonHours {
  [CmdletBinding(SupportsShouldProcess = $true)]

  Param(
    [String]
    $User,

    [String]
    $Domain

  )
  [byte[]]$hoursFalse = @(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

  try {
    Get-ADUser -Identity $User -Server $Domain |
    Set-ADUser -Replace @{logonhours = $hoursFalse } -Server $Domain -ErrorAction Stop
  }
  catch [Microsoft.ActiveDirectory.Management.ADException] {
    $Error[0].Exception
  }
  finally {
    $ErrorActionPreference = "Continue"
  }
}

# CSV file header example
# SamAccountName
# FooBar
# BarFoo
$Users = (Import-Csv -Path C:\Temp\<some_csv>.csv).SamAccountName

foreach ($User in $Users) {
  # Unomment -WhatIf for testing
  Clear-UserLogonHours -User $User -Domain 'bmg.bagint.com' #-WhatIf
}