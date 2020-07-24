
@"
Aasha_lewis@redmusic.com
sconnea@sonymusic.com
"@ -split [environment]::NewLine |

 
    ForEach-Object {
        $_ | 
            Get-QADUser -SearchRoot 'dc=mnet,dc=biz' -sizeLimit 0 | Select-Object samaccountname, email, name |
                Add-Member -MemberType NoteProperty -Name 'SMTP1' -Value $_.proxyaddress -PassThru 

<#@{N="SMTP1";E={
	$proxyvalue=@()
	$_.proxyaddresses | foreach {$proxyvalue += (where { $_.startswith("SMTP:")}).substring(5)}
	$proxyvalue -as [string]

}}
#>
} 
