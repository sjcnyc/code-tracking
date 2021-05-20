$Left = (Import-Csv "C:\temp\test1.csv" -Header (0..20) |Select-Object).ForEach{New-Object psobject -Property @{"Code" = $_.11; "Message" = $_.12; "Result" = $_.13}}
$Right = Import-Csv 'C:\temp\exceptions.csv'

function Get-DifferenceArray {
    [cmdletbinding()]
    param (
        $Left,
        $Right,
        [switch]$unique
    )

    if ($unique.IsPresent) {
        #https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic.hashset-1.symmetricexceptwith?view=netframework-4.7.2
        $diff = [Collections.Generic.HashSet[string]]$Left
        $diff.SymmetricExceptWith([Collections.Generic.HashSet[string]]$Right)
        return [string[]]$diff
    }
    $occurrences = @{}
    foreach ($_ in $Left) { $occurrences[$_]++ }
    foreach ($_ in $Right) { $occurrences[$_]-- }
    foreach ($_ in $occurrences.GetEnumerator()) {
        $cnt = [Math]::Abs($_.value)
        while ($cnt--) { $_.key }
    }
}

$arraylist = ($Left).Where{(Get-DifferenceArray -Left $Left.code -Right $right.code -unique) -contains $_.Code -and $_.Result -ne "Pass"}

$ErrorList = $arraylist | ForEach-Object {'{0} {1} {2}' -f $_.code, $_.message, $_.result}

if ($ErrorList) {
    [Console]::Error.WriteLine("An error occurred.")
    Write-Host "##vso[task.logissue type=error;]$($ErrorList)"
}

$PsArray = (Compare-Object -ReferenceObject $Left -DifferenceObject $Right).where{ $_.Result -ne "Pass" }

$ErrorList = ($PsArray.InputObject).ForEach{'Code: {0} Message: {1} Reuslt: {2}' -f $_.code, $_.message, $_.result}

if ($ErrorList) {
    [Console]::Error.WriteLine("An error occurred.")
    Write-Host "##vso[task.logissue type=error;]$($ErrorList)"
}