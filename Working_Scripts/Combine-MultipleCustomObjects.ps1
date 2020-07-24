$Users = @(
  [PSCustomObject]@{
    FirstName = "Bob"
    LastName  = "Dole"
    FullName  = "Bob Dole"
  },
  [PSCustomObject]@{
    FirstName = "Fred"
    LastName  = "Cox"
    FullName  = "Fred Cox"
  }
)

$NewUsers = @(
  [PSCustomObject]@{
    FirstName = "Robert"
    LastName  = "Dole"
    FullName  = "Robert Dole"
  },
  [PSCustomObject]@{
    FirstName = "Fredrick"
    LastName  = "Cox"
    FullName  = "Fredrick Cox"
  }
)

$Users | Where-Object {$_.LastName -in $Users.LastName} | ForEach-Object {
  $User = $_
  $NewUser = $NewUsers | Where-Object {$_.LastName -like $User.LastName}
  $_ | Get-Member | Where-Object {$_.MemberType -eq "NoteProperty"} | ForEach-Object {
    $Property = $_.Name
    $Value = $($_.Definition -split '=')[1]
    [PSCustomObject]@{
      Property = $Property
      OldValue = $Value
      NewValue = $NewUser."$Property"
    }
  }
}