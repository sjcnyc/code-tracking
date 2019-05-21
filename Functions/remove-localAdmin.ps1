$ErrorActionPreference = "Continue"
$List = Import-CSV "C:\temp\Local_Admin.csv"

try
{
  ForEach($Item in $List){
    $objUser = [ADSI]("WinNT://bmg.bagint.com/$($Item.username)")
    $objGroup = [ADSI]("WinNT://$($Item.AssetName)/Administrators")
    $objGroup.PSBase.Invoke("Remove",$objUser.PSBase.Path)
  }
}

catch [Runtime.InteropServices.COMException]
{
  # get error record
  [Management.Automation.ErrorRecord]$e = $_

  # retrieve information about runtime error
  $info = [PSCustomObject]@{
    Exception = $e.Exception.Message
    Reason    = $e.CategoryInfo.Reason
    Target    = $e.CategoryInfo.TargetName
    Script    = $e.InvocationInfo.ScriptName
    Line      = $e.InvocationInfo.ScriptLineNumber
    Column    = $e.InvocationInfo.OffsetInLine
    $ErrorActionPreference = "Continue"
  }
  
  # output information. Post-process collected info, and log info (optional)
  $info
  $ErrorActionPreference = "Continue"

}