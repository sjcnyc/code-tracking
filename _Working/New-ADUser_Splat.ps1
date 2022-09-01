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

$CSVFile = Import-Csv "Import user csv here"

# Generate a initial securestring password for user object
$PasswordSecureString = ([char[]]([char]33 .. [char]95) + ([char[]]([char]97 .. [char]126)) + 0 .. 20 |
    Sort-Object {
        Get-Random
    })[0 .. 20] -join '' | ConvertTo-SecureString -AsPlainText -Force

$CSVFile | ForEach-Object {
    # AD Attributes from csv file
    $paramNewADUser = @{
        Name                  = $_.DisplayName
        GivenName             = $_.FirstName
        Surname               = $_.LastName
        Initials              = $_.Initials
        DisplayName           = $_.DisplayName
        SamAccountName        = $_.SamAccountName
        UserPrincipalName     = $_.UserPrincipalName
        EmailAddress          = $_.EmailAddress
        Description           = $_.Description
        Office                = $_.Office
        OfficePhone           = $_.Telephone
        HomePage              = $_.WebPage
        StreetAddress         = $_.Street
        State                 = $_.State
        PostalCode            = $_.PostalCode
        City                  = $_.City
        Title                 = $_.Title
        Department            = $_.Department
        Company               = $_.Company
        POBox                 = $_.POBox
        ProfilePath           = $_.ProfilePath
        ScriptPath            = $_.LogonScript
        HomeDrive             = $_.HomeDrive
        HomeDirectory         = $_.HomeDirectory
        Path                  = $_.OULocation
        AccountPassword       = $PasswordSecureString
        PasswordNeverExpires  = $false
        CannotChangePassword  = $false
        ChangePasswordAtLogon = $true
        Enabled               = $true
        # Country               = $_.Country
        OtherAttributes       = @{
            'c' = $_.c; 'co' = $_.CO # c = $_.C; co = $_.CO; countrycode = $_.CountryCode
        }
        ErrorAction           = 'Stop'
    }

    try {
        Add-Logs -text "INF: Creating user: $($_.SamAccountName)"
        New-ADUser @paramNewADUser
        Start-Sleep -Seconds 3

        Add-Logs -text "INF: Checking SamAccountName: $($_.SamaccountName)"
        $NewUser = Get-ADUser -Identity $($_.SamaccountName) -Properties Name, UserPrincipalName, Distinguishedname, SamAccountname, DisplayName -ErrorAction 'Stop'
    } catch {
        Add-Logs -text "ERR: $($Error.Message)"
    }

    if ($NewUser) {
        if ($_.ProxyAddresses) {
            Add-Logs -text "INF: Setting ProxyAddresses: $($_.ProxyAddresses)"
            Set-ADUser $NewUser -Add @{ ProxyAddresses = $_.ProxyAddresses } -ErrorAction 0
        }
        if ($_.MailNickname) {
            Add-Logs -text "INF: Setting MailNickname: $($_.MailNickname)"
            Set-ADUser $NewUser -Add @{ MailNickname = $_.MailNickname } -ErrorAction 0
        }
        if ($_.TargetAddress) {
            Add-Logs -text "INF: Setting TargetAddress: $($_.TargetAddress)"
            Set-ADUser $NewUser -Add @{ TargetAddress = $_.TargetAddress } -ErrorAction 0
        }
        if ($_.EmployeeNumber) {
            Add-Logs -text "INF: Setting EmployeeNumber: $($_.EmployeeNumber)"
            Set-ADUser $NewUser -EmployeeNumber $_.EmployeeNumber -ErrorAction 0
        }
        if ($_.EmployeeID) {
            Add-Logs -text "INF: Setting EmployeeID: $($_.EmployeeID)"
            Set-ADUser $NewUser -EmployeeID $_.EmployeeID -ErrorAction 0
        }

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