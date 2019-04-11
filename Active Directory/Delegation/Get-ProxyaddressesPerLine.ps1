

Get-ADuser sconnea -properties ProxyAddresses, Displayname, Mail, UserPrincipalName,CanonicalName, Description -Server 'me.sonymusic.com' | ForEach-Object {
  foreach ($Proxy in $_.ProxyAddresses) {
    [pscustomobject]@{
      Name              = $_.Name
      SamAccountname    = $_.SamAccountName
      mail              = $_.mail
      UserPrincipalName = $_.UserPrincipalName
      CanonicalName     = $_.CanonicalName
      Description       = $_.Description
      ProxyAddress      = $Proxy
    }
  }
}