<#Created By Nitesh bhat (Mail Address : bhatnitesh@outlook.com/niteshbhat@icloud.com)#>
    
    $SerialNumber=(Get-WmiObject win32_bios).SerialNumber
    $Refresh=$true
    Set-StrictMode -Version Latest
    if ( $Script:PSBoundParameters.ContainsKey("host") ) { $hostPreference = "Continue" }
    Set-Variable productObjectVersion -value 0.4
    Set-Variable lenovoWarrantyUrl -value "https://csp.lenovo.com/ibapp/il/WarrantyStatus.jsp"
    Set-Variable lenovoProductDescriptionUrl  -value "http://support.lenovo.com/services/us/en/advancedsearch/getsearchresult/1c2d5342-a15b-4828-9095-13e5d52f9df6?dataSource=aca55143-0507-4b4d-a559-65147c1dec9a&SearchKey="
    Set-Variable lenovoPartsUrl  -value "http://support.lenovo.com/templatedata/Web%20Content/JSP/partsLookup.jsp"
    Set-Variable cacheDir  -value (Join-Path $env:APPDATA "LenovoProductInfo_Cache")
    Set-Variable maxCacheAge -value 90 
    
    if ( !( Test-Path $cacheDir ) ){ $null = New-Item -Type "Directory" -Path $cacheDir }
    Function CleanHtml($htData) {
        Return $htData -replace "&nbsp;", "" -replace "(\r|\f|\n)*", "" -replace "\t", " " -replace "  ", "" -replace "> <", "><" -replace "<img[^>]*>", "" -replace "</?b>", ""
    }
  
        $SerialNumber = $SerialNumber.Trim().ToUpper()
        
        $useCache = $false
        if ( $cacheHit = ls $cacheDir | ? { $_.Name -like "$($SerialNumber)_*" } ) {
            
            $useCache = $true
            if ( $Refresh ) {
                $useCache = $false
            }
            elseif ( $cacheHit -notlike "*_v$($productObjectVersion).xml" ) {
                Write-host "Version Mismatch; Deleting... :-("
                $useCache = $false
            }
            elseif ( ( Get-Date ) -gt $cacheHit.CreationTime.AddDays(90) ) {
                Write-host "Stale Cache; Deleting... :-("
                $useCache = $false
            }

            if ( ! $useCache ) { Remove-Item ( Join-Path $cacheDir $cacheHit ) }
        }
        function downloadProductData () {
           
            $ErrorActionPreference = "Stop"
            [net.httpWebRequest] $webReq = [net.webRequest]::create($lenovoWarrantyUrl)
            $webReq.Method = "POST"

            $postData = "type=&serial=$($SerialNumber)&selLanguage=EN&country=897&iws=off&sitestyle=lenovo"
            $postBuffer = [Text.Encoding]::Ascii.GetBytes($postData)
            $webReq.ContentLength = $postBuffer.Length
            $webReq.ContentType = "application/x-www-form-urlencoded"
            $reqStr = $webReq.GetRequestStream()
            $reqStr.Write( $postBuffer, 0, $postBuffer.Length)
            $reqStr.Flush()
            $reqStr.Close()

            [net.httpWebResponse] $webResp = $webReq.GetResponse()
            $strRdr = New-Object IO.StreamReader($webResp.GetResponseStream())
            $htData = CleanHtml( $strRdr.ReadToEnd() )
            $webResp.Close()
            $warrantyHtData = $htData -replace ".*<!-- Warranty information Cycle Start-->", "" -replace "Excluding:.*", "" -replace "End Date:", ""
            $skuData = (Select-String "<td[^>]*>([^<:]+?)</td>" -InputObject $warrantyHtData -AllMatches).Matches | % {$_.Groups[1].Value}
            $lenovoProduct = New-Object psObject
            
            $lenovoProduct | Add-Member NoteProperty ProductID $skuData[0]
            $lenovoProduct | Add-Member NoteProperty Type ($skuData[1] -split "-")[0]
            $lenovoProduct | Add-Member NoteProperty Model ($skuData[1] -split "-")[1]
            $lenovoProduct | Add-Member NoteProperty SerialNumber $skuData[2]
            $lenovoProduct | Add-Member NoteProperty Location $skuData[3]
            $lenovoProduct | Add-Member NoteProperty WarrantyExpiration $skuData[4]
            write-host "Serial Number:$SerialNumber"
           write-host  "Product ID:$($lenovoProduct.ProductID )"
           write-host "Warranty End:$($lenovoProduct.WarrantyExpiration)"
           $script:warranty=$($lenovoProduct.WarrantyExpiration)
            $ErrorActionPreference = "Continue"
            $null = $htData -match "<table[^>]*PartsTable.*?</table>"
            $trData = (Select-String "<tr><td[^>]*>[^<]*</td><td[^>]*>([^-<]*)</td><td[^>]*>([^<]*)</td></tr>" -InputObject $Matches[0] -AllMatches).Matches
            
            $lenovoProduct | Add-Member NoteProperty FRUs (New-Object psobject)
            foreach ( $tr in $trData ){
                $partObject = New-Object psObject
                $partObject | Add-Member NoteProperty FRU $tr.Groups[1].Value
                $partObject | Add-Member NoteProperty Description $tr.Groups[2].Value
                $lenovoProduct.FRUs | Add-Member NoteProperty $partObject.FRU $partObject -ErrorAction "SilentlyContinue"
            }
            $htClient = New-Object System.Net.Webclient
            #Query by product type
            $htData = $htClient.DownloadString("$($lenovoProductDescriptionUrl)$($lenovoProduct.ProductID)")
            #Navigate to result page
            $null = $htData -match '<a href="(.*?)">'
            $htData = cleanHtml( $htClient.DownloadString("http://support.lenovo.com/$($Matches[1])") )
            
            $null = $htData -match 'class="product-detail-title">(.*?)<'
            $lenovoProduct | Add-Member NoteProperty ProductName ($Matches[1] -replace ".*>" -replace " $($lenovoProduct.ProductID)" -replace " \(.*?\)")
            write-host "Product Name:$($lenovoProduct.ProductName)"
          
            $lenovoProduct | Add-Member NoteProperty __QueryDate (Get-Date)
            $lenovoProduct | Add-Member NoteProperty __productObjectVersion $productObjectVersion

            $lenovoProduct | Export-Clixml (Join-Path $cacheDir "$($lenovoProduct.SerialNumber)_$($lenovoProduct.ProductID)_v$($productObjectVersion).xml")
            Return
        }

        #Import line is potentially error prone, make it more specific later on
        if ( -not $useCache ) { downloadProductData }

        $lenovoProduct = Import-Clixml ( Join-Path $cacheDir "$($SerialNumber)_*" )
        $curentdate = (Get-Date).AddDays(-1).ToString('yyyy-MM-dd')
        $script:expdates=(New-TimeSpan -start "$curentdate" -end $script:warranty).Days
        if($script:expdates -le "35") {
            write-host "Warranty is going to expire in :$expdates Days"
            exit 1001
            }
            else
            {
            exit 0
            }