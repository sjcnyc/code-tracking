function Get-IPAddress
{
  param
  (
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [String[]]
    $Name
  )

  process
  { 
    $Name | ForEach-Object {
        try {
         #$result = [System.Net.DNS]::GetHostByName($_)
        $result = New-Object -TypeName PSObject -Property @{
        HostName  =  [System.Net.Dns]::GetHostByName($_).HostName
        Aliases   =  ([System.Net.Dns]::GetHostByName($_).Aliases | Out-String).Trim()
        IPAddress =  [System.Net.Dns]::GetHostByName($_).AddressList.IPAddressToString
    } 
    $result

        }
        catch {
        }
      }
   }
}

Get-IPAddress 162.49.2.65