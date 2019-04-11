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

    $verboseMsg = "for $SamAccountName not in CSV file"

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

        if ($SamExists -eq $SamAccountName -and $SamExists -ne $null) {
            if ($DisplayName) {
                Set-ADUser -Identity $SamAccountName -Replace @{ displayName = $DisplayName }
            }
            else {
                Write-Verbose -Message "DisplayName $verboseMsg"
            }
        }
        if ($GivenName) {
            Set-ADUser -Identity $SamAccountName -GivenName $GivenName
        }
        else {
            Write-Verbose -Message "GivenName $verboseMsg"
        }
        if ($Surname) {
            Set-ADUser -Identity $SamAccountName -Surname $Surname
        }
        else {
            Write-Verbose -Message "SurName $verboseMsg"
        }
        if ($StreetAddress) {
            Set-ADUser -Identity $SamAccountName -Replace @{ StreetAddress = $StreetAddress }
        }
        else {
            Write-Verbose -Message "StreetAddress $verboseMsg"
        }
        if ($City ) {
            Set-ADUser -Identity $SamAccountName -Replace @{ l = $City }
        }
        else {
            Write-Verbose -Message "City $verboseMsg"
        }
        if ($State) {
            Set-ADUser -Identity $SamAccountName -State $State
        }
        else {
            Write-Verbose -Message "State $verboseMsg"
        }
        if ($PostCode) {
            Set-ADUser -Identity $SamAccountName -Replace @{ postalCode = $PostCode }
        }
        else {
            Write-Verbose -Message "PostCode $verboseMsg"
        }
        if ($Country) {
            Set-ADUser -Identity $SamAccountName -Country $Country
        }
        else {
            Write-Verbose -Message "Country $verboseMsg"
        }
        if ($Title) {
            Set-ADUser -Identity $SamAccountName -Replace @{ Title = $Title }
        }
        else {
            Write-Verbose -Message "Job Title $verboseMsg"
        }
        if ($Company) {
            Set-ADUser -Identity $SamAccountName -Replace @{ Company = $Company }
        }
        else {
            Write-Verbose -Message "Company $verboseMsg"
        }
        if ($Description) {
            Set-ADUser -Identity $SamAccountName -Replace @{ Description = $Description }
        }
        else {
            Write-Verbose -Message "Description $verboseMsg"
        }
        if ($Department) {
            Set-ADUser -Identity $SamAccountName -Replace @{ Department = $Department }
        }
        else {
            Write-Verbose -Message "Department $verboseMsg"
        }
        if ($Office) {
            Set-ADUser -Identity $SamAccountName -Replace @{ physicalDeliveryOfficeName = $Office }
        }
        else {
            Write-Verbose -Message "Office $verboseMsg"
        }
        if ($Phone) {
            Set-ADUser -Identity $SamAccountName -Replace @{ telephoneNumber = $Phone }
        }
        else {
            Write-Verbose -Message "Phone number $verboseMsg"
        }
        if ($Mail) {
            Set-ADUser -Identity $SamAccountName -Replace @{ mail = $Mail }
        }
        else {
            Write-Verbose -Message "Mail $verboseMsg"
        }
        if ($fax) {
            Set-ADUser -Identity $SamAccountName -Fax $fax
        }
        else {
            Write-Verbose -Message "Fax $verboseMsg"
        }
        if ($Manager -and $ManagerDN) { Set-ADUser -Identity $SamAccountName -Manager $ManagerDN }
        else {
            Write-Verbose -Message "Manager $verboseMsg"
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