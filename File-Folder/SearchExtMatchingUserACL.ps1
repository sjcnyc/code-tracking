# SearchExtMatchingUserACL.ps1
# Sean Connealy
# 2/10/12
# Purpose: to search Filetypes by extension where ACL IdentityReference matches user name.
# created to find missing *.pst files on network share ;)
# recursive search for all *.pst files with ACL DOMAIN\sconnea
# .NET GetFiles used to overcome MAX_PATH limit of 256 char
# 2x faster than cmd dir
# 10x faster than gci (gci fails @ MAX_PATH)
#  
# usage  search -path \\server\path\ -searchstring *.pst -user sconnea

[reflection.assembly]::loadwithpartialname('Microsoft.VisualBasic') | Out-Null

$fn=@{n='FileName';e={$obj}};$name=@{n='Name';e={$_.IdentityReference}};

Function Search-Ext {

    param ([Parameter(Mandatory=$true, ValueFromPipeline = $true)][string]$Path,
           [Parameter(Mandatory=$true)][string]$SearchString,
           [Parameter(Mandatory=$true)][string]$user
           )

    try {
            [Microsoft.VisualBasic.FileIO.FileSystem]::GetFiles($Path,[Microsoft.VisualBasic.FileIO.SearchOption]::SearchAllSubDirectories,$SearchString) |
             Foreach-Object {
               $obj = $_; $obj | Get-Acl -ea 0 | 
               Foreach-Object {
                 $_.Access
               } | Where-Object {
                 $_.IdentityReference -match $user
             } | Select-Object $name, $fn} | Format-Table -auto

         } catch { $_ }
}

Search-Ext -Path '\\storage\home$' -SearchString *.pst -user sconnea 