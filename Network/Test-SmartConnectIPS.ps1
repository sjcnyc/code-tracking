function Test-SmartConnect {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
  [CmdletBinding(SupportsShouldProcess = $true)]
  param
  (
    [Parameter(Mandatory)]
    [string]$server,  
    [Parameter(Mandatory)]
    [int]$range
  )

  #clear DNS cache
  invoke-expression -Command 'ipconfig.exe /flushdns'

  Write-Verbose -Message "Query DNS for IP address of $server"
  #loop 1.. whatever's in your round-robin
  ForEach ($null in 1..$range) {
    try {
      [Net.Dns]::GetHostEntry($server) | Select-Object -Property Hostname, @{n = 'AddressList'; e = { $_.addresslist } }
    }
    catch {
      Write-Verbose -Message "No DNS Name $server"
    }
    Start-Sleep -Seconds 1
  }

}

test-smartconnect -server storage.me.sonymusic.com -range 40