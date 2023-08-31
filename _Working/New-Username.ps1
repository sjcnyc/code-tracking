

    <#PSScriptInfo

.VERSION
    1.0
.GUID
    0ae30495-bfc9-4f9e-8d05-6730895e755f
.AUTHOR
    Thomas J. Malkewitz @dotps1
.EXTERNALMODULEDEPENDENCIES
    ActiveDirectory

#>

    <#

.SYNOPSIS
    Creates a new username with AD DS Validation.
.DESCRIPTION
    Create a new username with the following order until a unique Username is found.
    1. First Initial Last Name.
    2. First Initial First Middle Intial Last Name.
    3. Itterates First Name adding each Char until a unique Username is found.
.INPUTS
    None.
.OUTPUTS
    System.String
.PARAMETER FirstName
    The first name of the user to be created.
.PARAMETER LastName
    The last name of the user to be created.
.PARAMETER OtherName
    The middle name of the user to be created.
.EXAMPLE
    PS C:\> New-Username -FirstName John -LastName Doe

    jdoe
.EXAMPLE
    PS C:\> New-Username -FirstName Jane -LastName Doe -MiddleName Ala

    jadoe
.NOTES
    Requires ActiveDirectory PowerShell Module available with Remote Server Administration Tools.
    RSAT 7SP1: http://www.microsoft.com/en-us/download/details.aspx?id=7887
    RSAT 8: http://www.microsoft.com/en-us/download/details.aspx?id=28972
    RSAT 8.1: http://www.microsoft.com/en-us/download/details.aspx?id=39296
    RSAT 10: http://www.microsoft.com/en-us/download/details.aspx?id=45520
.LINK
    http://dotps1.github.io

#>

    [CmdletBinding()]
    [OutputType(
        [String]
    )]

    Param (
        [Parameter(
            Mandatory = $true
        )]
        [Alias(
            'GivenName'
        )]
        [String]
        $FirstName,

        [Parameter(
            Mandatory = $true
        )]
        [Alias(
            'Surname'
        )]
        [String]
        $LastName,

        [Parameter()]
        [AllowNull()]
        [String]
        $OtherName
    )

    # '|' = Or Operand, '\s' = Spaces, '-' = Hyphens, ''' = Apostrophe,
    [RegEx]$pattern = "\s|-|'"

    $primaryUserName = ($FirstName.Substring(0, 1) + $LastName) -replace $pattern, ""
    if ((Get-ADUser -Filter { SamAccountName -eq $primaryUserName } | Measure-Object).Count -eq 0) {
        return $primaryUsername.ToLower()
    }

    if (-not ([String]::IsNullOrEmpty($OtherName))) {
        $secondaryUserName = ($FirstName.Substring(0, 1) + $OtherName.Substring(0, 1) + $LastName) -replace $pattern, ""
        if ((Get-ADUser -Filter { SamAccountName -eq $secondaryUserName } | Measure-Object).Count -eq 0) {
            return $secondaryUserName.ToLower()
        }
    }

    foreach ($char in $FirstName.ToCharArray()) {
        $prefix += $char
        $tertiaryUserName = ($prefix + $LastName) -replace $pattern, ""

        if (-not ($tertiaryUserName -eq $primaryUserName)) {
            if ((Get-ADUser -Filter { SamAccountName -eq $tertiaryUserName } | Measure-Object).Count -eq 0) {
                return $tertiaryUserName.ToLower()
            }
        }
    }
