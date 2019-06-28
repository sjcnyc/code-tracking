@"

"@ -split [environment]::NewLine |
ForEach-Object {
  try {
    #Set-ADUser -Identity $_ -PasswordNeverExpires:$true
    Get-ADUser -Identity $_ -Properties PasswordNeverExpires, SamAccountName -Server "bmg.bagint.com" |
    Select-Object SamAccountName, PasswordNeverExpires |
    Export-Csv C:\Temp\passwordneverexpires_bmg_001.csv -NoTypeInformation -Append
    #Write-ToConsoleAndLog -Output "Setting PasswordNeverExpires false on: $($_)" -Log "c:\temp\_passwordNotRequired_true_BMG-ME_002.log"
  }
  catch {
    $_.exception.Message
    # Write-ToConsoleAndLog -Output "$($_.exception.Message)" -Log "c:\temp\_passwordNotRequired_true_BMG-ME_002.log"
  }
}