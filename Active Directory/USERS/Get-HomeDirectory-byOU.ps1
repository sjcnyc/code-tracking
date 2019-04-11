function Get-HomeDirectory {
  param (
    [Parameter(Mandatory = $true,
      ValueFromPipeline = $true)]
    [System.Array]
    $Ous,

    [System.String]
    $Domain,

    [System.Management.Automation.SwitchParameter]
    $Export,

    [System.String]
    $Path
  )

  try {
    $PSArray = New-Object System.Collections.ArrayList
    (
      ($Ous).ForEach{
        Get-QADUser -SearchRoot "$($Domain)/$($_)" -SizeLimit 0 -Service 'me.sonymusic.com' | Select-Object ParentContainer, SamAccountName, HomeDirectory, HomeDrive, ScriptPath
      }
    ).ForEach{

      $PSObj = [PSCustomObject]@{
        ParentContainer = $_.ParentContainer
        SamAccountName  = $_.SamAccountName
        HomeDirectory   = $_.HomeDirectory
        HomeDrive       = $_.HomeDrive
        ScriptPath      = $_.ScriptPath
      }
      [void]$PSArray.Add($PSObj)
    }
    if ($export) {
      $PSArray | Export-Csv "$($Path)" -NoTypeInformation -Append
    }
    else {
      $PSArray
    }
  }
  catch {
    $_.exception.message; continue
  }
}

<# foreach ($ou in (Get-ADOrganizationalUnit -SearchScope OneLevel -filter * | Select-Object name)) {
    get-homedirectory -ous $ou.name -export -path c: \temp\homes2.csv

} #>

Get-HomeDirectory -ous 'Tier-2/STD/NA/USA/FRK' -Domain 'me.sonymusic.com' -Export -Path C:\Temp\FRK.csv