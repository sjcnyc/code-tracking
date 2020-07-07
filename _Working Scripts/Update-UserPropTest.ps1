function Update-UserProperty {
  param (
    [string]$SamAccountName,
    [string]$ADProperty,
    [string]$ADValue
    )

    try {

        switch ($ADProperty) {
            Manager       { Set-ADUser -Identity $SamAccountName -Manager $ADValue }
            MobilePhone   { Set-ADUser -Identity $SamAccountName -MobilePhone $ADValue }
            Fax           { Set-ADUser -Identity $SamAccountName -Fax $ADValue }
            HomePhone     { Set-ADUser -Identity $SamAccountName -HomePhone $ADValue }
            OfficePhone   { Set-ADUser -Identity $SamAccountName -OfficePhone $ADValue }
            City          { Set-ADUser -Identity $SamAccountName -City $ADValue }
            StreetAddress { Set-ADUser -Identity $SamAccountName -StreetAddress $ADValue }
            PostalCode    { Set-ADUser -Identity $SamAccountName -PostalCode $ADValue }
            State         { Set-ADUser -Identity $SamAccountName -State $ADValue }
            POBox         { Set-ADUser -Identity $SamAccountName -POBox $ADValue }
            Country       { Set-ADUser -Identity $SamAccountName -Country $ADValue }
            Company       { Set-ADUser -Identity $SamAccountName -Company $ADValue }
            Department    { Set-ADUser -Identity $SamAccountName -Department $ADValue }
            JobTitle      { Set-ADUser -Identity $SamAccountName -Title $ADValue }
        }

        Write-au2matorLog -Type INFO -Text "$ADProperty Property has been updated"
        $f_ErrorCount = 0
    }
    catch {
        $f_ErrorCount = 1
        Write-au2matorLog -Type ERROR -Text "Error to update $ADProperty Property"
        Write-au2matorLog -Type ERROR -Text $Error
    }
    return $f_ErrorCount
}