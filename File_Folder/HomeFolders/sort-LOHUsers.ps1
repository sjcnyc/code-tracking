$folders = Get-ChildItem '\\storage\home$' -Directory -Depth 0

foreach ($folder in $folders)
{
  #  Write-Host $folder.Name
    $LOHuser = Get-QADUser $folder.Name -Disabled

    if ($LOHuser -ne $null -and $LOHuser.ParentContainer -like 'bmg.bagint.com/USA/GBL/USR/LOH') {

    #  Write-Host $LOHuser.SamAccountName
      Rename-Item -Path $folder.FullName -NewName "LOH_$($folder.Name)" -WhatIf
   }
}
