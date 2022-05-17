function Add-UserToAvdGroup {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$UserName
    )

    DynamicParam {
        $ParameterName                                      = 'AVDGroups'
        $RuntimeParameterDictionary                         = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $AttributeCollection                                = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute                                 = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.ValueFromPipeline               = $true
        $ParameterAttribute.ValueFromPipelineByPropertyName = $true
        $ParameterAttribute.Mandatory                       = $true
        $ParameterAttribute.Position                        = 2
        $AttributeCollection.Add($ParameterAttribute)

        $arrSet = (Get-ADGroup -Filter 'Name -like "az_avd_*FullDesktop"' -prop Name).Name
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet | Sort-Object)
        $AttributeCollection.Add($ValidateSetAttribute)
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
    }
    Begin {
        $AVDGroups = $PsBoundParameters[$ParameterName]
    }
    Process {
        try {
            $GroupDN = (Get-ADGroup -Identity $AVDGroups).DistinguishedName
            Add-ADGroupMember -Members $UserName -Identity $GroupDN
            Write-Host "User $($UserName) added to AVD groups $($AVDGroups)" -ForegroundColor Green
        }
        catch {
            $_.Exception.message
        }
    }
}

function Add-UserToAvdGroup {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$UserName
    )
    try {
        $Groups = (Get-ADGroup -Filter 'Name -like "az_avd_*FullDesktop"' -prop Name).Name | Out-GridView -PassThru -Title "Select AVD group to add user to"

        foreach ($Group in $Groups) {
            $GroupDN = (Get-ADGroup -Identity $Group).DistinguishedName
            Add-ADGroupMember -Identity $GroupDN -Members $UserName
            Write-Host "Adding $($userName) to AVD group: $($Group)" -ForegroundColor Green
        }
    }
    catch {
        $_.Exception.message
    }
}