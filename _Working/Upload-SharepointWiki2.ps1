Connect-PnPOnline -Url "https://sonymusicentertainment.sharepoint.com/sites/AVA_Projects"
$web = Get-PnPWeb -identity "/sites/AVA_Projects/ADSEC_O365/seanland"
$wikipageurl = "/sites/AVA_Projects/ADSEC_O365/seanland/SitePages/TestPage10.aspx"

$content = Get-Content "C:\temp\HelpdeskWiki\helpdeskwiki\helpdeskwiki\wiki\pmwikicce1.html" -Raw

Add-PnPWikiPage -ServerRelativePageUrl $wikipageurl -Content $content -Web $web

<# Wiki Page Layout parameters are:
OneColumn, OneColumnSideBar, TwoColumns, TwoColumnsHeader, TwoColumnsHeaderFooter, ThreeColumns, ThreeColumnsHeader, ThreeColumnsHeaderFooter, Custom #>



#$content = [IO.File]::ReadAllText("D:\Nakkeeran\PnP\wikicontent.html")
#Add-SPOWikiPage -ServerRelativePageUrl "/Wiki Pages/PnPWikiPage2.aspx" -Content $content

#C:\temp\HelpdeskWiki\helpdeskwiki\helpdeskwiki\wiki\pmwiki0a17.html

function Upload-HTMLToSharePoint {
  param(
    [string]
    $HTMLPage
  )
  Connect-PnPOnline -Url "https://sonymusicentertainment.sharepoint.com/sites/AVA_Projects"
  $web = Get-PnPWeb -identity "/sites/AVA_Projects/ADSEC_O365/seanland"

  $Content = Get-Content $HTMLPage -Raw
  $FileName = Get-ChildItem $HTMLPage

  $wikipageurl = "/sites/AVA_Projects/ADSEC_O365/seanland/SitePages/$($FileName.Name).aspx"
  Add-PnPWikiPage -ServerRelativePageUrl $wikipageurl -Content $Content -Web $web
}