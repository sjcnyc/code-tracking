function New-Password {

  $Random = New-Object System.Random

  # Two Upper Case Characters

  [string]$Password += [char]$Random.Next(49,57)
  [string]$Password += [char]$Random.Next(65,72)

  # Two LowerCase Characters

  [string]$Password += [char]$Random.Next(97,107)
  [string]$Password += [char]$Random.Next(109,122)

  # One Special Char

  [string]$Password += [char]$Random.Next(36,43)

  # Two UpperCase Characters

  [string]$Password += [char]$Random.Next(65,72)
  [string]$Password += [char]$Random.Next(80,91)

  # One LowerCase

  [string]$Password += [char]$Random.Next(97,107)

  $Password
  $Password = $Null
}


New-Password
