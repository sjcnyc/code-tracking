function Set-ExtensionAttribute {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [System.String]
        $SamAccountName,

        [parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 1)]
        [ValidateSet("Set", "Clear")]
        $Option,

        [parameter(Mandatory = $false, ValueFromPipeline = $true, Position = 2)]
        [System.String]
        $Value = ""
    )
    dynamicparam {
        $ParameterName = 'ExtensionAttribute'
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.ValueFromPipeline = $true
        $ParameterAttribute.ValueFromPipelineByPropertyName = $true
        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.Position = 3
        $AttributeCollection.Add($ParameterAttribute)
        $ArrSet = 1..15 | ForEach-Object {"extensionAttribute$($_)"}
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($ArrSet)
        $AttributeCollection.Add($ValidateSetAttribute)
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
    }
    begin {
        $ExtensionAttribute = $PsBoundParameters[$ParameterName]
    }
    process {

        switch ($Option) {
            "Set" {
                Set-ADUser -Identity $SamAccountName -Replace @{$ExtensionAttribute = $value}
                Write-Verbose "Setting $ExtensionAttribute with value: $Value for User: $SamAccountName"
            }
            "Clear" {
                $ExtAttrib = Get-ADUser -Identity $SamAccountName -properties $ExtensionAttribute | Select-Object -ExpandProperty $ExtensionAttribute
                Set-ADUser -Identity $SamAccountName -Clear $ExtensionAttribute
                Write-Verbose "Clearing $ExtensionAttribute with value: $ExtAttrib for User: $SamAccountName"
            }
        }
    }
}

@"
sconnea
"@ -split [environment]::NewLine | ForEach-Object
{
    Set-ExtensionAttribute -SamAccountName $_ -Option Set -Value "NoSync111" -ExtensionAttribute extensionAttribute1 -Verbose
    Set-ExtensionAttribute -SamAccountName $_ -Option Clear -ExtensionAttribute extensionAttribute1 -Verbose
}