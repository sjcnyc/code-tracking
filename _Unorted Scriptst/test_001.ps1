Import-Module -Name ActiveDirectory -Verbose:$false; 
$users = Import-Csv -Path 'C:\temp\Export006.csv' 

$result = New-Object System.Collections.ArrayList;

Foreach ($user in $users){  
  $UserDn = get-aduser -Identity $user.SamAccountName | Select-Object Distinguishedname
  $parentContainer = (([adsi]"LDAP://$($UserDn.DistinguishedName)").Parent).Substring(7)
  
  $info = [pscustomobject]@{

    'SamAccountName' = $user.SamAccountName
    'DistinguishedName' = $user.DistinguishedName
    'DisplayName' = $user.DisplayName
    'ParentContainer' = $parentContainer
  }
  $null = $result.Add($info)
};

$result | Export-Csv 'c:\temp\ME_parentcontainers.csv' -NoTypeInformation