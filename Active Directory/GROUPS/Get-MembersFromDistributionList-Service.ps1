#Requires -Version 3.0 
<# 
.SYNOPSIS 

.DESCRIPTION 

 
.NOTES 
    File Name  : Get-MembersFromDistributionList-Service
    Author     : Sean Connealy
    Requires   : PowerShell Version 3.0 
.LINK 
    This script posted to: 
        http://www.github/sjcnyc
.EXAMPLE

.EXAMPLE

#>

@"
Glbl Mkt-International All 
"@ -split [environment]::NewLine |

Get-QADGroup -Service 'nycmnetads001.mnet.biz:389' -SizeLimit '0'   |
ForEach-Object {
  $_ | 
  Get-QADGroupMember -SizeLimit '0' | Select-Object DisplayName, eMail -Unique |
  Add-Member -MemberType NoteProperty -Name 'Group Name' -Value $_.displayname -PassThru |
  Add-Member -MemberType NoteProperty -Name 'Alias' -Value $_.alias -PassThru } |
  Export-Csv  c:\temp\DLReport_003.csv -Append -NoTypeInformation




  # this one works well.  Should look at $_ and foreach ??? pipeline ???

Move-QADObject -Service 'nycmnetads001.mnet.biz:389'