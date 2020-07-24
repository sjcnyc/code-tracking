function Invoke-InDirectory {
    Param(
        [ValidateScript( { Test-Path $_ -PathType Container } )]
        [string] $Path,
        [ValidateNotNullOrEmpty()]
        [scriptblock] $ScriptBlock
    )
    
    try {
        Push-Location $Path
        & $ScriptBlock
    }
    finally {
        Pop-Location
    }
}

# invoke in repo root
Invoke-InDirectory "$PSScriptRoot/.." {
	Invoke-InDirectory "./components" {
		npm install
		npm build
	}
	Invoke-InDirectory "./server" {
		npm install
		npm build
	}

	# deploy our monorepo
	$timestamp = Get-Date -Format 'yyyyMMddhhmmss'
	git checkout -b "release/$timestamp"
	git add ./components/build --force
	git add ./server/build --force
	git commit -am "adding deployment artifacts to release branch"
	git push production master
}