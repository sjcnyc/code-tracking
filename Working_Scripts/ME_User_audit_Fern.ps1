
  $getQADUserSplat = @{
      SizeLimit                        = 0
      DontUseDefaultIncludedProperties = $true
      IncludedProperties               = 'FirstName', 'LastName', 'SamAccountName', 'ParentContainer', 'Mail', 'Department', 'Company', 'AccountIsDisabled'
      Enabled                          = $true
  }

  Get-QADUser @getQADUserSplat | Select-Object $getQADUserSplat.IncludedProperties| Export-Csv D:\Temp\ME_Users_$(get-date -f {MMdyyyyhhmm}).csv -NoTypeInformation


$getADUserSplat = @{
  Filter     = {(Enabled -eq $True)}
  Properties = 'sAMAccountName', 'givenName', 'sn', 'enabled', 'CanonicalName', 'Mail', 'Department', 'Company'
}

Get-ADUser @getADUserSplat |
  Select-Object $getADUserSplat.Properties |
  Export-Csv -Path "D:\Temp\ME_Users_Enabled2.csv" -NoTypeInformation