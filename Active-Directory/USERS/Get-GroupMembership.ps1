$users = Get-QADUser -SearchRoot 'bmg.bagint.com/USA/GBL/USR/Arcade' -SizeLimit 0

$result = New-Object -TypeName System.Collections.ArrayList

foreach ($user in $users) {

  $info = [pscustomobject]@{
    'UserName'       = $user.Name
    'Groups'         = ((Get-QADUser $user.Name).MemberOf | Out-String).Trim()
    'SamaccountName' = $user.SamAccountName
  }

  $null = $result.Add($info)
}

$result #| Export-Csv -Path "$env:HOMEDRIVE\TEMP\user_sec_groups2.csv" -NoTypeInformation