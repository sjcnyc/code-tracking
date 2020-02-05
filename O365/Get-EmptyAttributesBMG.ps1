

Get-QADUser -Service 'NYCSMEADS0012' -SizeLimit '0' -IncludedProperties ParentContainer, FirstName, LastName, Mail, SamAccountName, AccountIsDisabled | 
Select-Object -Property FirstName, LastName, Mail, SamAccountName, ParentContainer, AccountIsDisabled, @{
  N = 'AccountStatus'
  E = {
    if ($_.AccountIsDisabled -eq 'TRUE')
    {
      'Disabled'
    }
    else 
    {
      'Enabled'
    }
  }
} |
Where-Object -FilterScript {
  $_.FirstName -eq $null -or $_.LastName -eq $null -or $_.Mail -eq $null
} |


nycmnetads002.mnet.biz