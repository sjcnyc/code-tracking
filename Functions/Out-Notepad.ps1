function Out-Notepad {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object]
        $InputObject
    )
    begin { $objs = @() }
    process { $objs += $InputObject }
    end {
        $old = Get-clipboard # store current value
        $objs | out-string -width 150 | Set-Clipboard
        notepad /c
        Start-Sleep -mil 500
       # $old | Set-Clipboard # restore the original value
    }
}

function Set-Clipboard {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)][object]$s
    )
    begin { $sb = new-object Text.StringBuilder }
    process {
        $s | ForEach-Object {
            if ($sb.Length -gt 0) { $null = $sb.AppendLine(); }
            $null = $sb.Append($_) 
        }
    }
    end { Add-Type –a system.windows.forms; [windows.forms.clipboard]::SetText($sb.Tostring()) }
}

function Get-Clipboard {
    Add-Type –a system.windows.forms; [windows.forms.clipboard]::GetText()
}

get-process | Out-Notepad