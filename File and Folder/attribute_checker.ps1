<#$dir = '\\storage\columbia$\201X Dropbox'

    Get-ChildItem -Path $dir -Recurse -Force | 

    Where-Object { ($_.Attributes.ToString() -Split ", ") -Contains "Hidden" -and $_.Name -ne '.DS_Store' } | 
    Select-Object -ExpandProperty FullName

#># .dummy Thumbs.db



function Get-FileAttribute {
    param(
        [Parameter(Mandatory)]$file,
        [Parameter(Mandatory)][ValidateSet('ReadOnly', 'Hidden', 'Normal')]$attribute
    )
    $val = [IO.FileAttributes]$attribute;
    if ((Get-ChildItem -Path $file -Force).Attributes -band $val -eq $val) {
    
        $script:Filename = $file

        $filename
    
    }
}

function Set-FileAttribute {
    param(
        [Parameter(Mandatory)]$file,
        [Parameter(Mandatory)][ValidateSet('ReadOnly', 'Hidden', 'Normal')]$attribute
    )
    $file = (Get-ChildItem -Path $file -Force);
    $file.Attributes = $file.Attributes -bor ([IO.FileAttributes]$attribute).value__;
    if ($?) {$true; } else {$false; }
}

function Clear-FileAttribute {
    param(
        [Parameter(Mandatory)]$file,
        [Parameter(Mandatory)][ValidateSet('ReadOnly', 'Hidden', 'Normal')]$attribute
    )
    $file = (Get-ChildItem -Path $file -Force);
    $file.Attributes -= ([System.IO.FileAttributes]$attribute).value__;
    if ($?) {$true; } else {$false; }
}

<#
ReadOnly
Hidden
System
Directory
Archive
Device
Normal
Temporary
SparseFile
ReparsePoint
Compressed
Offline
NotContentIndexed
Encrypted
#>