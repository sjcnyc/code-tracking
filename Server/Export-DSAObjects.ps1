[CmdletBinding(SupportsShouldProcess = $true)]
param(
  $domain = 'bmg.bagint.com'
)

#region Initiate HashTables & variables
$exportDate = Get-Date -Format ddMMyyyy
$xlsxFile = ".\export\dsa\source\$domain - DSAObjects - $exportDate.xlsx"
$xmlFile  = ".\export\dsa\source\$domain - DSAObjects - $exportDate.xml "
$DSAObjects = @{}
$Select = @{}
#endregion

<#region Main
    $DSAObjects.DFSLinks = ActiveDirectory\Get-ADObject -LDAPFilter '(objectClass=msDFS-LInkv2)'-Properties msDFS-LinkPathv2,msDFS-Propertiesv2,whenChanged,whenCreated |
    $DSAObjects.DFSLinks = Get-ADObject -LDAPFilter '(objectClass=msDFS-LInkv2)'-Properties msDFS-LinkPathv2,msDFS-Propertiesv2,whenChanged,whenCreated | 
    ForEach-Object{
    [PSCustomObject]@{
    DFSLink     = '\\bmg.bagint.com{0}' -f ($_.'msDFS-LinkPathv2').Replace('/','\')
    State       = $_.'msDFS-Propertiesv2' -join ','
    Changed     = $_.whenChanged
    Created     = $_.whenCreated
    CreatedDate = Get-Date (Get-Date $_.whenCreated).Date -format yyyyMMdd
    }
  }
#>

$DSAObjects.PrintQueues = ActiveDirectory\Get-ADObject -LDAPFilter '(objectClass=printQueue)' -Properties printerName, portName, printShareName, uNCName, serverName, whenChanged, whenCreated | 
ForEach-Object -Process {
  [PSCustomObject]@{
    PrinterName    = $_.printerName
    PortName       = $_.portName -join ','
    PrintShareName = $_.printShareName -join ','
    ServerName     = $_.serverName
    UNCName        = $_.uNCName
    Changed        = $_.whenChanged
    Created        = $_.whenCreated
    CreatedDate    = Get-Date -Date (Get-Date -Date $_.whenCreated).Date -Format yyyyMMdd
  }
}

$DSAObjects.Contacts = ActiveDirectory\Get-ADObject -LDAPFilter '(objectClass=contact)'  -Properties DisplayName, givenName, sn, DistinguishedName, mail, whenChanged, whenCreated |
ForEach-Object -Process {
  [PSCustomObject]@{
    GivenName         = $_.givenName
    SurName           = $_.sn
    DistinguishedName = $_.DistinguishedName
    DisplayName       = $_.DisplayName
    EmailAddress      = $_.mail
    Changed           = $_.whenChanged
    Created           = $_.whenCreated
    CreatedDate       = Get-Date -Date (Get-Date -Date $_.whenCreated).Date -Format yyyyMMdd
  }
}

$DSAObjects.Users = Get-ADUser -LDAPFilter '(objectClass=user)' -Properties accountExpirationDate, LastLogonDate, Initials, Description, EmailAddress, Enabled, DisplayName, OfficePhone, MobilePhone, Department, whenChanged, whenCreated, DistinguishedName, canonicalname |
ForEach-Object -Process {
  [PSCustomObject]@{
    SamAccountName    = $_.SamAccountName
    DistinguishedName = $_.DistinguishedName
    CanonicalName     = $_.CanonicalName
    Enabled           = $_.Enabled
    GivenName         = $_.GivenName
    Initials          = $_.Initials
    SurName           = $_.SurName
    EmailAddress      = $_.EmailAddress
    Description       = $_.Description
    Displayname       = $_.DisplayName
    OfficePhone       = $_.OfficePhone
    MobilePhone       = $_.MobilePhone
    Department        = $_.Department
    LastLogonDate     = $_.LastLogonDate
    AccountExpiresOn  = $_.accountExpirationDate
    Changed           = $_.whenChanged
    Created           = $_.whenCreated
    CreatedDate       = Get-Date -Date (Get-Date -Date $_.whenCreated).Date -Format yyyyMMdd
  }
}

$DSAObjects.Groups = Get-ADGroup -LDAPFilter '(objectClass=group)' -Properties Member, MemberOf, whenChanged, whenCreated |
ForEach-Object -Process {
  [PSCustomObject]@{
    DistinguishedName = $_.DistinguishedName
    SamAccountName    = $_.SamAccountName
    Name              = $_.Name
    Changed           = $_.whenChanged
    Created           = $_.whenCreated
    CreatedDate       = Get-Date -Date (Get-Date -Date $_.whenCreated).Date -Format yyyyMMdd
    Member            = $_.Member
    MemberOf          = $_.MemberOf
  }
}

$DSAObjects.Deleted = Get-ADObject -Filter * -IncludeDeletedObjects -Properties CN, SamAccountName, LastKnownParent |
Where-Object -FilterScript {
  $_.Deleted -eq $true
} |
ForEach-Object -Process {
  [PSCustomObject]@{
    CN              = $(($_.CN -split "`n") -join '; ')
    SamAccountName  = $_.SamAccountName
    Deleted         = $_.Deleted
    ObjectClass     = $_.ObjectClass
    LastKnownParent = $_.LastKnownParent
  }
}
#endregion

#region Export Object  and to Excel
$Select.DFSLinks = '*'
$Select.Users = '*'
$Select.Contacts = '*'
$Select.Groups = @('ObjectClass', 'DistinguishedName', 'Name', 'Changed', 'Created')
$Select.PrintQueue = @('ObjectClass', 'PrinterName', 'PortName', 'PrintShareName', 'ServerName', 'UNCName', 'Changed', 'Created')
$Select.Deleted = @('CN', 'SamAccountName', 'Deleted', 'ObjectClass', 'LastKnownParent') 
#XML File
$DSAObjects | 
Export-Clixml -Path $xmlFile -Encoding UTF8

#Excel File
$DSAObjects.Keys |
ForEach-Object -Process {
  if($DSAObjects.$_)
  {
    $DSAObjects.$_ |
    Select-Object -Property $Select.$_ |
    Export-Excel -Path $xlsxFile -WorkSheetname $_ -AutoSize -BoldTopRow -FreezeTopRow
  }
}
#endregion