class ADUser {
  [string]$Username
  [string]$Enabled
  [string]$Displayname
  [string]$Title
  [string]$Department
  [string]$EmailAddress
  [string]$CanonicalName
  [string]$City
  [string]$co
  [string]$OfficePhone
  [string]$MobilePhone
  [string]$ipPhone
  [array]$MemberOf
  [array]$DirectReports
  [string]$homeMDB
  [string]$Created
  [string]$Modified
  [string]$LastBadPasswordAttempt
  [string]$PasswordLastSet
 
  # Constructor
  ADUser ([string] $Username) {
    $this.Username = $Username
    $Properties = @(
      'CanonicalName',
      'City',
      'co',
      'Created',
      'Department',
      'DirectReports',
      'Displayname',
      'EmailAddress',
      'Enabled',
      'homeMDB',
      'ipPhone',
      'LastBadPasswordAttempt',
      'MemberOf',
      'MobilePhone',
      'Modified',
      'OfficePhone',
      'PasswordLastSet',
      'Title'
    )
    try {
      $P = Get-ADUser $Username -Properties $Properties | Select-Object $Properties
      $Properties | ForEach-Object {
        $this.$_ = $P.$_
      }
    }
    Catch {
      $_; continue
    }
  }
}