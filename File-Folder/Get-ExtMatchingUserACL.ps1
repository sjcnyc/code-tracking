#REQUIRES -Version 2.0

<#  
.SYNOPSIS  
    Search Filetypes by extension where ACL IdentityReference matches user name

.DESCRIPTION  
    Created to find missing *.pst files on network share ;)
    Recursive search for all *.pst files with ACL DOMAIN\username
    .NET GetFiles used to overcome MAX_PATH limit of 256 char (http://msdn.microsoft.com/en-us/library/system.io.directory.getfiles.aspx)
    2x faster than cmd dir
    10x faster than gci (gci fails @ MAX_PATH)

.NOTES  
    File Name      : Get-ExtMatchingUserACL.ps1  
    Author         : Sean Connealy
    Prerequisite   : PowerShell V2 over Vista and upper.
    
.LINK  
    Script posted over: http://www.willMakeARepoSoon.com
      
.EXAMPLE  
    .\Get-ExtMatchingUserACL -Path \\server\folders\ -SearchString '*.pst' -user 'foobar' 
    .\Get-ExtMatchingUserACL -Path \\server\folders\ -SearchString '*.pst' -user 'foobar' -export 'c:\foobar.csv'  

#>

[reflection.assembly]::loadwithpartialname('Microsoft.VisualBasic') | Out-Null

$fn=@{n='FileName';e={$f}};$name=@{n='Name';e={$_.IdentityReference}};

Function Get-ExtMatchingUserACL{

    param ([Parameter(Mandatory=$true, ValueFromPipeline = $true)][string]$Path,
           [Parameter(Mandatory=$true)][string]$SearchString,
           [Parameter(Mandatory=$true)][string]$user,
           [Parameter(Mandatory=$false)][string]$Export)

    try {
            $output= [Microsoft.VisualBasic.FileIO.FileSystem]::GetFiles($Path,[Microsoft.VisualBasic.FileIO.SearchOption]::SearchAllSubDirectories,$SearchString) |
             %{$f=$_; $f | Get-Acl -ea 0 | % {$_.Access} | Where-Object {$_.IdentityReference -match $user} | Select-Object $name, $fn}
             if ($export) { $output | export-csv $export -NoType }

             else {
                     $output | Format-Table -AutoSize
                  }

         } catch { $_ }
}


    Get-ExtMatchingUserACL -Path \\storage\ifs$\data\Production_Shares\offboard\home\ -SearchString *.doc -user adadlan 
     


