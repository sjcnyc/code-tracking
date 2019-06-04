@"
LYNSBMEBKP001
"@ -split [environment]::NewLine |

ForEach-Object {
    Get-WmiObject win32_systemenclosure -comp $_ | Select-Object serialnumber 
    }

