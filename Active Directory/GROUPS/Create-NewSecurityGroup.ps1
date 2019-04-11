function New-Sgroup {

  [cmdletbinding()]

    Param(
    [Parameter(Position=0)]
    [ValidateNotNullOrEmpty()]
    [string]$ou='ISI-DATA',
    [Parameter(Position=1)]
    [string]$name
    )


  $sgname = "USA-GBL $($ou) $($name)"
  $description = "\\storage\data$\$($name)"
  $container = "OU=$($ou),OU=FileShare Access,OU=Non-Restricted,OU=GRP,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com"
  New-QADGroup `
      -ParentContainer $container `
      -Name $sgname `
      -samAccountName $sgname `
      -GroupScope 'Global' `
      -GroupType 'Security' `
      -Description $description
}
function New-SecurityGroup {
  [CmdletBinding()]
  Param (
    [string]$Name 
  )
  DynamicParam {
        $ParameterName = 'OU'
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.Position = 1
        $AttributeCollection.Add($ParameterAttribute)
        $arrSet = Get-QADObject -Type 'OrganizationalUnit' -SearchRoot 'bmg.bagint.com/USA/GBL/GRP/Non-Restricted/FileShare Access'
        $arrSet2 = $arrSet | Select-Object -ExpandProperty name | Where-Object {$_ -ne 'FileShare Access'}
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet2)
        $AttributeCollection.Add($ValidateSetAttribute)
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
  }

  begin {
    # Bind the parameter to a friendly variable
  #  $OU = $PsBoundParameters[$ParameterName]
  }

  process {
    # Your code goes here
    #$OU.name
  }
}
