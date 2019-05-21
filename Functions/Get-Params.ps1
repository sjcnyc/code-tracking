# get-params -cmdlet <name of cmdlet> -params  -syntax 
function Get-Params {
    param($cmdlet,
          [switch]$syntax,
          [switch]$params
    )

if ($params){ (get-help $cmdlet).syntax | Select-Object –expand syntaxItem |
    Select-Object –expand parameter | Select-Object name | out-host }

if ($syntax){ (get-help $cmdlet).syntax | Select-Object –expand syntaxItem |
    Select-Object -expand parameter | out-host }
}