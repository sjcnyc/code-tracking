$blacklist = 'SID', 'LastLogonDate', 'SAMAccountName'

$user = Import-Csv -Path "C:\Users\sjcny\Desktop\User_Attributes_sjcnyc.csv"
$name = $user | Get-Member -MemberType *property | Select-Object -ExpandProperty Name

$hash = [Ordered]@{ }
$name |
Sort-Object |
Where-Object {
  $_ -notin $blacklist
} |
ForEach-Object {
  $hash[$_] = $user.$_
}