function Invoke-Rdp { 
	Param(
		[Parameter(Mandatory=$True)]
		[String]$Comp 
		) 
		mstsc.exe /v $comp /admin /h:1300 /w:2400 /v:$comp
		}

Clear-Host
#$comps = 
#	Get-QADComputer -SearchRoot 'OU=Windows 2012,OU=SRV,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com' |select name | Test-Connection -count 1 | Select-Object @#{Name="Computername";Expression={$_.Address}},Ipv4Address |	Sort-Object

	#$choice = Out-Menu $comps -AllowCancel
  
	#Invoke-Rdp -Comp $choice


$comps = 
	Get-QADComputer -SearchRoot 'OU=Windows 2012,OU=SRV,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com' |

select-object `
		 @{n = 'IP'; e = { (Test-Connection $_.Name -count 1).IPV4Address } },
		 @{n= 'Name'; e = { $_.name } }
		 

$choice = Out-Menu $comps -AllowCancel


#Invoke-Rdp -Comp $choice