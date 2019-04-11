function Get-IsMember {
  param (
    [string]
    $GroupName,

    [array]
    $Users
  )
  $Users | ForEach-Object {
    if ((Get-ADGroupMember $GroupName |Select-Object -ExpandProperty SamAccountName) -notcontains $_) {
      return $_
    }
  }
}

$gp = "USA-GBL Member Server Administrators"
$Users = @("sconnea", "klee123", "bobxxx")

Get-ismember -GroupName $gp -Users $Users