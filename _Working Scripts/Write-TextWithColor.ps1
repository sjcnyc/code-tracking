$Red = "$([char]27)[91m"
$Green = "$([char]27)[92m"
$Yellow = "$([char]27)[93m"
$Blue = "$([char]27)[94m"
$Magenta = "$([char]27)[95m"
$Reset = "$([char]27)[0m"

Write-Information "$($Red)This $($Green)text $($Yellow)has $($Blue)mixed $($Magenta)colors.$Reset" -InformationAction Continue