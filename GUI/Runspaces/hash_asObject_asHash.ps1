$peeps = @{
  'Lead'='asmith';
  'Enterprise'='bjones';
  'Edge'='chumperdink';
  'Backend'='dwilford';
  'SED'='fhanns'
}            

$obj = New-Object -Type PSObject -Property $peeps

$obj | Get-Member -MemberType Properties |
    ForEach-Object {$hash=@{}} {
        $hash.($_.Name) = $obj.($_.Name)
    } {$hash}