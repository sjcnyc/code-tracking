# https://docs.microsoft.com/en-us/dotnet/api/system.web.security.membership.generatepassword?view=netframework-4.7.2
# Namespace: System.Web.Security
# Assembly: System.Web.dll
# public static string GeneratePassword (int length, int numberOfNonAlphanumericCharacters);

using namespace System.Web.Security
function New-ComplexPassword {
  param (
    [int]
    $Length,
    [int]
    $NonAlphaChars
  )

  $Passwd = [System.Web.Security.Membership]::GeneratePassword($Length, $NonAlphaChars)
  $Passwd | Set-Clipboard
  Write-Output $Passwd
}