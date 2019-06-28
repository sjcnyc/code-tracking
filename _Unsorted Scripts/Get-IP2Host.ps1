@"
10.12.128.231
10.12.128.232
10.12.128.234
10.12.128.235
162.49.138.179
162.49.140.152
162.49.142.39
162.49.158.208
162.49.185.33
162.49.209.5
162.49.212.22
162.49.212.26
"@ -split [environment]::NewLine | ForEach-Object {

    $psobj = [pscustomobject]@{

        IPAddress = $_
        HostName  = ([system.net.dns]::GetHostByAddress($_)).hostname
    }

    $psobj
}
