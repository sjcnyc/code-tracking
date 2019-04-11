[CmdletBinding(SupportsShouldProcess = $true)]
Param()

Set-QADPSSnapinSettings -DefaultSizeLimit 0
$SourceGroup = 'CN=USA-GBL Wireless Computers Certificate,OU=Non-Restricted,OU=GRP,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com'
$TargetWin   = 'CN=WWI-Wireless-PC-PKI,OU=GRP,OU=WWI,DC=bmg,DC=bagint,DC=com'
$TargetMac   = 'CN=WWI-Wireless-MAC-PKI,OU=GRP,OU=WWI,DC=bmg,DC=bagint,DC=com'

try
{
  $Computers = Get-QADGroup -Identity 'USA-GBL Wireless Computers Certificate' |
  Get-QADGroupMember | 
  Get-QADComputer | 
  Select-Object -Property Name, OSName, sAMAccountName

  foreach ($comp in $Computers) 
  {
    if ($comp.OSName -match 'Mac') 
    {
      Write-Verbose -Message ('{0}.Name is a MAC' -f $comp.Name)
      Add-QADGroupMember -Identity $TargetMac -Member $comp.SamAccountName #-WhatIf -Verbose
      Remove-QADGroupMember -Identity $SourceGroup -Member $comp.SamAccountName #-WhatIf -Verbose
    }
    elseif ($comp.OSName -match 'Windows') 
    {
      Write-Verbose -Message ('{0}.Name is a PC' -f $comp.Name)
      Add-QADGroupMember -Identity $TargetWin -Member $comp.SamAccountName #-WhatIf -Verbose 
      Remove-QADGroupMember -Identity $SourceGroup -Member $comp.SamAccountName #-WhatIf -Verbose
    }
  }
}
catch
{
  ('Error: {0}' -f $_)
}