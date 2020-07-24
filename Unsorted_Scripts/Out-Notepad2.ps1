function Out-Notepad2 {
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Object]
        [AllowEmptyString()]
        $Object,

        [Int]
        $Width = 150
    )

    begin {
        $al = New-Object System.Collections.ArrayList
    }

    process {
        $null = $al.Add($Object)
    }
    end {
        $text = $al |
            Format-Table -AutoSize -Wrap | Out-String -Width $Width


        $WScript = New-Object -ComObject 'wscript.shell'
        $WScript.Run('notepad.exe') | Out-Null
        do {
            Start-Sleep -Milliseconds 100
        }
        until ($WScript.AppActivate('notepad2-mod'))
        
        $WScript.SendKeys($text.ToString())
        break;
    }
}

Get-Process | Out-Notepad2