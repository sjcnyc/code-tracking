$Items = Get-ChildItem -Path '\\server\share' -Recurse
foreach ($Item in $Items) {
  switch ($Item.PSIsContainer) {
    $true {
      [System.Security.AccessControl.DirectorySecurity]::new($Item.fullname, ('Owner', 'Group', 'Access')).
      GetSecurityDescriptorSddlForm(('Owner', 'Group', 'Access')); break 
    }

    $false {
      [System.Security.AccessControl.FileSecurity]::new($Item.fullname, ('Owner', 'Group', 'Access')).
      GetSecurityDescriptorSddlForm(('Owner', 'Group', 'Access')); break
    }
  }
}