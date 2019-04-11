$Currentdate = Get-Date

$QADParams = @{
  SizeLimit                        = '0'
  PageSize                         = '2000'
  DontUseDefaultIncludedProperties = $true
  IncludedProperties               = @('Name', 'LastLogonTimeStamp', 'SamAccountName', 'ParentContainer')
 # SearchRoot = @('bmg.bagint.com/USA/GBL/USR/Employees', 'bmg.bagint.com/USA/GBL/USR/Arcade', 'bmg.bagint.com/USA/GBL/USR/Non Employee Users', 'bmg.bagint.com/USA/GBL/USR/ES Royalties')
}


(Get-QADUser @QADParams -Enabled | Select-Object Name, LastLogonTimeStamp, SamAccountName, ParentContainer| 
  Where-Object { $_.LastLogonTimeStamp -ne $Null -and ($Currentdate-$_.LastLogonTimeStamp).Days -gt '30' }).count 