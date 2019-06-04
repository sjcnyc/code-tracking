function remote {
Clear-Host
#define a prompt
$p = @"
Remote desktop connections

  1 - lyn win 7
  2 - lyn win xp
  3 - nyc print server
  4 - lyn print server
  5 - posh script server
  6 - bvh backup server
  7 - nas backup server
  8 - Exit

Select host to remote to
"@

$c = 
@{
'1'='192.168.34.86'
'2'='192.168.34.70'
'3'='ny1'
'4'='ly2'
'5'='uslynvwinf003'
'6'='stmsbmewfp001'
'7'='nassbmewfp001'
}

do {Clear-Host
  $r=read-host $p `

  Switch ($r) {

    1 {Invoke-Mstsc $c.item('1')}
    2 {Invoke-Mstsc $c.item('2')}
    3 {Invoke-Mstsc $c.item('3')}
    4 {Invoke-Mstsc $c.item('4')}
    5 {Invoke-Mstsc $c.item('5')}
    6 {Invoke-Mstsc $c.item('6')}
    7 {Invoke-Mstsc $c.item('7')}
    8 {Clear-Host;break;}

    Default {Write-Host "Invalid choice: $r" -fore Yellow
        }
      }
    }
   while ($r -ne '8')
}

function rdp { Param([Parameter(Mandatory=$True)][String]$Comp ) mstsc.exe /v $comp /admin /w 1440 /h 900 -console }