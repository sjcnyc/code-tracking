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

  #clear DNS cache
  Invoke-Expression -Command 'ipconfig.exe /flushdns'

  Write-Verbose -Message "Query DNS for IP address of $Server"
  #loop 1.. whatever's in your round-robin
  ForEach ($null in 1..$Range) {
    try {
      [Net.Dns]::GetHostEntry($Server) | Select-Object -Property Hostname, @{N = 'AddressList'; E = { $_.AddressList } }
    }
    catch {
      Write-Verbose -Message "No DNS Name $Server"
    }
    Start-Sleep -Seconds 1
  }

}

Test-SmartConnect -server usstorage01.me.sonymusic.com -range 26