﻿#Requires -Version 3.0            
            
Function Get-ACE {            
Param (            
        [parameter(Mandatory=$true)]            
        [string]            
        [ValidateScript({Test-Path -Path $_})]            
        $Path            
)            
            
    $ErrorLog = @()            
            
    Write-Progress -Activity 'Collecting folders' -Status $Path `
        -PercentComplete 0            
    $folders = @()            
    $folders += Get-Item $Path | Select-Object -ExpandProperty FullName            
 $subfolders = Get-Childitem $Path -Recurse -ErrorVariable +ErrorLog `
        -ErrorAction SilentlyContinue |             
        Where-Object {$_.PSIsContainer -eq $true} |             
        Select-Object -ExpandProperty FullName            
    Write-Progress -Activity 'Collecting folders' -Status $Path `
        -PercentComplete 100            
            
    # We don't want to add a null object to the list if there are no subfolders            
    If ($subfolders) {$folders += $subfolders}            
    $i = 0            
    $FolderCount = $folders.count            
            
    ForEach ($folder in $folders) {            
            
        Write-Progress -Activity 'Scanning folders' -CurrentOperation $folder `
            -Status $Path -PercentComplete ($i/$FolderCount*100)            
        $i++            
            
        # Get-ACL cannot report some errors out to the ErrorVariable.            
        # Therefore we have to capture this error using other means.            
        Try {            
            $acl = Get-ACL -LiteralPath $folder -ErrorAction Continue            
        }            
        Catch {            
            $ErrorLog += New-Object PSObject `
                -Property @{CategoryInfo=$_.CategoryInfo;TargetObject=$folder}            
        }            
            
        $acl.access |             
            Where-Object {$_.IsInherited -eq $false} |            
            Select-Object `
                @{name='Root';expression={$path}}, `
                @{name='Path';expression={$folder}}, `
                IdentityReference, FileSystemRights, IsInherited, `
                InheritanceFlags, PropagationFlags            
            
    }            
                
    $ErrorLog |            
        Select-Object CategoryInfo, TargetObject |            
        Export-Csv ".\Errors_$($Path.Replace('\','_').Replace(':','_')).csv" `
            -NoTypeInformation            
            
}            
            
# Call the function for each path in the text file            
Get-Content .\paths.txt |             
    ForEach-Object {            
        If (Test-Path -Path $_) {            
            Get-ACE -Path $_ |            
                Export-CSV `
                    -Path ".\ACEs_$($_.Replace('\','_').Replace(':','_')).csv" `
                    -NoTypeInformation            
        } Else {            
            Write-Warning "Invalid path: $_"            
        }            
    }            