@'
GROS207
'@ -split [environment]::NewLine |

  ForEach-Object -Process {
  [pscustomobject]@{
    'SamAccountName' = $_
    'Email' = (Get-QADUser $_).Mail
  } #| Export-Csv c:\temp\RoEmail_01.csv -NoTypeInformation -Append
}