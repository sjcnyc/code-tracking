(Get-Content -Path "C:\temp\CI-CDValidation.csv") | Set-Content -Path "C:\temp\CI-CDValidation_UTF8.csv" -Encoding UTF8
$CsiScan = Import-Csv "C:\temp\CI-CDValidation_UTF8.csv" -Header (0..14) |Select-Object -SkipLast 2 |ForEach-Object{ New-Object psobject -Property @{"Code"=$_.11;"Message"=$_.12;"Result"=$_.13}}
$Exceptions = Import-Csv 'C:\temp\exceptions.csv'

$ErrorList  = Compare-Object -ReferenceObject $CsiScan -DifferenceObject $Exceptions -Property Code -PassThru |Select-Object Code, Message, Result |Where-Object{$_.Result -ne "Pass"}

if ($ErrorList.Count -gt 0) {
    [Console]::Error.WriteLine("An error occurred.")
    $ErrorList |ForEach-Object{
$Log = @"
 Code:    $($_.Code)
 Message: $($_.Message)
 Result:  $($_.Result)
"@
    Write-Host "##vso[task.logissue type=error;]$([environment]::NewLine)$($Log)"}
}