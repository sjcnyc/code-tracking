class VideoGameConsole {
    VideoGameConsole($company, $name){
        $this.company = $company
        $this.name = $name
    }
    
    hidden [void] DrawLogo($name)
    {
        Write-Host "Drawing the $($name) logo here" ([environment]::NewLine)
    }
    
    [string]$company
    [string]$name
}

class Xbox : VideoGameConsole {
    Xbox() : base('Microsoft','Xbox'){}

    [void] DrawLogo() {
        $this.DrawLogo('Xbox')
    }
}

class PlayStation : VideoGameConsole {
    PlayStation() : base('Sony','PlayStation'){}

    [void] DrawLogo() {
        $this.DrawLogo('PlayStation')
    }
}

class Wii : VideoGameConsole {
    Wii() : base('Nintendo','Wii'){}
    
    [void] DrawLogo(){
        $this.DrawLogo('Wii')
    }
}

[Xbox]::new().DrawLogo()
[PlayStation]::new().DrawLogo()
[Wii]::new().DrawLogo()


[Xbox]::new()
[PlayStation]::new()
[Wii]::new()