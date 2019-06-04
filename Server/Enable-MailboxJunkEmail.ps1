#requires -Version 1
# Author: Jon Webster
# Name: Enable-MailboxJunkEmail
# Created: 1/27/2009
#
# Version: 1.0
# History: 1.0 01/27/2009 Initial version
#
# 18.11.2010	BRF		Update for Microsoft Exchange SP3, Cookie Canary

param(
  $Identity,
  [string]$CasURL,
  [string]$User,
  [string]$Password,
  $DomainController,
  [switch]$help
)
	
BEGIN
{
  Function Usage
  {
    Write-Host -Object @'
Enable Server Side Junk E-mail filtering through Outlook Web Access
`n
Usage:
	Enable-MailboxJunkEmail -Identity <string> -CasURL <string> -User <string> -Password <string> -DomainController <string>
`n
Parameters:
	Identity: The Identity of mailbox who's server side Junk E-mail you want to enable.
	CasURL: The (OWA) Client Access Server Address of the exchange server you want to use.
	User: The fullaccess user's 'username' connecting to the mailbox that you want to change.
	Password: The fullaccess user's 'password' connecting to the mailbox that you want to change.
	DomainController: The fully qualified domain name (FQDN) of the domain controller that you want to use.
`n
Example:
	Enable-MailboxJunkEmail -Identity "john.doe@consoto.com" -CasURL "mail.consoto.com" -User "CONSOTO\Administrator" -Password "AdminPassword!"
'@
  }
	
  if($help -or $args -contains '-?')
  {
    Usage
    return
  }
	
  Function ValidateParams
  {
    # These required parameters are not passed via pipeline
    # $Identity
    $ErrorMessage = ''

    if(!$CasURL) {$ErrorMessage += "Missing parameter: The -CasURL parameter is required. Please pass a valid Client Access Server Url`n"}

    if(!$User) {$ErrorMessage += "Missing parameter: The -User parameter is required. Please pass a valid Username for OWA mailbox authentication`n"}

    if(!$Password) {$ErrorMessage += "Missing parameter: The -Password parameter is required. Please pass a valid password for OWA mailbox authentication`n"}

    if($ErrorMessage)
    {
      throw $ErrorMessage
      break
    }
  }

  Function ValidatePipeline
  {
    if($_)
    {
      $ErrorMessage = ''
      if(!$_.Identity)
      {$ErrorMessage += 'Missing Pipeline property: The Identity property is required.'} else {Set-Variable -Name Identity -Scope 1 -Value $_.Identity}

      if($ErrorMessage)
      {
        throw $ErrorMessage
        break
      }
    }
  }

  Function UpdateJunk
  {
    param ([string]$mbMailbox,
    [string]$CanaryNumber)

    Write-Debug -Message $mbMailbox
    Write-Debug -Message $CanaryNumber

    $xmlstr = '<params><canary>' + $CanaryNumber + '</canary><fEnbl>1</fEnbl></params>'	#Zwingend für SP3
    #$xmlstr = "<params><fEnbl>1</fEnbl></params>"	# Bei SP2 noch gültig
    Write-Debug -Message $xmlstr

    $req.Open('POST', 'http://' + $CasURL + '/owa/' + $mbMailbox + '/ev.owa?oeh=1&ns=JunkEmail&ev=Enable', $False)
    $req.setRequestHeader('Content-Type', 'text/xml; charset=""UTF-8""')
    $req.setRequestHeader('Content-Length', $xmlstr.Length)
    $req.Send($xmlstr)

    Write-Debug -Message $req.status
    Write-Debug -Message $req.GetAllResponseHeaders()

    if($req.status -ne 200)
    {
      Write-Error -Message $req.responsetext
      return
    }

    if($req.responsetext -match 'name=lngFrm')
    {
      Write-Host -Object 'Mailbox has not been logged onto before via OWA'

      $pattern = '<option selected value=""(.*?)"">'
      $matches = [regex]::Matches($req.responsetext,$pattern)
      if($matches.count -eq 2)
      {
        $lcidarry = $matches[0].Groups[1].Value
        Write-Debug -Message $lcidarry
        $tzidarry = $matches[1].Groups[1].Value
        Write-Debug -Message $tzidarry
        $pstring = 'lcid=' + $lcidarry + '&tzid=' + $tzidarry
        $req.Open('POST', 'http://' + $CasURL + '/owa/' + $mbMailbox + '/lang.owa', $False)
        $req.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
        $req.setRequestHeader('Content-Length', $pstring.Length)
        # not required?
        #$req.setRequestHeader("cookie", $reqCadata) # Error here
        $req.send($pstring)
        if($req.responsetext -match 'errMsg')
        {
          # Permission Error
          Write-Error -Message 'Authentication Error'
        } else {
          Write-Debug -Message $req.status
          if($req.status -eq 200 -and $req.responsetext -notmatch 'errMsg')
          { 
            Write-Host -Object 'Trying to update the Junk E-mail setting again.'
            UpdateJunk($mbMailbox)
            Write-Host -Object 'Removing OWA Language and Timezone settings...'

            &{
              # We'll get a warning if no properties were modified.
              # That warning means replication hasn't occurred yet.
              $warningPreference = 'Stop'
              $script:count = 0
              $loop = $true
              while($loop)
              {
                $loop = $False
                # Set-Mailbox $mbMailbox -Languages $null -DomainController $DomainController
                trap {
                  if($script:count -lt 5)
                  {
                    # Try for up to 20 seconds
                    Write-Debug -Message 'Unable to Reset Languages trying again in 5 seconds.'
                    Start-Sleep -Seconds 5
                    Set-Variable -Name loop -Scope 1 -Value $true
                    $script:count++
                  } else { Write-Debug -Message 'Failed.' }
                  continue
                }
              }
              $warningPreference = 'Continue'
            }
          } else {Write-Warning -Message 'Failed to set Default OWA settings'}
        }
      } else {Write-Warning -Message 'Script failed to retrieve default values'}
      Write-Host -Object 'Junk E-Mail setting Changed Successfully'
    }
  }
  ValidateParams
}
PROCESS
{
  ValidatePipeline

  # $mbx = Get-Mailbox -Identity $Identity -DomainController $DomainController -ErrorAction SilentlyContinue
  # if(!$mbx) {throw "Invalid Mailbox specified: $Identity"}

  $szXml = 'destination=http://' + $CasURL + '/owa/&flags=0&username=' + $User
  $szXml = $szXml + '&password=' + $Password + '&SubmitCreds=Log On&forcedownlevel=0&trusted=0'

  $req = New-Object -ComObject 'MSXML2.ServerXMLHTTP.6.0'
  $req.Open('POST', 'http://' + $CasURL + '/owa/auth/owaauth.dll', $False)
  $req.SetOption(2, 13056)
  $req.Send($szXml)

  Write-Debug -Message $req.GetAllResponseHeaders()
  if($req.responsetext -match 'wrng')
  {
    Write-Error -Message 'The user name or password that you entered is not valid. Try entering it again.'
    return
  }
	
  #Modifikation für Exchange SP3 Canary muss ermittelt werden
  $req.Open('GET', 'http://' + $CasURL + '/owa/sean.connealy.peak@sonymusic.com' +'', $False)
  $req.SetOption(2, 13056)
  $req.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
  $req.setRequestHeader('Content-Length', '133')
  $req.Send($szXml)
  Write-Debug -Message $req.GetAllResponseHeaders()

  $cookie = $req.GetResponseHeader('Set-Cookie')
  Write-Debug -Message $cookie
  
  $slen = $cookie.IndexOf('=')+1
  $elen = $cookie.IndexOf('&')
  $canary = $cookie.Substring($slen,$elen-$slen)
  Write-Debug -Message "CANARY: $canary"
  #Modifikation
	
  UpdateJunk -mbMailbox 'sean.connealy.peak@sonymusic.com' -CanaryNumber $canary
}

#Enable-MailboxJunkEmail -Identity "sean.connealy.peak@sonymusic.com" -CasURL "NYCMNET7CT001" -User "BMG\sconnea" -Password "Avatar5522"