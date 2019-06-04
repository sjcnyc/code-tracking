function Get-LocalAccount
{
    # new in PSv3: -Skip skips first 4 lines:
    $result = net user | Select-Object -Skip 4
    # skip last 2 lines:
    $result = $result | Select-Object -First ($result.Count - 2)
    # new in PSv3: call Trim() method for each string in the array:
    $result = $result.Trim()
    # split users wherever there are at least 2
    # whitespaces using a regular expression:
    $result -split '\s{2,}'
}

Get-LocalAccount
Write-Host "`t`nContains Admin: $((Get-LocalAccount) -contains 'Administrator')"