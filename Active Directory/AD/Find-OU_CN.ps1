function Find-OU  {
  param
  (
    [System.Object]
    $ou
  )
  
  
  Get-QADObject -Type 'organizationalunit' -Name $ou | Select-Object CanonicalName
}