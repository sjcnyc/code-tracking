<#$QADParams = @{
  SizeLimit                        = '0'
  PageSize                         = '2000'
  DontUseDefaultIncludedProperties = $true
  IncludedProperties               = @('sAMAccountName','FirstName','LastName','parentContainer')
  SearchScope                      = 'Subtree'
}
#>
<#Get-QADUser -Service 'NYCSMEADS0012:389' @QADParams -Enabled | 
Select-Object -Property SAMAccountName, FirstName, LastName, parentContainer| Export-Csv -Path "$env:HOMEDRIVE\Temp\all_user_export12.csv" -NoTypeInformation
#>



$CSVReport = Import-Csv -Path C:\temp\O365_report.csv 
$result = New-Object System.Collections.ArrayList

foreach ($user in $CSVReport.Alias) {

  $userinfo = Get-QADUser $user -IncludedProperties SamaccountName, AccountIsDisabled


  $info = [pscustomobject]@{

    'SamAccountName'  = $user
    'UserExists'      = if ($userinfo.SamAccountName -eq $null) {'False'}else{'True'}
    'AccountStatus'   = if ($userinfo.AccountIsDisabled -eq 'TRUE'){'Disabled'}else{'Enabled'}
  }
  
  $null = $result.Add($info)
  $result
}

$result | Export-Csv 'C:\temp\O365_report2.csv' -NoTypeInformation


#$csv = Import-Csv C:\temp\AsiaLink1.csv ; $csv | ForEach-Object {Get-ADuser -Identity $_.samaccountname | Select-Object SAMAccountName, DisplayName, @{N ='AccountStatus';E={if($_.AccountIsDisabled -eq 'TRUE'){'Disabled'}else{'Enabled'}}}} | Export-Csv c:\temp\exportAsiaAccountStatus.csv -NoTypeInformation
