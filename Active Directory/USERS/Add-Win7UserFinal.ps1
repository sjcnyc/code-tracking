
Clear-Host

Function Add-Win7user {
  [cmdletBinding(SupportsShouldProcess = $True)]
  param (
    [Parameter(Mandatory = $true)]
    [string]
    $user
    )

  begin { }
  process {
    try {
      $output = Get-QADUser $user -IncludeAllProperties
      $loc = $output.DN.Split(',')[-4]
      $usr = $output.DN.Split(',')[-7]
      $group = @('USA-GBL New Logon Script', 'USA-GBL MapO Logon Isilon Outlook', 'USA-GBL MapS Logon Isilon Data')

      if ($loc -eq 'OU=USA') { Write-Host "User: $user is in: $loc,$usr" }
      else {
        Write-Host "Moving $user to: OU=USA,$usr" -NoNewline
        Move-QADObject -I $user -NewParentContainer "$usr,ou=usr,ou=gbl,ou=usa,dc=bmg,dc=bagint,dc=com" | Out-Null
        1..(50 - ($loc.length + $usr.length + 1)) | ForEach-Object { Write-Host '.' -ForegroundColor Cyan -NoNewline; Start-Sleep -Milliseconds .5; }
        Write-Host '[ OK ]' -ForegroundColor Cyan
      }
      foreach ($grp in $group) {
        isMember $user
      }
    }
    catch { $_.exception.message; continue }
  }
  end { }
}


function isMember ($user) {

  if (Get-QADUser $user | Get-QADMemberOf | ForEach-Object { $_} | Where-Object { $_.name -eq $grp }) { Write-Host "User: $user is member of: " $grp }
  else {
    Write-Host "Adding $user to:" $grp -NoNew; Add-QADGroupMember -I $grp -Member $user | Out-Null
    1..(50 - $grp.Length) | ForEach-Object { Write-Host '.' -ForegroundColor Cyan -NoNewline; Start-Sleep -Milliseconds .5; }
    Write-Host '[ OK ]' -Fore Cyan
  }
}


Add-Win7user sconnea