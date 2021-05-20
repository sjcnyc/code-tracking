function Get-Something {
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ArgumentCompleter( { 
        @(
          "keys"
          "wallet"
          "phone"
        )
      })]
    [String]$Thing
  )
}
