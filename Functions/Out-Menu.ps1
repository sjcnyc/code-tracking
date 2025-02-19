﻿Clear-Host
$comps = (Get-QADComputer -SearchRoot 'OU=Windows 2012,OU=SRV,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com').Name | Sort-Object

$choice = Out-Menu $comps -AllowCancel -Header 'Choose Server to RDP to' -Footer 'Enter Number to Select, <esc> to Cancel'
  
Invoke-Rdp -Comp $choice

function Out-Menu {
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True)]
        [object[]]$Object, 
        [string]$Header, 
        [string]$Footer, 
        [switch]$AllowCancel, 
        [switch]$AllowMultiple 
    ) 
 
    if ($input) { 
        $Object = @($input)
    }

    if (!$Object) {
        throw 'Must provide an object.'
    } 
 
    Write-Host '' 
 
    do { 
        $prompt = New-Object System.Text.StringBuilder 
        switch ($true) { 
            {[bool]$Header -and $Header -notmatch '^(?:\s+)?$'} { $null = $prompt.Append($Header); break }
            $true { $null = $prompt.Append('Choose an option') } 
            $AllowCancel { $null = $prompt.Append(', or enter "c" to cancel.') } 
            $AllowMultiple {$null = $prompt.Append("`nTo select multiple, enter numbers separated by a comma EX: 1, 2") } 
        } 
        Write-Host $prompt.ToString() 
 
        for ($i = 0; $i -lt $Object.Count; $i++) { 
            Write-Host "$('{0:D2}' -f ($i+1)). $($Object[$i])" 
        } 
 
        if ($Footer) { 
            Write-Host $Footer 
        } 

        Write-Host '' 
 
        if ($AllowMultiple) { 
            $answers = @(Read-Host).Split(',').Trim() 
 
            if ($AllowCancel -and $answers -match 'c') { 
                return 
            } 
 
            $ok = $true 
            foreach ($ans in $answers) { 
                if ($ans -in 1..$Object.Count) { 
                    $Object[$ans - 1] 
                }
                else { 
                    Write-Host 'Not an option!' -ForegroundColor Red 
                    Write-Host ''
                    $ok = $false 
                }
            } 
        }
        else { 
            $answer = Read-Host 

            if ($AllowCancel -and $answer -eq 'c') { 
                return 
            } 
 
            $ok = $true 
            if ($answer -in 1..$Object.Count) { 
                $Object[$answer - 1] 
            }
            else { 
                Write-Host 'Not an option!' -ForegroundColor Red 
                Write-Host '' 
                $ok = $false 
            } 
        } 
    } while (!$ok)
}

function Invoke-Rdp {
    Param(
        [Parameter(Mandatory = $True)]
        [String]$Comp
    )
    mstsc.exe /v $comp /admin /h:1300 /w:2400 /v:$comp
}