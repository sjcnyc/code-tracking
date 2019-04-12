# requires OktaAPI: https://github.com/gabrielsroka/OktaAPI.psm1
#Connect-Okta "00sWalAzrQfemGnMShMBwx2Goob6FO3vh53hS3bXYE" "https://mcapri.oktapreview.com"
Connect-Okta "004R6LKh-Az6qMyTpZnm7wnDOHSLXM3qFcmOZsQ0WD" "https://sonymusic.okta.com"
function Get-MfaUsers() {
  $totalUsers = 0
  $mfaUsers = @()
  # for more filters, see https://developer.okta.com/docs/api/resources/users#list-users-with-a-filter
  $params = @{filter = 'status eq "ACTIVE"'}
  do {
    $page = Get-OktaUsers @params
    $users = $page.objects
    foreach ($user in $users) {
      $factors = Get-OktaFactors $user.id

      $sms = $factors.where( {$_.factorType -eq "sms"})
      $call = $factors.where( {$_.factorType -eq "call"})
      $push = $factors.where( {$_.factorType -eq "push"})

      $mfaUsers += [PSCustomObject]@{
        id                           = $user.id
        name                         = $user.profile.login
        sms                          = $sms.factorType
        sms_enrolled                 = $sms.created
        sms_status                   = $sms.status
        call                         = $call.factorType
        call_enrolled                = $call.created
        call_status                  = $call.status
        push                         = $push.factorType
        push_enrolled                = $push.created
        push_status                  = $push.status
        token                        = $token.factorType
        token_enrolled               = $token.created
        token_status                 = $token.status
        token_software_totp          = $token_software_totp.factorType
        token_software_totp_enrolled = $token_software_totp.created
        token_software_totp_status   = $token_software_totp.status
      }
    }
    $totalUsers += $users.count
    $params = @{url = $page.nextUrl}
  } while ($page.nextUrl)
  $mfaUsers | Export-Csv c:\temp\mfaUsers_001.csv -notype
  "$totalUsers users found."
}
Get-MfaUsers