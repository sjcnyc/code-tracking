function Add-Logs {
    [CmdletBinding()]
    param (
        [string]
        $text,

        [string]
        $ExternalLog = "C:\Temp\New_users_$(Get-Date -Format 'MMddyyHHmmss').txt"
    )
    $datesortable = Get-Date -Format "HH':'mm':'ss"
    "[$datesortable] - $text" + [environment]::NewLine
    if ($null -ne $ExternalLog) {
        "[$datesortable] - $text" | Add-Content $ExternalLog
    }
}

$CSVFile = Import-Csv D:\Downloads\AWAL_Onboarding_AD_and_SF_2022.09.09_Sean.csv

# Generate a initial securestring password for user object
$PasswordSecureString = ([char[]]([char]33 .. [char]95) + ([char[]]([char]97 .. [char]126)) + 0 .. 20 |
    Sort-Object {
        Get-Random
    })[0 .. 20] -join '' | ConvertTo-SecureString -AsPlainText -Force

$CSVFile | ForEach-Object {
    # AD Attributes from csv file
    $paramNewADUser = @{
        #Name                  = $_.DisplayName
        GivenName             = $_.SF_FirstName
        Surname               = $_.SF_lastName
        #Initials              = $_.Initials
        DisplayName           = "$($_.SF_lastName), $($_.SF_firstName)"
        SamAccountName        = $_.SF_UserID
        UserPrincipalName     = $_.SF_OnboardEmail
        EmailAddress          = $_.SF_OnboardEmail
        #Description           = $_.Description
        #Office                = $_.Office
        #OfficePhone           = $_.Telephone
        #HomePage              = $_.WebPage
        #StreetAddress         = $_.Street
        #State                 = $_.State
        #PostalCode            = $_.PostalCode
        #City                  = $_.City
        Title                 = $_.SF_Title
        Department            = $_.SF_Department
        #Company               = $_.Company
        #POBox                 = $_.POBox
        #ProfilePath           = $_.ProfilePath
        #ScriptPath            = $_.LogonScript
        #HomeDrive             = $_.HomeDrive
        #HomeDirectory         = $_.HomeDirectory
        Path                  = "OU=Test,OU=Users,OU=GBL,OU=USA,OU=NA,OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"
        AccountPassword       = $PasswordSecureString
        PasswordNeverExpires  = $false
        CannotChangePassword  = $false
        ChangePasswordAtLogon = $true
        Enabled               = $true
        #Country               = $_.Country
        #OtherAttributes       = @{
        #    'c' = $_.c; 'co' = $_.CO # c = $_.C; co = $_.CO; countrycode = $_.CountryCode
        #}
        ErrorAction           = 'Stop'
    }

    try {
        Add-Logs -text "INF: Creating user: $($_.SF_UserID)"
        New-ADUser @paramNewADUser
        Start-Sleep -Seconds 3

        Add-Logs -text "INF: Checking SamAccountName: $($_.SF_UserID)"
        $NewUser = Get-ADUser -Identity $($_.SF_UserID) -Properties Name, UserPrincipalName, Distinguishedname, SamAccountname, DisplayName -ErrorAction 'Stop'
    } catch {
        Add-Logs -text "ERR: $($Error.Message)"
    }

    if ($NewUser) {
      #  if ($_.ProxyAddresses) {
      #      Add-Logs -text "INF: Setting ProxyAddresses: $($_.ProxyAddresses)"
      #      Set-ADUser $NewUser -Add @{ ProxyAddresses = $_.ProxyAddresses } -ErrorAction 0
      #  }
        if ($_.SF_UserID) {
            Add-Logs -text "INF: Setting MailNickname: $($_.SF_UserID)"
            Set-ADUser $NewUser -Add @{ MailNickname = $_.SF_UserID } -ErrorAction 0
        }
        if ($_.SF_ADTargetAddress) {
            Add-Logs -text "INF: Setting TargetAddress: $($_.SF_ADTargetAddress)"
            Set-ADUser $NewUser -Add @{ TargetAddress = $_.SF_ADTargetAddress } -ErrorAction 0
        }
      #  if ($_.EmployeeNumber) {
      #      Add-Logs -text "INF: Setting EmployeeNumber: $($_.EmployeeNumber)"
      #      Set-ADUser $NewUser -EmployeeNumber $_.EmployeeNumber -ErrorAction 0
      #  }
      #  if ($_.EmployeeID) {
      #      Add-Logs -text "INF: Setting EmployeeID: $($_.EmployeeID)"
      #      Set-ADUser $NewUser -EmployeeID $_.EmployeeID -ErrorAction 0
        #}
<#
        try {
            Add-Logs -text "INF: Processing VPN groups"

            switch ((($NewUser).replace('\', '') -split ',*..=')[6]) {
                'AP' {
                    Add-Logs -text "INF: Adding user to GlobalProtectVPN-AsiaPacificUsers"
                    Add-ADGroupMember -Identity "GlobalProtectVPN-AsiaPacificUsers" -Members $NewUser -ErrorAction 0
                }
                'EU' {
                    Add-Logs -text "INF: Adding user to GlobalProtectVPN-EuropeanUsers"
                    Add-ADGroupMember -Identity "GlobalProtectVPN-EuropeanUsers" -Members $NewUser -ErrorAction 0
                }
                'LA' {
                    Add-Logs -text "INF: Adding user to GlobalProtectVPN-EuropeanUsers"
                    Add-ADGroupMember -Identity "GlobalProtectVPN-EuropeanUsers" -Members $NewUser -ErrorAction 0
                }
                'NA' {
                    Add-Logs -text "INF: Adding user to GlobalProtectVPN-NorthAmericaUsers"
                    Add-ADGroupMember -Identity "GlobalProtectVPN-NorthAmericaUsers" -Members $NewUser -ErrorAction 0
                }
                Default {
                    Add-Logs -text "ERR: No VPN groups added"
                }
            }
        } catch {
            Add-Logs -text "ERR: $($Error.Message)"
        }
        #>
    }
    Add-Logs -text $('#' * 62)

    $UserObject = [pscustomobject]@{
        DateCreated       = "$(Get-date)"
        SamAccountName    = $NewUser.SamAccountname
        DisplayName       = $NewUser.DisplayName
        UserPrincipalName = $NewUser.UserPrincipalName
        DistinguishedName = $NewUser.DistinguishedName
    }

    $UserObject | Export-Csv -Path $AdminLog -Append -NoTypeInformation
} # Its Milla time!