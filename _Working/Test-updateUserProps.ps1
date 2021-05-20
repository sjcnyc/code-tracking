function Update-ADUserAttributes {
  [CmdletBinding(SupportsShouldProcess = $true)]
  Param(
    [string]
    $csvFile
  )

  #Add-Type -AssemblyName Microsoft.ActiveDirectory.Management

  $Users = Import-Csv C:\Temp\AD.csv
  $Userprops = $Users[0].psobject.Properties.Name

  foreach ($User in $Users) {

    try {
      $SamAccountExists = (Get-ADUser -Identity $User.SamAccountName -ea 0).SamAccountName

      if ($SamAccountExists -eq $User.SamAccountName -and $null -ne $User.SamAccountName) {

        $ManagerDN = if ($User.Manager) {
          Get-ADUser -LDAPFilter "(displayname=$User.manager)" -Properties SamAccountName | Select-Object -Property SamAccountName
        }

        switch ($Userprops) {
          DESCRIPTION                 { Set-ADUser -Identity $User.SamAccountName -Replace @{ Description = $User.Description }}
          TITLE                       { Set-ADUser -Identity $User.SamAccountName -Replace @{ Title = $User.Title }}
          GIVEN_NAME                  { Set-ADUser -Identity $User.SamAccountName -GivenName $User.GivenName }
          SURNAME                     { Set-ADUser -Identity $User.SamAccountName -Surname $User.Surname }
          DISPLAYNAME                 { Set-ADUser -Identity $User.SamAccountName -Replace @{ displayName = $User.Displayname }
          MAIL                        { Set-ADUser -Identity $User.SamAccountName -Replace @{ mail = $User.Mail }}
          TELEPHONENUMBER             { Set-ADUser -Identity $User.SamAccountName -Replace @{ telephoneNumber = $User.Phone }}
          COMPANY                     { Set-ADUser -Identity $User.SamAccountName -Replace @{ Company = $User.Company }}
          STREETADDRESS               { Set-ADUser -Identity $User.SamAccountName -Replace @{ StreetAddress = $User.StreetAddress}}
          L                           { Set-ADUser -Identity $User.SamAccountName -Replace @{ l = $User.City }}
          ST                          { Set-ADUser -Identity $User.SamAccountName -State $User.State }
          POSTALCODE                  { Set-ADUser -Identity $User.SamAccountName -Replace @{ postalCode = $User.PostCode }}
          #CO
          C                           { Set-ADUser -Identity $User.SamAccountName -Country $User.Country }
          PHYSICALDELIVERYOFFICENAME  { Set-ADUser -Identity $User.SamAccountName -Replace @{ physicalDeliveryOfficeName = $User.Office }}
          DEPARTMENT                  { Set-ADUser -Identity $User.SamAccountName -Replace @{ Department = $User.Department }}
          Manager                     { if ($User.Manager -and $ManagerDN) {Set-ADUser -Identity $User.SamAccountName -Manager $ManagerDN }}
          }
          Default {
            break
          }
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
}