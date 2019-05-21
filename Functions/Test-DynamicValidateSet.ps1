function Test-DynamicValidateSet {
    [CmdletBinding()]
    Param(
        # Any other parameters can go here
    )
 
    DynamicParam {
            # Set the dynamic parameters' name
            $ParameterName = 'Path'
            
            # Create the dictionary 
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

            # Create the collection of attributes
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            
            # Create and set the parameters' attributes
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $true
            $ParameterAttribute.Position = 1

            # Add the attributes to the attributes collection
            $AttributeCollection.Add($ParameterAttribute)

            # Generate and set the ValidateSet 
            $arrSet = Get-ChildItem -Path c:\ -Directory | Select-Object -ExpandProperty FullName
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

            # Add the ValidateSet to the attributes collection
            $AttributeCollection.Add($ValidateSetAttribute)

            # Create and return the dynamic parameter
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
            $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
            return $RuntimeParameterDictionary
    }

    begin {
        # Bind the parameter to a friendly variable
        $Path = $PsBoundParameters[$ParameterName]
    }

    process {
        # Your code goes here
        Get-ChildItem -Path $Path
    }

}

function New-DynamicParam {
Param (
  $parmName,
  $arrySet
)

$parameterName = $paramName
$runtimeParamDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
$attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.attribute]
$parameterAttribute = New-Object System.Management.Automation.ParameterAttribute
$parameterAttribute.Mandatory =$true
$parameterAttribute.Position = 1

$attributiCollection.Add($parameterAttribute)

$arrySet1 = $arrySet
$validatesetattribute = New-Object System.Management.Automation.ValidateArgumentsAttribute($arrySet1)
$attributeCollection.Add($validatesetattribute)
$runtimeparamater = New-Object System.Management.Automation.RuntimeDefinedParameter($parameterName, [string], $attributeCollection)
$runtimeParamDictionary.Add($parameterName, $runtimeparamater)
return $runtimeParamDictionary
}