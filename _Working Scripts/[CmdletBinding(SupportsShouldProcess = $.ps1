[CmdletBinding(SupportsShouldProcess = $true)]
Param()

#Add-Type -AssemblyName Microsoft.ActiveDirectory.Management

$users = Import-Csv -Path "$env:HOMEDRIVE\temp\AdAttribUpdates\New Zealand for Sean.csv"

foreach ($user in $users) {

    $GivenName      = $user.'First Name'
    $Surname        = $user.'Last Name'
    $DisplayName    = $user.'Display Name'
    $StreetAddress  = $user.'Address/Street'
    $SamAccountName = $user.Name
    $City           = $user.City
    $State          = $user.'State/Province'
    $PostCode       = $user.'ZIP/Postal Code'
    $Country        = $user.Country
    $Title          = $user.'Job Title'
    $Company        = $user.Company
    $Description    = $user.Description
    $Department     = $user.Department
    $Office         = $user.Office
    $Phone          = $user.'Telephone Number'
    $Mail           = $user.'Email Address'
    $Manager        = $user.Manager
    $fax            = $user.'Fax Number'

  $ManagerDN = if ($Manager) {
    Get-ADUser -LDAPFilter "(displayname=$manager)" -Properties SamAccountName | Select-Object -Property SamAccountName
  }

  Import-Csv -Path "$env:HOMEDRIVE\temp\Country_Codes.csv" | ForEach-Object -Process {
    $CountryName = $_.'Country Name'
    $CountryCode = $_.Codes

    if ($Country -eq "$CountryName") {
      $Country = "$CountryCode"
    }
  }

  try {
    $SamExists = (Get-ADUser -Identity $SamAccountName -ErrorAction 0).SamAccountName

    if ($SamExists -eq $SamAccountName -and $null -ne $SamExists) {
      if ($DisplayName) {
        Set-ADUser -Identity $SamAccountName -Replace @{ displayName = $DisplayName }
      }
      if ($GivenName) {
        Set-ADUser -Identity $SamAccountName -GivenName $GivenName
      }
      if ($Surname) {
        Set-ADUser -Identity $SamAccountName -Surname $Surname
      }
      if ($StreetAddress) {
        Set-ADUser -Identity $SamAccountName -Replace @{ StreetAddress = $StreetAddress }
      }
      if ($City ) {
        Set-ADUser -Identity $SamAccountName -Replace @{ l = $City }
      }
      if ($State) {
        Set-ADUser -Identity $SamAccountName -State $State
      }
      if ($PostCode) {
        Set-ADUser -Identity $SamAccountName -Replace @{ postalCode = $PostCode }
      }
      if ($Country) {
        Set-ADUser -Identity $SamAccountName -Country $Country
      }
      if ($Title) {
        Set-ADUser -Identity $SamAccountName -Replace @{ Title = $Title }
      }
      if ($Company) {
        Set-ADUser -Identity $SamAccountName -Replace @{ Company = $Company }
      }
      if ($Description) {
        Set-ADUser -Identity $SamAccountName -Replace @{ Description = $Description }
      }
      if ($Department) {
        Set-ADUser -Identity $SamAccountName -Replace @{ Department = $Department }
      }
      if ($Office) {
        Set-ADUser -Identity $SamAccountName -Replace @{ physicalDeliveryOfficeName = $Office }
      }
      if ($Phone) {
        Set-ADUser -Identity $SamAccountName -Replace @{ telephoneNumber = $Phone }
      }
      if ($Mail) {
        Set-ADUser -Identity $SamAccountName -Replace @{ mail = $Mail }
      }
      if ($fax) {
        Set-ADUser -Identity $SamAccountName -Fax $fax
      }
      if ($Manager -and $ManagerDN) {
        Set-ADUser -Identity $SamAccountName -Manager $ManagerDN
      }
    }
  }
  catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    [Management.Automation.ErrorRecord]$e = $_
    $info = [PSCustomObject]@{
      Exception = $e.Exception.Message
    }
    $info.Exception
  }
}