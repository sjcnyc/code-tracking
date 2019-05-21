Function out-TestPage {
	[CmdletBinding()]
	Param()
	DynamicParam {
		$attributes = new-object System.Management.Automation.ParameterAttribute
		$attributes.ParameterSetName = '__AllParameterSets'
		$attributes.Mandatory = $true
		$attributeCollection =
		
		new-object -Type System.Collections.ObjectModel.Collection[System.Attribute]
		
		$attributeCollection.Add($attributes)
		$_Values = (Get-CimInstance win32_Printer).name  
		$ValidateSet = new-object System.Management.Automation.ValidateSetAttribute($_Values)
		
		$attributeCollection.Add($ValidateSet)
		
		$dynParam1 = new-object -Type System.Management.Automation.RuntimeDefinedParameter(
		
		'Printer', [string], $attributeCollection)
		
		$paramDictionary = new-object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
		
		$paramDictionary.Add('Printer', $dynParam1)
		
		return $paramDictionary }
	
	begin {}
	
	process {
		$printer = $PSBoundParameters.printer
		Invoke-CimMethod -MethodName printtestpage -InputObject ( Get-CimInstance win32_printer -Filter "name LIKE '$printer'") }
	end {}	
}