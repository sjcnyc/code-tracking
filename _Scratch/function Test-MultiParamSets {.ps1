function Test-MultiParamSets {
  [CmdletBinding(DefaultParameterSetName = 'Name')]
  param(
    [Parameter(ParameterSetName = 'Name', Mandatory = $true)]
    [Parameter(ParameterSetName = 'ID')]
    [Parameter(Position = 0)]
    [String]$Name,

    [Parameter(Mandatory = $False)]
    [ValidateSet('Choice1', 'Choice2', 'Choice3')]
    [string]
    $Choices,

    [Parameter(ParameterSetName = 'ID')]
    [int]
    $ID
  )
  'Set name is:{0}' -f $PSCmdlet.ParameterSetName
  'Name is: [{0}], ID is [{1}]' -f $Name, $ID
  'choices is: [{0}]' -f $choices
}