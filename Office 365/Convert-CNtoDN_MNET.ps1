#requires -Version 1.0
function ConvertFrom-Canonical {
    param([string]$canoincal = (throw ('{0} is required!' -f $Canonical)))
    $obj = $canoincal.Replace(',', '\,').Split('/')
    [string]$DN = 'OU=' + $obj[$obj.count - 1] # was CN=
    for ($i = $obj.count - 2; $i -ge 1; $i--) {
        $DN += ',OU=' + $obj[$i]
    }
    $obj[0].split('.') | ForEach-Object -Process { $DN += ',DC=' + $_}
    return $DN
}

$users = Import-Csv C:\temp\ReadyforAADSync_Apr262017.csv
$result = New-Object -TypeName System.Collections.ArrayList

foreach ($user in $users) {

  $info = [pscustomobject]@{
    'SamAccountName'    = $user.samaccountname
    'DistinguishedName' = $user.DistinguishedName
    'ParentContainer'   = (ConvertFrom-Canonical $user.OrganizationalUnit)
  }
  
  $null = $result.Add($info)

}

$result | Export-Csv -Path 'c:\temp\MNET_Partentcontainers2.csv' -NoTypeInformationz