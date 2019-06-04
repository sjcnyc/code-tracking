#requires -Version 3
function Get-FolderPermissions {
    param
    (
        [System.Object]
        $path
    )

    $PathList = Get-ChildItem -Directory -Path $path
    
    Foreach ($path in $PathList) {
        $dateTime = Get-Date -Format s
        $dateTime = $dateTime -replace ':', '_'
        $dateTime = $dateTime.ToString()

        Write-Host $path.FullName 'Is Being Processed'
        $ReportOutput = @()
        $DirList = @()
        $DirList = (Get-ChildItem -WarningAction SilentlyContinue -Directory -Path $path.FullName -Recurse).FullName
        $DirList += $path.FullName
    
        Foreach ($Dir in $DirList) {
            $GetFolderACL = $Null
            $GetFolderACL = (Get-Acl $Dir).Access | Where-Object -FilterScript {$_.IsInherited -EQ 0 -and $_.InheritanceFlags -ne 'None'}
            If ($GetFolderACL.Count -GE 1) {
                $ProtectedFolder = $False
                $ProtectedFolder = (Get-Acl $Dir).AreAccessRulesProtected

                $result = New-Object -TypeName System.Collections.ArrayList

                ForEach ($ACL in $GetFolderACL) {
                    $r = [PSCustomObject]@{
                        'Path' = $Dir
                        'Identity' = $ACL.IdentityReference
                        'Rights' = ($ACL.FileSystemRights | Out-String).Trim()
                        'InheritanceFlags' = ($ACL.InheritanceFlags | Out-String).Trim()
                        'Propagation' = $ACL.PropagationFlags
                        'Protected' = $ProtectedFolder
                    }
                    $null = $result.Add($r)
                }
            }
        }
        $result # | Export-Csv -Path 'c:\temp\report_0001.csv' -NoTypeInformation -Append
    }
}
