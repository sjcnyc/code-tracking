function ConvertFrom-Canonical {
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Canoincal
    )
    $obj = $Canoincal.Replace(',', '\,').Split('/')
    [string]$DN = 'OU=' + $obj[$obj.count - 1]
    for ($i = $obj.count - 2; $i -ge 1; $i--) {
        $DN += ',OU=' + $obj[$i]
    }
    ($obj[0].split('.')).ForEach{ $DN += ',DC=' + $_ }
    return $DN
}
function Move-UsersFromProvisionOu {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [System.String]
        $SamAccountName,

        [parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1 )]
        [ValidateSet("AP", "EU", "LA", "NA")]
        [System.String]
        $RegionOu
    )
    DynamicParam {

        $OuSplat = @{
            LDAPFilter  = '(name=*Employees*)'
            SearchBase  = "OU=$($RegionOu),OU=STD,OU=Tier-2,DC=me,DC=sonymusic,DC=com"
            SearchScope = 'Subtree'
            Properties  = 'CanonicalName'
            Server      = 'me.sonymusic.com'
        }
        $ParameterName = 'CountryOu'
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.ValueFromPipeline = $true
        $ParameterAttribute.ValueFromPipelineByPropertyName = $true
        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.Position = 2
        $AttributeCollection.Add($ParameterAttribute)
        $DestOu =
        (Get-ADOrganizationalUnit @OuSplat).CanonicalName
        $arrSet = ($DestOu).ForEach{$_.replace("me.sonymusic.com/Tier-2/STD/$($RegionOu)/", "")}
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet| Sort-Object)
        $AttributeCollection.Add($ValidateSetAttribute)
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
    }
    Begin {
        $CountryOu = $PsBoundParameters[$ParameterName]
    }
    Process {
        try {
            $CountryOu = ConvertFrom-Canonical -Canoincal "me.sonymusic.com/Tier-2/STD/$($RegionOu)/$($CountryOu)"
            $User = (Get-Aduser $SamAccountName -Server 'me.sonymusic.com').DistinguishedName
            Move-ADObject -Identity $User -TargetPath $CountryOu -Server 'me.sonymusic.com'
            Write-Verbose -Message ("Moving User: {0} to: {1}" -f $SamAccountName, $CountryOu)
        }
        catch {
            $_.Exception.message
        }
    }
}

@"
sconnea
"@ -split [environment]::NewLine | ForEach-Object {

   Move-UsersFromProvisionOu -SamAccountName $_ -RegionOu NA -CountryOu USA/GBL/Users/Employees
}