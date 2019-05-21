$Forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
$Sites = @()
foreach ($site in $Forest.Sites) {$Sites += $Site}
$Locations = @{}
$Sites | foreach { $_.Subnets | % {
    If ($_.Location) {$loc = $_.Location.Trim()} Else {$loc = $_.Site}
    $Bits = ($_.Name -Split '/')[1] 
    $Net = $_.Name -Split ".",0,"SimpleMatch"
    "Processing $Loc, subnet {0}.{1}.{2}, bits $Bits" -f $net[0],$net[1],$net[2]
    Switch ($Bits) {
        16 {$n = "{0}.{1}.{2}" -f $Net[0],$Net[1],$Net[2]; $Locations += @{$N = $Loc}; Break}
        21 {0..7 | % {$n = "{0}.{1}.{2}" -f $Net[0],$Net[1],([INT]$Net[2]+$_); $Locations += @{$N = $Loc}}; Break}
        22 {0..3 | % {$n = "{0}.{1}.{2}" -f $Net[0],$Net[1],([INT]$Net[2]+$_); $Locations += @{$N = $Loc}}; Break}
        23 {0..1 | % {$n = "{0}.{1}.{2}" -f $Net[0],$Net[1],([INT]$Net[2]+$_); $Locations += @{$N = $Loc}}; Break}
        24 {$n = "{0}.{1}.{2}" -f $Net[0],$Net[1],$Net[2]; $Locations += @{$N = $Loc}; Break}
    } #end Switch
}}
$Locations | Export-Clixml c:\Locations.xml