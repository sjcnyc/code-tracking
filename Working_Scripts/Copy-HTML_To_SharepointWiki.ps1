Add-PnPPublishingPage -PageName "Test" -PageTemplateName "EnterpriseWiki" -Folder Pages
$item = Get-PnPFile -Url "Pages/Test.aspx" -AsListItem
$item["PublishingPageContent"] = "<p>your content</p>"
$item.Update()
Execute-PnPQuery





Connect-PnPOnline -Url "https://sonymusicentertainment.sharepoint.com/sites/AVA_Projects"
$web = Get-PnPWeb -identity "/sites/AVA_Projects/ADSEC_O365/seanland"
$wikipageurl = "/sites/AVA_Projects/ADSEC_O365/seanland/SitePages/Home123.aspx"
#He then tests to see if the page exists via a Get-PnPListItem -Web $web -List "Site Pages"

Add-PnPWikiPage -web $web -ServerRelativePageUrl $wikipageurl -Layout TwoColumns


Add-PnPWikiPage -ServerRelativePageUrl $wikipageurl -Web $web -Layout OneColumn

Add-PnPWikiPage -pageConnect-PnPOnline -Url "https://sonymusicentertainment.sharepoint.com/sites/AVA_Projects"
$web = Get-PnPWeb -identity "/sites/AVA_Projects/ADSEC_O365/seanland"
$wikipageurl = "/sites/AVA_Projects/ADSEC_O365/seanland/SitePages/Home123.aspx"
#He then tests to see if the page exists via a Get-PnPListItem -Web $web -List "Site Pages"

Add-PnPWikiPage -web $web -ServerRelativePageUrl $wikipageurl -Layout TwoColumns


Add-PnPWikiPage -ServerRelativePageUrl $wikipageurl -Web $web -Layout OneColumn

Add-PnPWikiPage -page