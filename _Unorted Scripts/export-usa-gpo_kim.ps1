Function Export-OUGPOs {

    [CmdletBinding(SupportsShouldProcess = $true)]
    Param(
        [string]$OU,
        [string]$FolderName

    )

    $searchscope = Get-QADObject -Type 'organizationalUnit' -SearchRoot $ou -SizeLimit 0

    foreach ($source in $searchscope) {

        $linked = (Get-SDMgplink -Scope $source.DN)

        foreach ($link in ($linked).where{$_.Enabled -eq $true}) {
            try {

                #Export-SDMgpo -DisplayName $link.Name.ToString() -Location c:\temp\
                Get-GPO -Name $link.Name.ToString()  |
                    ForEach-Object {
                    $_.GenerateReport('html') | Out-File "c:\temp\USA-GPOs\$($foldername)\$($link.Name.ToString()).htm"
                    # $_.GenerateReport('xml') | Out-File "c:\temp\USA-GPOs\$($foldername)\$($link.Name.ToString()).xml"
                }
            }
            catch {
                $_
            }
        }
    }
}

$ous = Get-QADObject -Type 'organizationalUnit' -SearchScope OneLevel | Select-Object DN, Name

foreach ($ou in $ous) {

    if ( -Not (Test-Path -Path c:\temp\USA-GPOs\$($ou.Name) ) ) {
        New-Item -ItemType directory -Path c:\temp\USA-GPOs\$($ou.Name)
    }
    Export-OUGPOs -OU $ou.DN -FolderName $ou.Name
}


#$result | Export-Csv -Path "c:\Temp\GPOLinks.csv" -NoTypeInformation

#New-GPLink -Guid $guid -Target $Target -LinkEnabled $enabled -confirm:$false -WhatIf
#Set-GPLink -Guid $guid -Target $Target -Order $order -confirm:$false -WhatIf

#Get-GPO -All | Foreach-Object { $_.GenerateReport('xml') | Out-File "$($_.DisplayName).xml" }