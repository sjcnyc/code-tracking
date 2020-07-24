$json = Get-Content -Raw -Path 'C:\Users\sjcny\Dropbox\Development\AzureDevOps\POWERSHELL\Projects\AD User Creator\Config\Addresses.json'

$json | ConvertFrom-Json | ConvertTo-Json

<# [] in Json means an array {} in json means hashtable

So you can use regular array and psobject patterns.
get one zone:

> $data = $json | ConvertFrom-Json
> $data.zones[0]
or the same thing

> $data.zones | select -First 1
Another way to visualize all zones in one table

>> $data.zones | ft

cool_setpoint damper_position heat_setpoint hold out temperature temporary
------------ - -------------- - ------------ - ---- -- - ---------- - -------- -
76 100                        68    1   0          77         0
76 53                         62    2   0          76         0
or create a list only grabbing specific properties
>  $zoneList = $data.zones | select cool_setpoint, temperature
>> $zoneList | ft

cool_setpoint temperature
------------ - ---------- -
76          77
76          76

> $zoneList | ConvertTo-Json

[
{
  "cool_setpoint": 76,
  "temperature": 77
},
{
  "cool_setpoint": 76,
  "temperature": 76
}
]
to pretty-print / format json, just json -> import -> export
> $json | ConvertFrom-Json | ConvertTo-Json #>
