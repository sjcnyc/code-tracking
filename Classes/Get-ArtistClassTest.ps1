$data = Import-Csv C:\temp\data.csv

class MyUpcoming {

    #properties
    [string]$Title
    [datetime]$ReleaseDate
    [string]$comments
    [int]$openIn
    [string]$Rating
    [boolean]$Nowplaying = $false

    #methods
    [MyUpcoming]Update() {

        $this.openIn = ($this.ReleaseDate - (Get-Date)).totaldays

        if ((Get-Date) -ge $this.ReleaseDate) {
            $this.Nowplaying = $true
        }
        return $this
    }

    #constructor
    MyUpcoming([string]$Title, [datetime]$ReleaseDate, [string]$Rating, [string]$comments) {
        $this.Title = $Title
        $this.ReleaseDate = $ReleaseDate
        $this.Rating = $Rating
        $this.comments = $comments
        $this.Update()
    }
}

$data[0..5] | ForEach-Object {
    [MyUpcoming]::new($_.Title,$_.ReleaseDate,$_.Rating,$_.comments)
}