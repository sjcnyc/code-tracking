$Users = (Get-ADUSer -Filter *).count
$Computers = (Get-ADComputer -Filter *).count
$Security_Groups = (Get-ADGroup -Filter {GroupCategory -eq "Security"}).count

Write-Output "User Count: $users"
Write-Output "Computer Count: $computers"
Write-Output "Security Group Count: $Security_Groups"
