$result = New-Object System.Collections.ArrayList

$props =@{
  Properties = @('SamAccountName', 'Name', 'DisplayName', 'Mail')
}

@'
jorge.ocampo.peak@sonymusic.com
'@ -split [environment]::NewLine |

 Foreach-Object {
    Get-ADUser -Filter {Mail -eq $_} @props  | Select-Object 'SamAccountName', 'Name', 'DisplayName', 'Mail'

    $info = [pscustomobject]@{
      'Name' = $_.Name
      'SamaccountaName' = $_.SamAccountName
      'Displayname' = $_.DisplayName
      'Mail' =    $_.Mail
    }

    $null = $result.Add($info)
  }

  $result