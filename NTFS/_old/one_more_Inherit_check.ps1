function Get-CustomDirInfo {
   param
   (
     [System.String]
     $path,
  
     [System.Int32]
     $level = 0
   )
    
    [long]$size = 0
    $fileCount = 0
    $folderCount = 0
    $path | Get-ChildItem -ea silentlycontinue | Foreach-Object { 
        if ($_.PsIsContainer) { 
            $folder = Get-CustomDirInfo $_.FullName ($level + 1)
            $size += @($folder)[-1].Size
            $folderCount++
            $folder
        } else { 
            $fileCount++
            $size += $_.Length
        } 
    }    
    ($path | Get-Acl).Access | Foreach-Object { 
        New-Object PSObject -Property @{
            Path = $path;
            IdentityReference = $_.IdentityReference;
            FileSystemRights = $_.FileSystemRights;
            IsInherited = $_.IsInherited;
            Size = $size;
            FileCount = $fileCount;
            FolderCount = $folderCount;
            Level = $level
        }
    }
}


#$path = @('\\usculvwweb001\c$\inetpub\wwwroot\brain','\\lynsbmeweb001\e$\brain')


Get-CustomDirInfo '\\usculvwweb001\c$\inetpub\wwwroot\brain' | Select-Object `
      Path, IdentityReference, FileSystemRights |
      Export-Csv 'c:\temp\FileSystemRights_usculvwweb001_2.csv' -NoTypeInformation
      

<#
Get-CustomDirInfo c:\temp | Where-Object { $_.Level -lt 2 } | 
    Select-Object Path, IdentityReference, FileSystemRights, IsInherited, Size, FileCount, FolderCount |
  Export-Csv c:\output.csv -NoTypeInformation#>