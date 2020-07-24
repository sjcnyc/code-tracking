function Join-Objects {
    param([Parameter(Mandatory = $true)][PSCustomObject]$Object1,
        [Parameter(Mandatory = $true)][PSCustomObject]$Object2)

    $object3 = New-Object -TypeName PSObject

    foreach ( $Property in $Object1.PSObject.Properties) {
        $arguments += @{$Property.Name = $Property.value }

        $object3 | Add-Member -MemberType NoteProperty -Name $Property.Name -Value $Property.value
    }

    foreach ( $Property in $Object2.PSObject.Properties) {
        $object3 | Add-Member -MemberType NoteProperty -Name $Property.Name -Value $Property.value
    }

    return $object3
}

$EWSDLL = (($(Get-ItemProperty -ErrorAction SilentlyContinue -Path Registry::$(Get-ChildItem -ErrorAction SilentlyContinue -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Exchange\Web Services'|Sort-Object Name -Descending| Select-Object -First 1 -ExpandProperty Name)).'Install Directory') + "Microsoft.Exchange.WebServices.dll")
if (Test-Path $EWSDLL) {
    Import-Module $EWSDLL
}
else {
    "$(get-date -format yyyyMMddHHmmss):"
    "This script requires the EWS Managed API 1.2 or later."
    "Please download and install the current version of the EWS Managed API from"
    "http://go.microsoft.com/fwlink/?LinkId=255472"
    ""
    "Exiting Script."
    exit
}

$ExchangeVersion = [Microsoft.Exchange.WebServices.Data.ExchangeVersion]::Exchange2013_SP1

$service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService($ExchangeVersion)

$creds = New-Object System.Net.NetworkCredential('repoman@SonyMusicEntertainment.onmicrosoft.com', 'KeepItCleanKids!')
$service.Credentials = $creds

## Code From http://poshcode.org/624
## Create a compilation environment
$Provider = New-Object Microsoft.CSharp.CSharpCodeProvider
$Compiler = $Provider.CreateCompiler()
$Params = New-Object System.CodeDom.Compiler.CompilerParameters
$Params.GenerateExecutable = $False
$Params.GenerateInMemory = $True
$Params.IncludeDebugInformation = $False
$Params.ReferencedAssemblies.Add("System.DLL") | Out-Null

$TASource = @'
  namespace Local.ToolkitExtensions.Net.CertificatePolicy{
    public class TrustAll : System.Net.ICertificatePolicy {
      public TrustAll() {
      }
      public bool CheckValidationResult(System.Net.ServicePoint sp,
        System.Security.Cryptography.X509Certificates.X509Certificate cert, 
        System.Net.WebRequest req, int problem) {
        return true;
      }
    }
  }
'@ 
$TAResults  = $Provider.CompileAssemblyFromSource($Params, $TASource)
$TAAssembly = $TAResults.CompiledAssembly

$TrustAll   = $TAAssembly.CreateInstance("Local.ToolkitExtensions.Net.CertificatePolicy.TrustAll")
[System.Net.ServicePointManager]::CertificatePolicy = $TrustAll

$uri = [system.URI] "https://outlook.office365.com/EWS/Exchange.asmx"
$service.Url = $uri
$pagesize = 100
$offset = 0
$propertySet = new-object Microsoft.Exchange.WebServices.Data.PropertySet([Microsoft.Exchange.WebServices.Data.ItemSchema]::InternetMessageHeaders)
do {
    $view = New-Object Microsoft.Exchange.WebServices.Data.ItemView($pagesize, $offset)
    $findResults = $service.FindItems([Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Inbox, $view)
    foreach ($item in $findResults.Items) {

          $PSObj = [pscustomobject]@{

             'From'       = $item.From
             'ReplyTo'    = $item | Select-Object -ExpandProperty ReplyTo
             'Sender'     = $item.Sender
             'Subject'    = $item.Subject
             'Received'   = $item.ReceivedBy
             'Message-ID' = $item.InternetMessageId
          }

          $item.Load($propertySet)

          $PSObj2 = [pscustomobject]@{
             'Authentication-Results'            = ($item.InternetMessageHeaders | Where-Object {$_.name -match 'Authentication-Results'}).value
             'Received-SPF'                      = ($item.InternetMessageHeaders | Where-Object {$_.name -match 'Received-SPF'}).value
             'DKIM-Signature'                    = ($item.InternetMessageHeaders | Where-Object {$_.name -match 'DKIM-Signature'}).value
             'X-Originating-ip'                  = ($item.InternetMessageHeaders | Where-Object {$_.name -match 'X-Originating-IP'}).value
             'Return-Path'                       = ($item.InternetMessageHeaders | Where-Object {$_.name -match 'Return-Path'}).value
             'X-Forefront-Antispam-Report'       = ($item.InternetMessageHeaders | Where-Object {$_.name -match 'X-Forefront-Antispam-Report'}).value
             'X-MS-Exchange-Organization-AuthAs' = ($item.InternetMessageHeaders | Where-Object {$_.name -match 'X-MS-Exchange-Organization-AuthAs'}).value
             'X-CustomSpam'                      = ($item.InternetMessageHeaders | Where-Object {$_.name -match 'X-CustomSpam'}).value
             'ReceivedFrom'                          = (($item.InternetMessageHeaders | Where-Object {$_.name -match 'Received'}).value | Out-String).Trim()
             #'X-Headers'                         =  ($item.InternetMessageHeaders | ForEach-Object {"$($_.Name): $($_.Value)"} | Out-String).Trim()
          }
          Join-Objects -Object1 $PSObj -Object2 $PSObj2 | Export-Csv -Path C:\Temp\X-Headers7.csv -NoTypeInformation -Append
        }
    $offset += $pagesize
} while ($findResults.MoreAvailable)