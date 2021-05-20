$folders = Get-ChildItem '\\storage.me.sonymusic.com\home$\sconnea' -Directory

$output =
foreach ($Folder in $Folders) {
  $ACLs = Get-Acl $Folder.fullname

  $ACLs.Access | ForEach-Object {
    $ACL = $_

    [PSCustomObject]@{
      Foldername = $folder.FullName
      Name       = $acl.IdentityReference
      SID        = $ACL.IdentityReference.Translate([System.Security.Principal.SecurityIdentifier])
      Domain     = Get-adgroup -ea 0 -Identity ($ACL.IdentityReference.Translate([System.Security.Principal.SecurityIdentifier])) -prop CanonicalName | Select -ExpandProperty CanonicalName
    }
  }
}

$output | Where-Object Sid -eq "S-1-5-21-804046446-3026172632-3320083432-5642"

# Find the bmg sid then add to where-object filter above
# Is this for remediation?