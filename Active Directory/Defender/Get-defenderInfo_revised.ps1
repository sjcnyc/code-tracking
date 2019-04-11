Function Convert-IntTodate {
  Param ($Integer)
  if ($Integer -eq $null) {
    $date = $null
  }
  else {
    
    $date = [datetime]::FromFileTime($Integer).ToString('g')
    
    If ($Date.IsDaylightSavingTime)
    {
      $Date = $Date.AddHours(1)
    }
    $Date
  }
}

$newobj=@()

$tokens =  Get-QADObject `
 -SizeLimit 0 `
 -IncludeAllProperties `
 -Type 'defender-tokenClass' `
 -SearchRoot 'DC=bmg,DC=bagint,DC=com

  
  foreach ($td in $_.'defender-tokenUsersDNs' ) {
      
    $result = Get-QADUser `
    -Identity $td `
    -IncludeAllProperties `
    -ErrorAction 0 `
    -Enabled

    $newObj = New-Object System
    
    $newobj += New-Object -TypeName PSObject -Property @{
            'defender-name' = $result.name
            'defender-userID' = $result.samaccountname
            'defender-violationCount' = $result.'defender-violationCount'
            'defender-resetCount' = $result.'defender-resetCount'
            'defender-lockoutTime' = (convert-intTodate $result.'defender-lockoutTime')
            'defender-lastlogon' = (convert-intTodate $result.'defender-lastlogon')
            'defender-tokenName' = $token.name
            'defender-tokenDescription' = $token.description
            'defender-parentContainer' = $result.parentcontainer
            'Account-IsDisabled' = $result.AccountIsDisabled
        } #| Where-Object {$result.ParentContainer -like 'bmg.bagint.com/USA*'}
    }
\defender_inf_5.csv' -NoTypeInformation -Append