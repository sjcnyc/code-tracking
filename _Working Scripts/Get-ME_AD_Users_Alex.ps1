using namespace System.Collections.Generic

function Convert-IntTodate {
    param ($Integer = 0)
    if ($null -eq $Integer) {
      $date = $null
    }
    else {
      $date = [datetime]::FromFileTime($Integer).ToString('g')
      if ($date.IsDaylightSavingTime) {
        $date = $date.AddHours(1)
      }
      $date
    }
  }

$UserList = [List[PSObject]]::new()

$getQaduserSplat = @{
  Properties = 'sAMAccountName',
               'givenName',
               'initials',
               'sn',
               'name',
               'displayName',
               'streetAddress',
               'l',
               'st',
               'c',
               'postalCode',
               'company',
               'department',
               'title',
               'telephoneNumber',
               'Manager',
               'employeeid',
               'emailaddress',
               'mail',
               'proxyaddresses',
               'whenCreated',
               'whenChanged',
               'UserPrincipalName',
               'LastLogon',
               'LastLogonTimestamp',
               'Enabled',
               'CanonicalName',
               'msNPAllowDialin'
  Filter = "*"
}

$users = Get-ADUser @getQaduserSplat | Select-Object $getQaduserSplat.IncludedProperties

foreach ($user in $users) {
  $PSobj = [pscustomobject]@{
    sAMAccountName     = $User.sAMAccountName
    givenName          = $User.givenName
    initials           = $User.initials
    sn                 = $User.sn
    name               = $User.name
    displayName        = $User.displayName
    streetAddress      = $User.streetAddress
    l                  = $User.l
    st                 = $User.st
    c                  = $User.c
    postalCode         = $User.postalCode
    company            = $User.company
    department         = $User.department
    title              = $User.title
    telephoneNumber    = $User.telephoneNumber
    Manager            = $User.Manager
    msNPAllowDialin    = $User.msNPAllowDialin
    employeeid         = $User.employeeid
    email              = $User.emailaddress
    mail               = $User.mail
    whenCreated        = $User.whenCreated
    whenChanged        = $User.whenChanged
    UserPrincipalName  = $User.UserPrincipalName
    LastLogon          = (Convert-IntTodate $User.LastLogon)
    LastLogonTimestamp = (Convert-IntTodate $User.LastLogonTimestamp)
    Enabled            = $User.Enabled
    ParentContainer    = $User.CanonicalName
    ProxyAddresses     = ($user | Select-Object -ExpandProperty proxyaddresses | Out-String).Trim()

  }
  [void]$UserList.Add($PSobj)
}

$UserList | Export-Csv D:\temp\ME_AD_DUMP_AD.csv -NoTypeInformation