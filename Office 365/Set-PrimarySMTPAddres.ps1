function Set-PrimarySMTPAddress
{
  [CmdletBinding(SupportsShouldProcess = $true)]
  Param()

  #$users = (Import-Csv "$env:HOMEDRIVE\temp\imput.csv").SAMAccountName

  $users = 
@'
blynch
safasfasfasf
sconnea
'@ -split [environment]::NewLine

  foreach ($user in $users){
    try {
      $BMGMail = (Get-QADUser -Identity $user -IncludeAllProperties).Mail
    
      if ([string]::IsNullOrWhiteSpace($BMGMail)){
        throw 'Object is Null or Empty.'
      }

      $MnetSMTP = (Get-QADUser -Service 'nycmnetads001.mnet.biz:389' -Identity $user -IncludeAllProperties).PrimarySMTPAddress
      
      if ($BMGMail -cne $MnetSMTP){
        Set-ADUser -Identity $user -Email $MnetSMTP
        Write-Verbose -Message ('Swapping {0} for {1}' -f ($BMGMail), ($MnetSMTP))
      }
      else {
        Write-Verbose -Message 'MnetSMTP and BMGMail match.'
      }
    }
    catch {
      "Error: $_"
    }
  }
}

Set-PrimarySMTPAddress -Verbose -WhatIf