

Get-QADUser -IncludeAllProperties -SizeLimit 0 -SearchScope Subtree -Service me.sonymusic.com |
Select-Object SAMAccountName, Displayname,useraccountcontrol,distinguishedname, parentcontainer, `
	 @{N='AccountStatus';E={if ($_.AccountIsDisabled -eq 'TRUE'){'Disabled'}else{'Enabled'}}} |
		Export-Csv -Path 'c:\temp\me_user_report_3.csv' -NoTypeInformation



@"
DC=me,DC=sonymusic,DC=com
"@ -split [environment]::NewLine | ForEach-Object {

  $Filter = [RegEx]'^*OU=Employee*|^*OU=Non-Employee'

  $getADUserSplat = @{
    SearchBase = $_
    Properties = 'SamAccountName', 'Name', 'DistinguishedName'
    Server     = "me.sonymusic.com"
    Filter     = '*'
  }

  Get-ADUser @getADUserSplat |Where-Object {$_.DistinguishedName -match $Filter} |Select-Object SAMAccountName, Name, DistinguishedName |Export-Csv -Path 'c:\temp\ME_Admin_Report.csv' -NoTypeInformation -Append

}