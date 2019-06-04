#requires -Version  5.0 
 
Enum ComputerType
{
  ManagedServer
  ManagedClient
  Server
  Client
}
 
function Connect-Computer 
{
  param 
  (
    [ComputerType] 
    $Type, 
 
    [string] 
    $Name 
  )
 
  "Computername: $Name Type: $Type" 
}