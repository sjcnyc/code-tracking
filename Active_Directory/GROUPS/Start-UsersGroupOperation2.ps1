function Start-UsersGroupOperation {
  [CmdletBinding(SupportsShouldProcess = $true)]
  param (
    [Parameter(Mandatory)][ValidateSet('AddMember', 'RemoveMember')]
    $option,
    [Parameter(Mandatory)][string]
    $Groupname,
    [Parameter(Mandatory)][string]
    $Username
  )
  Add-Type -AssemblyName Microsoft.ActiveDirectory.Management

  try {
    if ($option -eq 'AddMember') {
      Add-ADGroupMember -Identity $Groupname -Members $Username -Confirm:$false -ErrorAction Stop
    }
    elseif ($option -eq 'RemoveMember') {
      Remove-ADGroupMember -Identity $Groupname -Members $Username -Confirm:$false -ErrorAction Stop
    }
  }
  catch [Microsoft.ActiveDirectory.Management.ADException] {
    [Management.Automation.ErrorRecord]$e = $_

    $info = [PSCustomObject]@{
      Exception = "$($e.Exception.Message) $($e.CategoryInfo.TargetName)"
    }
    Write-Output -InputObject $info.Exception
  }
  catch {
    $line = $_.InvocationInfo.ScriptLineNumber
    Write-Output -InputObject ('Error was in Line {0}, {1}' -f ($line), $_)
  }
}

# Single operation

#Start-UsersGroupOperation -option RemoveMember -Groupname "usa-gbl member server administrators" -Username sconneaxx
#Start-UsersGroupOperation -option AddMember -Groupname "usa-gbl member server administrators" -Username sconnea

# Multiple operations.  Use -whatIf for testing
$users = Import-Csv c:\temp\user.csv

foreach ($user in $users) {
  Start-UsersGroupOperation -option RemoveMember -Groupname "usa-gbl member server administrators" -Username $user
  #Start-UsersGroupOperation -option AddMember -Groupname "usa-gbl member server administrators" -Username $user
}

# Quick and dirty here string operation
@"
sconnea
"@ -split [environment]::NewLine | ForEach-Object {
  Start-UsersGroupOperation -option RemoveMember -Groupname "usa-gbl member server administrators" -Username $_ -WhatIf
}