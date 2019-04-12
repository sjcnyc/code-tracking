$inputFromUser = @()
$input = ''
While ($input -ne "q") {
    If ($input -ne $null) {
        $InputFromUser += $input.Trim()
    }
    $input = Read-Host "Enter the input here (Enter 'q' to exit) "
}
$inputFromUser = $inputFromUser[1..($inputFromUser.Length - 1)]