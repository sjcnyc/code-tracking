Function Export-DNSServerIPConfiguration {
param($Domain)

    $DNSReport = @()

    ForEach ($DomainEach in $Domain) {
        $DCs = netdom.exe query /domain:$DomainEach dc |
            Where-Object {$_ -notlike '*accounts*' -and $_ -notlike '*completed*' -and $_}

        ForEach ($dc in $DCs) {

            $dnsFwd = Get-WMIObject -ComputerName $("$dc.$DomainEach") `
                -Namespace root\MicrosoftDNS -Class MicrosoftDNS_Server `
                -ErrorAction SilentlyContinue

            $nic = Get-WMIObject -ComputerName $("$dc.$DomainEach") -Query `
                'Select * From Win32_NetworkAdapterConfiguration Where IPEnabled=TRUE' `
                -ErrorAction SilentlyContinue

            $DNSReport += 1 | Select-Object `
                @{name='DC';expression={$dc}}, `
                @{name='Domain';expression={$DomainEach}}, `
                @{name='DNSHostName';expression={$nic.DNSHostName}}, `
                @{name='IPAddress';expression={$nic.IPAddress}}, `
                @{name='DNSServerAddresses';expression={$dnsFwd.ServerAddresses}}, `
                @{name='DNSServerSearchOrder';expression={$nic.DNSServerSearchOrder}}, `
                @{name='Forwarders';expression={$dnsFwd.Forwarders}}, `
                @{name='BootMethod';expression={$dnsFwd.BootMethod}}, `
                @{name='ScavengingInterval';expression={$dnsFwd.ScavengingInterval}}

        } # End ForEach

    }

    $DNSReport | Format-Table -AutoSize -Wrap
    $DNSReport | Export-CSV ".\DC_DNS_$(Get-Date -UFormat %Y%m%d%H%M%S).csv" -NoTypeInformation
}