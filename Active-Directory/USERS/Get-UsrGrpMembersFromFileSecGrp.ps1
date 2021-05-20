$filter='^.*Administrators$|^.*All Share Access$|^.*Infra_Admins$|^.*Desktop Operations$';
$path=  '\\storage\creative-ny$\CG Artist Archive'

$path |
    ForEach-Object {$_} |
    Get-Acl |
    ForEach-Object {$_.Access } |
    Select-Object IdentityReference |
    Where-Object {$i=$_.IdentityReference;$i -like 'BMG\*' -and $i -notmatch $filter} |
    ForEach-Object {$i.value.replace('BMG\','') |
    Get-QADGroup |
    ForEach-Object {$g=$_;Get-QADGroupMember $g | 
    Select-Object name,samaccountname}} | 
    Format-Table -AutoSize