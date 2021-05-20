@'
jjackson
'@ -split [environment]::NewLine | ForEach-Object {


  Add-QADGroupMember -Identity 'WWI-Crashplan-Americas Users' -Member $_

}