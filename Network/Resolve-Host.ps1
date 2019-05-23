Function Resolve-Host {
    param(
        [Parameter(Mandatory = $true, Position = 0)] $HostEntry,
        [Switch] $HostnameToIP,
        [Switch] $FlushDNS
    )

    if ($FlushDNS) {
        Ipconfig /FlushDNS | Out-Null
    }

    if ($HostnameToIP) {
        $object = @()
        $HostEntry | ForEach-Object {

            $Object += New-Object psobject -Property @{  HostName = $_
                IPAddress = $([System.Net.Dns]::GetHostEntry(($_).AddressList.IPAddressToString))
                }
            }
            Return $object | Select-Object Hostname, IPAddress
        }
        else {
            $object = @()
            $HostEntry | ForEach-Object {

                $Object += New-Object psobject -Property @{  IPAddress = $_
                    HostName = $([System.Net.Dns]::gethostentry($_).HostName)
                }
            }
            return $object | Select-Object IPAddress, Hostname
        }
    }