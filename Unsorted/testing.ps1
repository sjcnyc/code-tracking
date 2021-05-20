[CmdletBinding(SupportsShouldProcess = $true)]
Param(
  [Parameter(Mandatory = $true)][string]$CsvName,
  [System.Management.Automation.CredentialAttribute()]
  $credential=(get-credential)
)

$linkedDC = 'CULSMEADS0101.me.sonymusic.com'

Import-Csv $CsvName | ForEach-Object -Process {
  
  try 
  {
    #Set-Mailbox –Identity $_.Identity -LinkedDomainController $linkedDC -LinkedMasterAccount $_.LinkedMasterAccount -LinkedCredential $credential
  }
  catch 
  {
    [Management.Automation.ErrorRecord]$e = $_

    $info = New-Object -TypeName PSObject -Property  @{
      Exception = $e.Exception.Message
    }

    $info
  }
}

