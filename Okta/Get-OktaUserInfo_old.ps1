
Import-Module -Name Okta.Core.Automation

Connect-Okta -Token '00GRAQ3WacIl4SJplWCjQCOyK9YNLxjuFK8FpL_LeG' -FullDomain 'https://sonymusic-admin.okta.com'

#$result = New-Object -TypeName System.Collections.ArrayList

$users = Get-OktaUser

try
{
  foreach ($user in $users) {

    $info = [pscustomobject]@{

        'Logon'           = $user.Profile.Login
        'FirstName'       = $user.Profile.FirstName
        'LastName'        = $user.Profile.LastName
        'Email'           = $user.Profile.Email
        'OktaID'          = $user.Id
        'StatusChanged'   = $user.StatusChanged
        'Activated'       = $user.Activated
        'Created'         = $user.Created.Date
        'Status'          = $user.Status
        'LastLogon'       = $user.LastLogin.Date
        'LastUpdated'     = $user.LastUpdated
        'PasswordChanged' = $user.PasswordChanged
        'SamAccountName'  = (Get-QADUser -Identity $user.Profile.Login -IncludedProperties SamAccountName).SamAccountName
        'Factor'          = ((Get-OktaUserFactor -IdOrLogin $user.Profile.Login).FactorType | Out-String).Trim()
    }

    #$null = $result.Add($info)
    
    $info | Export-Csv C:\temp\OktaUserInfo_withFactorType_005.csv -NoTypeInformation -Append
  }
}

catch
{
  [Management.Automation.ErrorRecord]$e = $_

  $er = [PSCustomObject]@{
    Exception = $e.Exception.Message
  }
  $er
}

#$result | Export-Csv -Path 'C:\Temp\OktaUserInfo2.csv' -NoTypeInformation