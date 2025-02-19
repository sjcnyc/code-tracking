using namespace System.Collections.Generic

$groupList = [List[PSObject]]::new()

$Splat = @{
  Properties = "Name", "Members", "whenCreated", "Modified", "ProtectedFromAccidentalDeletion", "DistinguishedName"
  Filter = '*'
}

$Groups = Get-ADGroup @Splat

foreach ($Group in $Groups) {
  $PSobject = [pscustomobject]@{
    Name                    = $Group.Name
    HasMembers              = $group.Members -ge 1 ? $true : $false
    WhenCreated             = $Group.whenCreated
    Modified                = $Group.Modified
    Protected               = $Group.ProtectedFromAccidentalDeletion
    DistinguishedName       = $Group.DistinguishedName
  }
  [void]$groupList.Add($PSobject)
}

$groupList | Export-Csv "D:\Temp\Group_Report_001.csv" -NoTypeInformation