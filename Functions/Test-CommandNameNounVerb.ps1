#Requires -Version 3.0 
<# 
    .SYNOPSIS

    .DESCRIPTION
 
    .NOTES 
        File Name  : Test-CommandNameNounVerb
        Author     : Sean Connealy
        Requires   : PowerShell Version 3.0 
        Date       : 7/1/2015

    .LINK 
        This script posted to: http://www.github/sjcnyc

    .EXAMPLE

#>

function Test-CommandNameNounVerb 
{
  Param(
    [Parameter(Position = 0,Mandatory = $True,
    HelpMessage = 'What is the noun for your command?')]
    [ValidateNotNullorEmpty()]
    [string]$Noun,
    [ValidateSet('All','Common','Data','Lifecycle','Diagnostic','Communications','Security','Other')]
    [string]$Category = 'All'    
  )
  if ($Category -eq 'All') 
  {
    $verbs = Get-Verb | Select-Object -ExpandProperty Verb
  }
  else 
  {
    $verbs = Get-Verb |
    Where-Object -FilterScript {
      $_.Group -eq $Category
    } |
    Select-Object -ExpandProperty Verb
  }  
  foreach ($verb in $verbs) 
  {
    '{0}-{1}' -f $verb, $Noun
  }
}