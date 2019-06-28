[CmdletBinding(SupportsShouldProcess = $true)]
Param()

$searchscope = Get-QADObject -Type 'organizationalUnit' -SearchScope Subtree -SizeLimit 0

$result = New-Object System.Collections.ArrayList

foreach ($source in $searchscope) {

  $linked = (Get-SDMgplink -Scope $source.DN)

  foreach ($link in $linked) {

    $info = [pscustomobject]@{
      'OU'       = $source.DN
      'guid'     = $link.GPOID
      'Domain'   = $link.GPODomain
      'Enforced' = $link.enforced
      'order'    = $link.SOMLinkOrder
      'enabled'  = $link.Enabled
      'Name'     = $link.Name
      }

      $enabled = $link.Enabled

      if ($enabled) 
      { 
        $enabled = "Yes"
      }
      else 
      { 
        $enabled = "No" 
      }
      $null = $result.Add($info)
  }
}

$result #| Export-Csv -Path "$env:HOMEDRIVE\Temp\GPOLinks.csv" -NoTypeInformation

#New-GPLink -Guid $guid -Target $Target -LinkEnabled $enabled -confirm:$false -WhatIf
#Set-GPLink -Guid $guid -Target $Target -Order $order -confirm:$false -WhatIf