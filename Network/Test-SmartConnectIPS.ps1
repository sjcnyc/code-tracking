function Test-SmartConnect {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
  [CmdletBinding(SupportsShouldProcess = $true)]
  param
  (
    [Parameter(Mandatory)]
    [string]$Server,
    [Parameter(Mandatory)]
    [int]$Range
  )

  $ipaddresss = @()

  #clear DNS cache
  Invoke-Expression -Command 'ipconfig.exe /flushdns'

  Write-Verbose -Message "Query DNS for IP address of $Server"
  #loop 1.. whatever's in your round-robin
  ForEach ($null in 1..$Range) {
    try {
      $ipaddresss += [Net.Dns]::GetHostEntry($Server) | Select-Object -Property Hostname, @{N = 'AddressList'; E = { $_.AddressList } }
    }
    catch {
      Write-Verbose -Message "No DNS Name $Server"
    }
    Start-Sleep -Seconds 1
  }
  $ipaddresss | Select-Object * -Unique | sort-object

}

Test-SmartConnect -server storage.me.sonymusic.com -range 30