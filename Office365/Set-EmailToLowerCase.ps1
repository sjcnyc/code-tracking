function Log-Message
{
    Param
    (
       [Parameter(Mandatory = $true, Position = 0)]
       [string]$Message 
    )

  $Message | Out-File -FilePath "$env:HOMEDRIVE\temp\EmailLog.txt" -Append
  Write-Verbose -Message $Message
}

function Set-EmailToLowerCase 
{
  [CmdletBinding(SupportsShouldProcess = $true)]
  Param()

  $users = (Import-Csv -Path "$env:HOMEDRIVE\temp\BMGUppercaseEmail.csv")

  foreach ($user in $users)
  {
    try
    {
      $MailUpper = (Get-ADUser -Identity $user.SAMAccountName -Properties mail).Mail

       if ([string]::IsNullOrWhiteSpace($MailUpper)) 
      {
        $MNETMail = (Get-QADUser -Service 'nycmnetads001.mnet.biz:389' -Identity $user.SAMAccountName).Mail
        $mnetLower = $MNETMail.ToLower()
        Log-Message -Message ('WARN: "{0}" Mail attribute is empty, adding email address: {1}' -f $user.SAMAccountName, $mnetLower)
        Set-ADUser -Identity $user.SAMAccountName -EmailAddress $user.EmailAddress
      }
             
      elseif ($MailUpper -cmatch '[A-Z]') 
      {
        $MailLower = $MailUpper.ToLower()

        Write-Verbose -Message ('OKAY: {0} Converted to: {1}' -f $MailUpper, $MailLower)
        Set-ADUser -Identity $user.SAMAccountName -EmailAddress $MailLower
      }
      else 
      {
        Log-Message -Message ('INFO: {0} Contains no capital lettes.' -f $MailUpper)
      }
    }
    catch
    {
      Log-Message -Message ('ERR!: {0}' -f $_)
    }
  }
}

Set-EmailToLowerCase -Verbose -WhatIf