function Get-Reddit()
{
    param($Subreddit='PowerShell')

    $response = Invoke-WebRequest -Uri "http://www.reddit.com/r/$Subreddit.json"
    $obj = ConvertFrom-Json ($response.Content)
    $obj.Data.Children.Data | Select-Object Title, Score, num_comments, Url, PermaLink
}

