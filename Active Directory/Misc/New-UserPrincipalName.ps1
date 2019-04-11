#requires -Version 1
#requires -PSSnapin Quest.ActiveRoles.ADManagement
function New-UserPrincipalName {
  param (
    [string]$logon
  )

  $Name = "$($logon)"
  $defaultname = $Name

  $Exit = 0
  $Count = 1
  Do
  {
    Try
    {
      $User = Get-QADUser -UserPrincipalName "$Name@bmg.bagint.com"
      If ($User -eq $null) {$Exit = 1}
      else
      {$Name  = $defaultname + $Count++}
    }
    Catch
    {$Exit = 1}
  }
  While ($Exit -eq 0)
  $UPN = $Name
  $UPN
}
