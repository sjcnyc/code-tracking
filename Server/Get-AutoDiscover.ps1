function Get-AutoDiscover {
  <#
    .SYNOPSIS
    Retrieves the Autodiscover response for a given user

    .DESCRIPTION
    Retrieves the Autodiscover response for a given user

    .PARAMETER EmailAddress
    Email Address of User 

    .PARAMETER Server
    Exchange Server

    .PARAMETER Credentials
    Admin credintials

    .EXAMPLE
    Get-AutoDiscover -EmailAddress sconnea@sonymusic.com -Credentials $cred -Server NYCMNET7EV001.mnet.biz

    .NOTES
    File Name  : Get-AutoDiscover
    Author     : Sean Connealy
    Requires   : PowerShell Version 3.0 
    Date       : 10/30/2014

    .LINK
    This script posted to: http://www.github/sjcnyc

    .INPUTS


    .OUTPUTS

  #>
  
  Param (
    [parameter( Mandatory=$true, ValueFromPipelineByPropertyName=$false)]
    [String]$EmailAddress,
    [parameter( Mandatory=$false, ValueFromPipelineByPropertyName=$false)]
    [String]$Server,
    [parameter( Mandatory=$false, ValueFromPipelineByPropertyName=$false)]
    [System.Management.Automation.PsCredential]$Credentials
  )
  try {
    # check for PS version
    If ((Get-Host).Version.Major -lt 3) {
      Write-Warning 'Sorry not supported! Need PS 3.0!'
      Break
    }
    $AS = '<?xml version="1.0" encoding="utf-8"?>
      <Autodiscover xmlns="http://schemas.microsoft.com/exchange/autodiscover/outlook/requestschema/2006">
      <Request>
    <EMailAddress>'
    $AS += $EmailAddress
    $AS += '</EMailAddress>
      <AcceptableResponseSchema>http://schemas.microsoft.com/exchange/autodiscover/outlook/responseschema/2006a</AcceptableResponseSchema>
      </Request>
      </Autodiscover>
    '
    If (!$Server) {
      Write-Host -fore yellow 'No server specified! Will try to figure out!'
      $Domain = $EmailAddress.Split('@')[1]
      $Server = 'autodiscover.' + $Domain
      $URL = "https://$server/autodiscover/autodiscover.xml"
    }
    Else {
      $url = "https://$server/autodiscover/autodiscover.xml"
    }
    If (!$Credentials) {
      Write-Host -fore yellow 'Using default credentials!'
      [XML]$ASResponse = Invoke-WebRequest -Uri $URL -Method POST -Body $AS -ContentType 'text/xml'  -UseDefaultCredentials
    }
    Else {
      Write-Host -fore Yellow "Using given credentials $($Credentials.Username)"
      [XML]$ASResponse = Invoke-WebRequest -Uri $URL -Method POST -Body $AS -ContentType 'text/xml'  -Credential $Credentials
    }
    $Root = $ASResponse.Get_DocumentElement()
    If ($($Root.GetElementsByTagName('Error'))) {
      Write-Host -fore red "Error occured:$($Root.GetElementsByTagName('Error').message)"
    }
    Else {
      $Root.Response.Account.Protocol
    }
  }
  Catch {
    Write-Host -fore red $_.Exception.Message
  }
}