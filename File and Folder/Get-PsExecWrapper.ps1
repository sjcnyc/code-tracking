<#
  .SYNOPSIS
  Svendsen Tech's generic PowerShell PsExec wrapper. Also look into PowerShell
  remoting which came with PowerShell v2, and consider WMI, which are better
  solutions in most cases.

  Author: Joakim Svendsen

  .DESCRIPTION
  See the online documentation for comprehensive documentation and examples at:
  http://www.powershelladmin.com/wiki/Powershell_psexec_wrapper

  .PARAMETER PsExecCommand
  The command to pass to PsExec after "PsExec.exe \\<computer> ".
  .PARAMETER ComputerList
  List of computers to process. Use a file with "(gc computerfile.txt)".
  .PARAMETER OutputFile
  Output file name. You will be asked to overwrite unless -Clobber is specified.
  .PARAMETER MultiLineJoinString
  The string to join multi-line output with in the second CSV field or XML field, if necessary.
  .PARAMETER DelimiterJoinString
  The string that separates lines in the PsExec output. You can specify a newline with "`n".
  Also see -RegexoptionNoSingleLine
  .PARAMETER ExtractionRegex
  The first capture group, indicated by parentheses, in the specified regexp, will be extracted
  instead of the entire output. If there is no match, it will fall back to -MultiLineJoinString
  and store the entire output. By default, it's "(.+)", which means "one or more of any character".
  .PARAMETER RegexOptionNoSingleLine
  Makes the regexp meta-character "." NOT match newlines.
  .PARAMETER RegexOptionCaseSensitive
  Makes the regexp case sensitive.
  .PARAMETER Clobber
  Overwrite output file if it exists without prompting.
  .PARAMETER XmlOutput
  Output to XML instead of CSV. Remember to use a full path!
#>

function Get-PsExecWrapper {

  param(
    [Parameter(Mandatory = $true)][string]   $PsExecCommand,
    [Parameter(Mandatory = $true)][string[]] $ComputerList ,
    [Parameter(Mandatory = $true)][string]   $OutputFile,
    [string] $MultiLineJoinString = ' | ',
    [string] $DelimiterJoinString = ' | ',
    [regex]  $ExtractionRegex     = '(.+)' ,
    [switch] $RegexOptionNoSingleLine,
    [switch] $RegexOptionCaseSensitive,
    [switch] $Clobber,
    [switch] $XmlOutput
  )

  Set-StrictMode -Version 2.0
  $ErrorActionPreference = 'Stop'

  # Store script start time. Will be displayed at the end along with the end time.
  $StartTime = Get-Date
  "Script start time: $StartTime"

  # Prompt to overwrite unless -Clobber is specified.
  if ( -not $Clobber -and (Test-Path $OutputFile) ) 
  {
    $Answer = Read-Host 'Output file already exists and -Clobber not specified. Overwrite? (y/n) [yes]'
    if ($Answer -imatch 'n') 
    {
      Write-Output 'Aborted.'
      exit
    }
  }

  # Remove it if it exists, and just suppress errors if it doesn't.
  Remove-Item $OutputFile -ErrorAction SilentlyContinue

  # Some minor sanity checking if the user supplied an extraction regex other than '(.+)'. Make sure they capture something.
  if ( $ExtractionRegex.ToString() -ne '(.+)' -and ($ExtractionRegex.ToString() -inotmatch '\(' -or $ExtractionRegex.ToString() -inotmatch '\)') ) 
  {
    Write-Output "The supplied regex '$($ExtractionRegex.ToString())' is missing either a '(' or a ')'.`nYou must capture something.`nSee Get-Help $($MyInvocation.MyCommand.Name).`nWill now exit with exit code 1"
    exit 1
  }

  # 45 lines to check if we have psexec.exe in current working dir or path... Should write a generic function for this.
  $PsExecFile = 'PsExec.exe'

  if ( Test-Path $PsExecFile ) 
  {
    $PsExecFullPath = '.\' + $PsExecFile
    Write-Output "Found $PsExecFile in current working directory. Using: $PsExecFullPath"
  }

  elseif ($PsExecFileObject = Get-Command $PsExecFile) 
  {
    if ($PsExecFileObject -is [System.Array]) 
    {
      $PsExecFullPath = $PsExecFileObject[0].Definition
      Write-Output "Found multiple $PsExecFile instances in path. Using this path: $PsExecFullPath"
    }
    
    elseif ($PsExecFileObject -is [System.Management.Automation.ApplicationInfo]) 
    {
      $PsExecFullPath = $PsExecFileObject.Definition
      Write-Output "Found one instance of $PsExecFile in path. Using this path: $PsExecFullPath"
    }
    
    else 
    {
      Write-Output "Unknown object type returned from 'Get-Command $PsExecFile'.`nWill now exit with status code 3"
      exit 3
    }
  }

  else 
  {
    @"
You need to download PsExec from www.sysinternals.com (redirects to microsoft.com)
in order to use this PsExec wrapper script. It needs to be in the current working
directory, or in a directory in the current PATH environment variable.

Will now exit with status code 2.
"@
    
    exit 2
  }

  # Output array
  $OutputArray = @()

  # Temporary file name
  $TempFileName = '.\Svendsen-Tech-PsExec-wrapper.tmp'

  # Add the option that makes "." match newlines unless -RegexOptionNoSingleLine is passed
  if (-not $RegexOptionNoSingleLine) 
  {
    $ExtractionRegex = [regex] ('(?s)' + $ExtractionRegex.ToString())
  }

  # Make the regex case-insensitive by default, unless -RegexOptionCaseSensitive is passed
  if (-not $RegexOptionCaseSensitive) 
  {
    $ExtractionRegex = [regex] ('(?i)' + $ExtractionRegex.ToString())
  }

  foreach ($Computer in $ComputerList) 
  {
    Write-Host -NoNewline "Processing ${Computer}... "
    
    # It returns some odd error, but it's redirected if you set $ErrorActionPreference to "Continue"...
    $ErrorActionPreference = 'Continue'
    $Output = Invoke-Expression "$PsExecFullPath \\$Computer $PsExecCommand 2> $TempFileName"
    $ErrorActionPreference = 'Stop'
    
    if (($Output -join $DelimiterJoinString) -imatch $ExtractionRegex) 
    {
      Write-Host "Regex matched. Captured: $($Matches[1])"
      $ExtractedOutput = $Matches[1]
    }
    
    else 
    {
      if ($Output) 
      {
        $ExtractedOutput = $Output
        Write-Host "Regex did not match. Using all output in $(if ($XmlOutput) 
          { 'XML field' 
          } else 
          { "lines joined with '$($MultiLineJoinString)'" 
        })."
      }
        
      else 
      {
        $ExtractedOutput = 'ERROR: No output'
        Write-Host 'Regex did not match and no output.'
      }
    }
    
    $OutputArray += ,$ExtractedOutput
  }

  if (Test-Path $TempFileName) 
  {
    Remove-Item $TempFileName -ErrorAction 'Continue'
  }

  if ($XmlOutput) 
  {
    $XmlString = '<computers>'
    
    foreach ( $i in 0..($ComputerList.Length - 1) ) 
    {
      $XmlString += '<computer><name>' + $ComputerList[$i] + '</name><output>' + $OutputArray[$i] + '</output></computer>'
    }
    
    $XmlString += '</computers>'
    
    $Xml = [xml] $XmlString
    
    $Xml.Save($OutputFile)
  }

  else 
  {
    # Create CSV headers manually
    '"ComputerName","Output"' | Out-File $OutputFile
    
    foreach ( $i in 0..($ComputerList.Length - 1) ) 
    {
      # Create CSV manually
      '"' + $ComputerList[$i] + '","' + ($OutputArray[$i] -join $MultiLineJoinString) + '"' | Out-File -Append $OutputFile
    }
  }

  @"
Done!
Script start time: $StartTime
Script end time:   $(Get-Date)
Output file: $OutputFile
"@

}

Get-PsExecWrapper -PsExecCommand 'net localgroup administrators' -ComputerList 'ny1' -OutputFile C:\TEMP\net.txt -XmlOutput