function Update-ADUsersAttributes {
    [CmdletBinding(DefaultParameterSetName = 'CSVPath', SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'CSVPath')]
        [ValidateNotNullOrEmpty()]
        [String]$CSVPath
    )

    Begin {
        $csvfile = Import-Csv -Path $CSVPath
        Import-Module -Name ActiveDirectory -WarningAction SilentlyContinue
    }

    process {
        $csvfile | ForEach-Object -Process {
            $GivenName      = $_.FirstName
            $Surname        = $_.LastName
            $StreetAddress  = $_.Address
            $SamAccountName = $_.SamAccountName
            $City           = $_.City
            $State          = $_.State
            $PostCode       = $_.PostCode
            $Country        = $_.Country
            $Title          = $_.Title
            $Company        = $_.Company
            $Description    = $_.Description
            $Department     = $_.Department
            $Office         = $_.Office
            $Phone          = $_.Phone
            $Mail           = $_.Email
            $Manager        = $_.Manager

            try {
                if ($Manager) {
                    $ManagerDN = (Get-ADUser -Identity $Manager).DistinguishedName
                } else {
                    $ManagerDN = $null
                }
            }
            catch {
                Add-Logs -Message "Manager not found: $Manager"
            }

            #Check whether $SamAccountName exisits in AD.
            try {
                $SamExists = (Get-ADUser -Identity $SamAccountName -ErrorAction SilentlyContinue).SamAccountName
            } catch {
                Add-Logs -text $Error.Exception.Message
            }
            try {
            # Set-ADUser below only if $SamAccountName is in AD and also is in the Csv file, else ignore
            if ($SamExists -eq $SamAccountName -and $null -ne $SamExists) {

                if ($GivenName) {
                    Set-ADUser -Identity $SamAccountName -Replace @{ givenname = $GivenName }
                }
                if ($Surname) {
                    Set-ADUser -Identity $SamAccountName -Replace @{ sn = $Surname }
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
                if ($Company ) {
                    Set-ADUser -Identity $SamAccountName -Replace @{ Company = $Company }
                }
                if ($Description ) {
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
                if ($Manager -and $ManagerDN) {
                    Set-ADUser -Identity $SamAccountName -Manager $ManagerDN
                }
            } else {
                Add-Logs -text "User $SamAccountName does not exist in Active Directory"
            }
        }
        catch {
            Add-Logs -text $Error.Exception.Message
        }
        }
    }
    End {
        Add-Logs -text "Update-ADUsersAttributes completed"
    }
}
function Add-Logs {
	[CmdletBinding()]
	param (
        $text,
        $ExternalLog = "C:\temp\update_users_$(Get-Date -Format 'MMddyyHHmmss').txt"
    )
	$datesortable = Get-Date -Format "HH':'mm':'ss"
	"[$datesortable] - $text" + [environment]::NewLine
	if ($null -ne $ExternalLog) {
		"[$datesortable] - $text" | Add-Content $ExternalLog
	}
}