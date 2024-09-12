function Load {
    param([scriptblock]$function,
        [string]$Label)
    $job = Start-Job  -ScriptBlock $function -Name "user"

    $symbols = @("|", "/", "-", "\", "|")
    $i = 0;
    while ($job.State -eq "Running") {
        $symbol =  $symbols[$i]
        Write-Host -NoNewLine "`r$symbol $Label" -ForegroundColor Green
        Start-Sleep -Milliseconds 100
        $i++
        if ($i -eq $symbols.Count){
            $i = 0;
        }   
    }
    Write-Host -NoNewLine "`r"
}

Clear-Host

load -function {
    $user = get-aduser sconnea
    start-sleep -s 10
    $user
} -Label "Loading user"


$result = Receive-Job -Name "user"

$result
Remove-Job -Name "user"