function Join-Objects {
    param(
        [Parameter(Mandatory = $true)][PSCustomObject]$Object1,
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

function Get-FolderItems {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true)] [string]$MailboxName,
        [Parameter(Position = 1, Mandatory = $true)] [PSCredential]$Credentials,
        [Parameter(Position = 2, Mandatory = $true)] [string]$FolderPath,
        [Parameter(Position = 3, Mandatory = $false)] [switch]$useImpersonation,
        [Parameter(Position = 4, Mandatory = $false)] [string]$url
    )
    Begin {

        $limit    = 20000
        $pagesize = 1000

        if ($url) {
            $service = Connect-Exchange -MailboxName $MailboxName -Credentials $Credentials -url $url
        }
        else {
            $service = Connect-Exchange -MailboxName $MailboxName -Credentials $Credentials
        }
        if ($useImpersonation.IsPresent) {
            $service.ImpersonatedUserId = new-object Microsoft.Exchange.WebServices.Data.ImpersonatedUserId([Microsoft.Exchange.WebServices.Data.ConnectingIdType]::SmtpAddress, $MailboxName)
        }
        $PSArrayList = New-Object -TypeName System.Collections.ArrayList
        $fldId = FolderIdFromPath -FolderPath $FolderPath -SmtpAddress $MailboxName
        $SubFolderId = new-object Microsoft.Exchange.WebServices.Data.FolderId($fldId)
        $ivItemView = New-Object Microsoft.Exchange.WebServices.Data.ItemView($pagesize)
        $ItemPropset = new-object Microsoft.Exchange.WebServices.Data.PropertySet([Microsoft.Exchange.WebServices.Data.BasePropertySet]::FirstClassProperties)
        $ivItemView.PropertySet = $ItemPropset
        #$rptCollection = @{}
        $fiItems = $null
        if ($limit -and $limit -lt $pagesize) {
            $pagesize = $limit
        }
        do {
            $fiItems = $service.FindItems($SubFolderId, $ivItemView)
            #[Void]$service.LoadPropertiesForItems($fiItems,$ItemPropset)
            foreach ($Item in $fiItems.Items) {
                #Process Item
                $PSObj = [pscustomobject]@{

                    'From'       = $item.From
                    'ReplyTo'    = $item | Select-Object -ExpandProperty ReplyTo
                    'Sender'     = $item.Sender
                    'Subject'    = $item.Subject
                    'Received'   = $item.ReceivedBy
                    'Message-ID' = $item.InternetMessageId
                }

                $item.Load($ItemPropset)

                $PSObj2 = [pscustomobject]@{
                    'Authentication-Results'            = ($item.InternetMessageHeaders | Where-Object {$_.name -match 'Authentication-Results'}).value
                    'Received-SPF'                      = ($item.InternetMessageHeaders | Where-Object {$_.name -match 'Received-SPF'}).value
                    'Return-Path'                       = ($item.InternetMessageHeaders | Where-Object {$_.name -match 'Return-Path'}).value
                    'DKIM-Signature'                    = ($item.InternetMessageHeaders | Where-Object {$_.name -match 'DKIM-Signature'}).value
                    'X-Originating-ip'                  = ($item.InternetMessageHeaders | Where-Object {$_.name -match 'X-Originating-IP'}).value
                    'X-Forefront-Antispam-Report'       = ($item.InternetMessageHeaders | Where-Object {$_.name -match 'X-Forefront-Antispam-Report'}).value
                    'X-MS-Exchange-Organization-AuthAs' = ($item.InternetMessageHeaders | Where-Object {$_.name -match 'X-MS-Exchange-Organization-AuthAs'}).value
                    'X-CustomSpam'                      = ($item.InternetMessageHeaders | Where-Object {$_.name -match 'X-CustomSpam'}).value
                    'X-Received'                        =(($item.InternetMessageHeaders | Where-Object {$_.name -match 'Received'}).value | Out-String).Trim()
                    'X-Headers'                         = ($item.InternetMessageHeaders | ForEach-Object {"$($_.Name): $($_.Value)"} | Out-String).Trim()
                }
                $PSJoinedObj = Join-Objects -Object1 $PSObj -Object2 $PSObj2
                $null = $PSArrayList.Add($PSJoinedObj)
            }
            $ivItemView.Offset += $fiItems.Items.Count
            if ($ivItemView.Offset -ge $limit) {
                break
            }
        } while (   $fiItems.MoreAvailable -eq $true)
        # Write-Output $rptCollection.Values | Sort-Object -Property NumberOfItems -Descending
        $PSArrayList | Export-Csv -Path \\storage\pstholding$\SpamLogs\X-Headers-$((get-date).ToString("yyy-MM-dd_hh-mm-ss")).csv -NoTypeInformation
    }
}
function Connect-Exchange {
    param(
        [Parameter(Position = 0, Mandatory = $true)] [string]$MailboxName,
        [Parameter(Position = 1, Mandatory = $true)] [System.Management.Automation.PSCredential]$Credentials,
        [Parameter(Position = 2, Mandatory = $false)] [string]$url
    )
    Begin {
        Load-EWSManagedAPI

        ## Set Exchange Version
        $ExchangeVersion = [Microsoft.Exchange.WebServices.Data.ExchangeVersion]::Exchange2010_SP2

        ## Create Exchange Service Object
        $service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService($ExchangeVersion)

        ## Set Credentials to use two options are availible Option1 to use explict credentials or Option 2 use the Default (logged On) credentials

        #Credentials Option 1 using UPN for the windows Account
        #$psCred = Get-Credential
        $creds = New-Object System.Net.NetworkCredential($Credentials.UserName.ToString(), $Credentials.GetNetworkCredential().password.ToString())
        $service.Credentials = $creds
        #Credentials Option 2
        #service.UseDefaultCredentials = $true
        #$service.TraceEnabled = $true

        Handle-SSL

        $uri=[system.URI] "https://outlook.office365.com/EWS/Exchange.asmx"
        $service.Url = $uri

        #$service.ImpersonatedUserId = new-object Microsoft.Exchange.WebServices.Data.ImpersonatedUserId([Microsoft.Exchange.WebServices.Data.ConnectingIdType]::SmtpAddress, $MailboxName)
        if (!$service.URL) {
            throw "Error connecting to EWS"
        }
        else {
            return $service
        }
    }
}
function Load-EWSManagedAPI {
    param(
    )
    Begin {
        $EWSDLL = (($(Get-ItemProperty -ErrorAction SilentlyContinue -Path Registry::$(Get-ChildItem -ErrorAction SilentlyContinue -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Exchange\Web Services'|Sort-Object Name -Descending| Select-Object -First 1 -ExpandProperty Name)).'Install Directory') + "Microsoft.Exchange.WebServices.dll")
        if (Test-Path $EWSDLL) {
            Import-Module $EWSDLL
        }
        else {
            "$(get-date -format yyyyMMddHHmmss):"
            "This script requires the EWS Managed API 2.2 or later."
            "Please download and install the current version of the EWS Managed API from"
            "http://go.microsoft.com/fwlink/?LinkId=255472"
            ""
            "Exiting Script."
            exit
        }
    }
}
function Handle-SSL {
    param(
    )
    Begin {
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
        $TAResults = $Provider.CompileAssemblyFromSource($Params, $TASource)
        $TAAssembly = $TAResults.CompiledAssembly
        $TrustAll = $TAAssembly.CreateInstance("Local.ToolkitExtensions.Net.CertificatePolicy.TrustAll")
        [System.Net.ServicePointManager]::CertificatePolicy = $TrustAll
    }
}
function FolderIdFromPath {
    param (
        $FolderPath = "$( throw 'Folder Path is a mandatory Parameter' )",
        $SmtpAddress = "$( throw 'Folder Path is a mandatory Parameter' )"
		  )
    process {
        $folderid = new-object Microsoft.Exchange.WebServices.Data.FolderId([Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::MsgFolderRoot, $SmtpAddress)
        $tfTargetFolder = [Microsoft.Exchange.WebServices.Data.Folder]::Bind($service, $folderid)
        $fldArray = $FolderPath.Split("\")
        for ($lint = 1; $lint -lt $fldArray.Length; $lint++) {
            $fvFolderView = new-object Microsoft.Exchange.WebServices.Data.FolderView(1)
            $SfSearchFilter = new-object Microsoft.Exchange.WebServices.Data.SearchFilter+IsEqualTo([Microsoft.Exchange.WebServices.Data.FolderSchema]::DisplayName, $fldArray[$lint])
            $findFolderResults = $service.FindFolders($tfTargetFolder.Id, $SfSearchFilter, $fvFolderView)
            if ($findFolderResults.TotalCount -gt 0) {
                foreach ($folder in $findFolderResults.Folders) {
                    $tfTargetFolder = $folder
                }
            }
            else {
                "Error Folder Not Found"
                $tfTargetFolder = $null
                break
            }
        }
        if ($tfTargetFolder -ne $null) {
            return $tfTargetFolder.Id.UniqueId.ToString()
        }
        else {
            throw "Folder not found"
        }
    }
}

$password = ConvertTo-SecureString "KeepItCleanKids!" -AsPlainText -Force

$Creds = New-Object System.Management.Automation.PSCredential ('repoman@SonyMusicEntertainment.onmicrosoft.com', $password)

Get-FolderItems -MailboxName 'repoman@SonyMusicEntertainment.onmicrosoft.com' -Credentials (Get-Credential $creds) -FolderPath '\Inbox'