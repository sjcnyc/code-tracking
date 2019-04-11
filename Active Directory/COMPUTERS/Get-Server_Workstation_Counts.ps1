<#

(Get-QADComputer -ldapFilter '(!(userAccountControl:1.2.840.113556.1.4.803:=2))' -SearchScope Subtree -SizeLimit 0 | Where-Object {$_.OSName -notmatch 'Server'}).count
(Get-QADComputer -ldapFilter '(!(userAccountControl:1.2.840.113556.1.4.803:=2))' -SearchScope Subtree -SizeLimit 0 -OSName "*Server*").count


$ous = Get-QADObject -Type 'OrganizationalUnit' -SearchScope OneLevel
$result = New-Object System.Collections.ArrayList

foreach ($ou in $ous) {
  
  $count = (Get-QADComputer -ldapFilter '(!(userAccountControl:1.2.840.113556.1.4.803:=2))' -SearchRoot "bmg.bagint.com/$($ou.Name)" -OSName '*Server*' -SizeLimit 0).count

  write-host "$($ou.Name) : $($count)"

  $info = [pscustomobject]@{
      'OrganizationalUnit'= $ou.Name
      'ComputerCount'     = $count
    }

    $result.Add($info) | Out-Null
}

$result | Export-Csv -Path "$env:HOMEDRIVE\Temp\ServeCountByOU.csv" -NoTypeInformation -Append



Get-QADComputer -ComputerRole member -SizeLimit 0 -OSName 'Windows XP*', 'Windows 2000 Professional', 'Windows 7*', 'Windows Vista*', 'windows 10*'


$result = New-Object System.Collections.ArrayList

$servers = Get-QADComputer -ldapFilter '(!(userAccountControl:1.2.840.113556.1.4.803:=2))' -SearchScope Subtree -SizeLimit 0 -OSName '*Server*'

foreach ($server in $servers)
{
  
      $info = [pscustomobject]@{
      'Name'    = $server.Name.ToUpper()
      'OSName'  = $Server.OSName
      'OU'      = $Server.ParentContainer.Replace('bmg.bagint.com/','')
      }

      $null = $result.Add($info)
}

$result | export-csv C:\Temp\serverLost.csv -NoTypeInformation #>