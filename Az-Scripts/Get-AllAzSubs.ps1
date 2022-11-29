$resources = @()
Get-AzSubscription | ForEach-Object {
   # $_ | Set-AzContext
   [pscustomobject]@{
    subscriptionName = $_.Name
    subscriptionId = $_.SubscriptionId
   }

}
$resources | Export-csv d:\Temp\subs.csv