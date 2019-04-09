function Get-LoggedOnUser {
  param (
    [string]
    $Computername
  )
  quser /server:$Computername 2>&1 | Select-Object -Skip 1 | ForEach-Object {
    $CurrentLine = $_.Trim() -Replace '\s+', ' ' -Split '\s'
    $HashProps = @{
      UserName     = $CurrentLine[0]
      ComputerName = $Computername
    }
    $HashProps
  }
}