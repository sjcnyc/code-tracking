function New-HomeFolders {
  param(
    [string]$csv,
    [string]$user
  )

  # $csv=Read-Host "Enter Path to CSV"
  if ($csv){
    $users=Import-Csv $csv
  }
  else {
    $users = $user
  }
       
  #Create Home Directories
  $users | ForEach-Object {mkdir($_.'\\storage\home$')}
       
  #Assign Access Rights
       
  foreach ($user in $users)
  {
    $account='BMG\'+$user.LoginName
    $homedir=$user.HomeDirectory
    $rights=[System.Security.AccessControl.FileSystemRights]::FullControl
    $inheritance=[System.Security.AccessControl.InheritanceFlags]'ContainerInherit,ObjectInherit'
    $propagation=[System.Security.AccessControl.PropagationFlags]::None
    $allowdeny=[System.Security.AccessControl.AccessControlType]::Allow
       
    $dirACE=New-Object System.Security.AccessControl.FileSystemAccessRule ($account,$rights,$inheritance,$propagation,$allowdeny)
    $dirACL=Get-Acl $homedir
    $dirACL.AddAccessRule($dirACE)
    Set-Acl $homedir $dirACL
    Write-Host $homedir access rights assigned
  }
}