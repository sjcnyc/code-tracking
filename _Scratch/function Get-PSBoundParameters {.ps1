function Get-PSBoundParameters {
  [cmdletbinding()]
  param(
    [Parameter(

    )]
    [string]
    $ParamOne,

    [Parameter(

    )]
    [string]
    $ParamTwo
  )

  begin {

  }

  process {

  }

  end {

    return $PSBoundParameters

  }
}