$users = Get-QADUser -Service 'nycmnetads001.mnet.biz:389' -SizeLimit '0' | Select-Object Name, Mail, proxyAddresses, ParentContainer

$result = New-Object System.Collections.ArrayList

foreach ($user in $users) {

  $info = [pscustomobject]@{
    'Name' = $user.Name
    'Email'= $user.Mail
    'Proxy' = ($user.proxyAddresses | Out-String).Trim()
    'ParentContainer' = $user.ParentContainer
  }

   $null = $result.Add($info)
}

$result | Export-Csv -Path "$env:HOMEDRIVE\Temp\MNET_allEmailAddresses2.csv" -NoTypeInformation