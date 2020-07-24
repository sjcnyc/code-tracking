@"
HEMM014
WHEE003
COHO002
"@ -split [environment]::NewLine | ForEach-Object {
    Set-ADUser -Identity $_ -Replace @{ extensionAttribute7 = "NoSync"}
    #get-qaduser $_ -IncludeAllProperties | select samaccountname, name, extensionAttribute7
}