#Requires -Version 3.0 
<# 
    .SYNOPSIS
      Display data page by page, asking for a key press to continue
    .DESCRIPTION
 
    .NOTES 
        File Name  : Out-More
        Author     : Sean Connealy
        Requires   : PowerShell Version 3.0 
        Date       : 4/7/2015

    .LINK 
        This script posted to: https://gist.github.com/sjcnyc/4c446c60635e967d2cc2

    .EXAMPLE
      Get-Process | Out-More
#>

function Out-More 
{
    param 
    (
        $Lines = 20,         
        [Parameter(ValueFromPipeline=$true)]
        $InputObject 
    )    
    begin 
    {
        $counter = 0 
    }    
    process 
    {
        $counter++ 
        if ($counter -ge $Lines)
        {
            $counter = 0 
            Write-Host 'Press ENTER to continue' -ForegroundColor Yellow 
            Read-Host  
        }
        $InputObject 
    }
}