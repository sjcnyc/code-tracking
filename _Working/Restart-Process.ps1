[cmdletbinding(SupportsShouldProcess = $True)]

param (
    [String]
    $targetProcess = 'chrome'
)

$process = Get-Process -Name $targetprocess
 
while ($true){ 
    while (!($process)){ 
        $process = Get-Process -Name $targetprocess 
        if (!($process)){ 
            start-process $targetprocess 
        } 
        start-sleep -s 5 
    } 
    if ($process){ 
        $process.WaitForExit() 
        start-sleep -s 2 
        $process = Get-Process -Name $targetprocess 
        start-process $targetprocess 
    } 
}