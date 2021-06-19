function New-ADDGuidMap {
  .SYNOPSIS
  Creates a guid map for the delegation part
  .DESCRIPTION
  Creates a guid map for the delegation part
  .EXAMPLE
  Get-Process C:\> New-ADDGuidMap
  .OUTPUTS
  Hashtable
  .NOTES
  Author: Constantin Hager
  Date: 06.08.2019
  #>
  $rootdse = Get-ADRootDSE
  $guidmap = @{ }
  $guidMapParams = @{
    SearchBase = ($rootdse.SchemaNamingContext)
    LDAPFilter = '(schemaidguid=*)'
    Properties = ('lDAPDisplayName', 'schemaIDGUID')
  }
  Get-ADObject @guidMapParams | ForEach-Object { $guidmap[$_.lDAPDisplayName] = [System.GUID]$_.schemaIDGUID }
  return $guidmap
}