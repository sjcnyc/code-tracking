.\get-dfslinks.ps1 -path \\bmg.bagint.com\usa\ |
Select-Object name,path,state,timeout, `
@{N='Target Path';E={
		$path=@()
		$_.Targets | ForEach-Object {$path+=$_.path}
		$path -as [string]
	}}, `
@{N='Target State';E={
		$state=@()
		$_.Targets | ForEach-Object {$state+=$_.state}
		$state -as [string]
	}}, `
@{N='Target Site';E={
		$site=@()
		$_.Targets | ForEach-Object {$site+=$_.site}
		$site -as [string]
	}} # |