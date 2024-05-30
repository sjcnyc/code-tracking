<#
.SYNOPSIS
    Retrieves the expiration information of Azure application certificates and secrets.

.DESCRIPTION
    The Get-MgApplicationCertificateAndSecretExpiration function retrieves the expiration information of Azure application certificates and secrets.
    It can filter the results based on various parameters such as showing only certificates or secrets, showing expired keys, and specifying the number of days within expiration.
    The function generates an HTML report and sends it via email along with a CSV file containing the detailed information.

.PARAMETER ShowOnlyCertificates
    If specified, only the certificates will be shown in the results.

.PARAMETER ShowOnlySecrets
    If specified, only the secrets will be shown in the results.

.PARAMETER ShowExpiredKeys
    If specified, expired keys will be included in the results.

.PARAMETER DaysWithinExpiration
    Specifies the number of days within expiration. Only the keys expiring within this number of days will be included in the results.
    The default value is 30.

.PARAMETER AppId
    Specifies the Application ID (Client ID) of the Azure application. If specified, only the application with the specified ID will be included in the results.

.OUTPUTS
    System.Management.Automation.PSCustomObject
    The function returns a custom object with the following properties:
    - AppDisplayName: The display name of the Azure application.
    - AppId: The Application ID (Client ID) of the Azure application.
    - Owner: The display name of the application owner(s).
    - KeyType: The type of the key (Certificate or ClientSecret).
    - ExpirationDate: The expiration date of the key.
    - DaysUntilExpiration: The number of days until the key expires.
    - Id: The ID of the Azure application.
    - KeyId: The ID of the key.
    - Description: The description of the key.
    - Status: The status of the key (Expired or Expiring soon).

.EXAMPLE
    Get-MgApplicationCertificateAndSecretExpiration -DaysWithinExpiration 30 -ShowExpiredKeys
    Retrieves the expiration information of Azure application certificates and secrets.
    Only the keys expiring within 30 days will be included in the results, including the expired keys.

.EXAMPLE
    Get-MgApplicationCertificateAndSecretExpiration -ShowOnlyCertificates
    Retrieves the expiration information of Azure application certificates only.

.EXAMPLE
    Get-MgApplicationCertificateAndSecretExpiration -ShowOnlySecrets -DaysWithinExpiration 15
    Retrieves the expiration information of Azure application secrets only.
    Only the secrets expiring within 15 days will be included in the results.

#>

$ClientSecretCredential = Get-Credential -Credential $secret:graphcreds

Connect-MgGraph -TenantId "f0aff3b7-91a5-4aae-af71-c63e1dda2049" -ClientSecretCredential $ClientSecretCredential -NoWelcome

Function Get-MgApplicationCertificateAndSecretExpiration {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(Mandatory = $false, ParameterSetName = 'CertOnly')]
        [switch]
        $ShowOnlyCertificates,

        [Parameter(Mandatory = $false, ParameterSetName = 'SecretOnly')]
        [switch]
        $ShowOnlySecrets,

        [Parameter(Mandatory = $false)]
        [switch]
        $ShowExpiredKeys,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 720)]
        [int]
        $DaysWithinExpiration = 30,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('ApplicationId', 'ClientId')]
        [string]
        $AppId
    )

    BEGIN {
        $ConnectionGraph = Get-MgContext
        if (-not $ConnectionGraph) {
            Write-Error "Please connect to Microsoft Graph" -ErrorAction Stop
        }
        $DaysWithinExpiration++
        $CheckDate = Get-Date
    }

    PROCESS {
        try {
            if ($PSBoundParameters.ContainsKey('AppId')) {
                $ApplicationList = Get-MgApplication -Filter "AppId eq '$AppId'" -ErrorAction Stop
                $AppFilter = $true
            } else {
                $ApplicationList = Get-MgApplication -All -Property AppId, DisplayName, PasswordCredentials, KeyCredentials, Id -PageSize 999 -ErrorAction Stop
            }

            #If certs are selected, show certs
            if ($PSBoundParameters.ContainsKey('ShowOnlyCertificates') -or

                #If neither Certs or Secrets are selected show both.
                   (-not $PSBoundParameters.ContainsKey('ShowOnlyCertificates') -and
                -not $PSBoundParameters.ContainsKey('ShowOnlySecrets'))) {

                $CertificateApps = $ApplicationList | Where-Object { $_.keyCredentials }

                $CertApp = foreach ($App in $CertificateApps) {
                    [array]$AppOwners = Get-MgApplicationOwner -ApplicationId $App.Id
                    if ($AppOwners) {
                        $AppOwnersOutput = $AppOwners.additionalProperties.displayName -join ", "
                    }
                    foreach ($Cert in $App.keyCredentials) {
                        $ExpirationDays = $null; $Status = $null
                        if ($null -ne $Cert.endDateTime) {

                            $ExpirationDays = (New-TimeSpan -Start $CheckDate -End $Cert.EndDateTime).Days

                            if ($ExpirationDays -lt 0) {
                                $Status = "Expired"
                            } elseif ($ExpirationDays -gt 0 -and $ExpirationDays -le $DaysWithinExpiration) {
                                $Status = "Expiring soon"
                            }
                        }
                        if ( $Cert.endDateTime -le (Get-Date).AddDays($DaysWithinExpiration) -or ($AppFilter) ) {
                            [PSCustomObject]@{
                                AppDisplayName      = $App.DisplayName
                                AppId               = $App.AppId
                                Owner               = $AppOwnersOutput
                                KeyType             = 'Certificate'
                                ExpirationDate      = $Cert.EndDateTime
                                DaysUntilExpiration = (($Cert.EndDateTime) - (Get-Date) | Select-Object -ExpandProperty TotalDays) -as [int]
                                Id                  = $App.Id
                                KeyId               = $Cert.KeyId
                                Description         = $Cert.DisplayName
                                Status              = $Status
                            }
                        }
                    }
                }

                if ($PSBoundParameters.ContainsKey('ShowExpiredKeys')) {
                    $CertApp | Sort-Object DaysUntilExpiration
                } else {
                    $CertApp | Sort-Object DaysUntilExpiration | Where-Object { $_.DaysUntilExpiration -ge 0 }
                }
            }

            #If secrets are selected, show secrets
            if ($PSBoundParameters.ContainsKey('ShowOnlySecrets') -or

                #If neither Certs or Secrets are selected show both.
                   (-not $PSBoundParameters.ContainsKey('ShowOnlySecrets') -and
                -not $PSBoundParameters.ContainsKey('ShowOnlyCertificates'))) {

                $ClientSecretApps = $ApplicationList | Where-Object { $_.passwordCredentials }

                $SecretApp = foreach ($App in $ClientSecretApps) {
                    [array]$AppOwners = Get-MgApplicationOwner -ApplicationId $App.Id
                    if ($AppOwners) {
                        $AppOwnersOutput = $AppOwners.additionalProperties.displayName -join ", "
                    }
                    foreach ($Secret in $App.PasswordCredentials) {
                        $ExpirationDays = $null; $Status = $null
                        if ($null -ne $Secret.EndDateTime) {
                            $ExpirationDays = (New-TimeSpan -Start $CheckDate -End $Secret.EndDateTime).Days
                            # Figure out app secret status based on the number of days until it expires
                            If ($ExpirationDays -lt 0) {
                                $Status = "Expired"
                            } elseif ($ExpirationDays -gt 0 -and $ExpirationDays -le $DaysWithinExpiration) {
                                $Status = "Expiring soon"
                            }
                        }
                        if ( $Secret.EndDateTime -le (Get-Date).AddDays($DaysWithinExpiration) -or ($AppFilter) ) {
                            [PSCustomObject]@{
                                AppDisplayName      = $App.DisplayName
                                AppId               = $App.AppId
                                Owner               = $AppOwnersOutput
                                KeyType             = 'ClientSecret'
                                ExpirationDate      = $Secret.EndDateTime
                                DaysUntilExpiration = (($Secret.EndDateTime) - (Get-Date) | Select-Object -ExpandProperty TotalDays) -as [int]
                                Id                  = $App.Id
                                KeyId               = $Secret.KeyId
                                Description         = $Secret.DisplayName
                                Status              = $Status
                            }
                        }
                    }
                }

                if ($PSBoundParameters.ContainsKey('ShowExpiredKeys')) {
                    $SecretApp | Sort-Object DaysUntilExpiration
                } else {
                    $SecretApp | Sort-Object DaysUntilExpiration | Where-Object { $_.DaysUntilExpiration -ge 0 }
                }
            }
        } catch {
            Write-Error $_.Exception.Message
        }
    }

    END {}
}

$Style1 =
'<style>
  body {color:#333333;font-family:Calibri,Tahoma,arial,verdana;font-size: 10pt;}
  h1 {text-align:center;}
  h2 {border-top:1px solid #E9E9E9;}
  h4 {font-size: 8pt;}
  table {border-collapse:collapse;}
  th {text-align:left;font-weight:bold;color:#FFFFFF;background-color:#2980B9;border:1px solid #2980B9;padding:4px;}
  td {padding:4px; border:1px solid #E9E9E9;}
  .odd { background-color:#F6F6F6; }
  .even { background-color:#E9E9E9; }
</style>'

$Date = (get-date -f yyyy-MM-dd)
$CSVFile = "c:\support\Temp\App_Secret_Cert_Report_$($Date).csv"

$Results = Get-MgApplicationCertificateAndSecretExpiration -DaysWithinExpiration 30 -ShowExpiredKeys

$count = $Results.Count
$Results | Export-Csv -Path $CSVFile -NoTypeInformation

$InfoBody = [pscustomobject]@{
  'Task:'      = "PSU Runbook - Tier-2"
  'Action:'    = "Azure Application Secret and Cert Report"
  "AVD Users:" = $Count
}

$HTML = New-HTMLHead -title "Azure Application Secret and Cert Report" -style $Style1
$HTML += New-HTMLTable -inputObject $(ConvertTo-PropertyValue -inputObject $InfoBody)
$HTML += "<h4>See Attached CSV Report</h4>"
$HTML += "<h4>Runbook Completed: $(Get-Date -Format G)</h4>" | Close-HTML

$EmailParams = @{
  to =        "sconnea@sonymusic.com" #, "brian.lynch@sonymusic.com", "suminder.singh.itopia@sonymusic.com"
  #To         = "sconnea@sonymusic.com"
  from       = 'PwSh Alerts pwshalerts@sonymusic.com'
  subject    = 'Azure Application Secret and Cert Report'
  smtpserver = 'cmailsony.servicemail24.de'
  Body       = ($HTML |Out-String)
  BodyAsHTML = $true
}

Send-MailMessage @EmailParams -Attachments $CSVFile 3>$null
Start-Sleep -Seconds 5
Remove-Item $CSVFile #| Export-Csv C:\Temp\expCertSecrets_30_days4.csv -notypeinformation