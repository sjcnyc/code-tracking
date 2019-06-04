#REQUIRES -Version 2.0

<#  
  .SYNOPSIS  
    Search for Orphaned SIDs

  .DESCRIPTION  
    Search Home folders for orphaned SIDs.  
    If folder ACL contains both "S-1-5-21-" and "DOMAIN\username" DO NOT OFFBOARD.
    Either "another" user Has access to folder or an offboarded user Had access to folder
    
  .NOTES  
    File Name      : Get-OrphanedSid.ps1  
    Author         : Sean Connealy
    Prerequisite   : PowerShell V2 over Vista and upper.
    
  .LINK  
    Script posted over:  
    http://www.willMakeARepoSoon.com

  .PARAMETERS
    $Path (Mandatory) Input path of folders to search
    $Export (Optional) If true $result output to *.csv, else $result to host  
      
  .EXAMPLE  
    .\Get-OrphanedSid.ps1 -path \\server\forlders\ -export c:\export.csv 
    .\Get-OrphanedSid.ps1 -path \\server\forlders\ 
    
  .TODO
    Second loop to filter "DOMAIN\username" and only return orphaned SIDs   

#>

$pattern='^.*Administrators|^.*All Share Access|^.*Infra_Admins|^.*ISI Offboard*|^.*NA_Desktop_Operations|^.*NYC*|^.*LYN*|^.*MPL*'
$pn=@{n='Path';e={$f.FullName}};$gn=@{n='SecurityGroup';e={$ir}};

function Get-OrphanedSid {
  param ([Parameter(Mandatory=$true, ValueFromPipeline = $true)][string]$Path,
         [Parameter(Mandatory=$false)][string]$Export)
   try {
         $output = Get-ChildItem $path | % {if ($_.PSIsContainer -eq $True){$f=$_; $f}} | Get-Acl  | % {$_.Access } |
         Where-Object {$ir=$_.IdentityReference;$ir -like 'BMG\*' -and $ir -notmatch $pattern -or $ir -like '*S-1-5-21-*'} | Select-Object $pn, IdentityReference 

        # foreach ($ir in $output.identityreference) {
           # if (!($

       } catch { $_.Exception.Message; continue}

    Finally { if ($export){ $output | export-csv $export -NoType } else { $output }
     
    }
}

Get-OrphanedSid -Path \\storage\data$