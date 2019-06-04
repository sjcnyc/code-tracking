#requires -Version 1
############## script start ##############

$CookieContainer = New-Object -TypeName System.Net.CookieContainer

function Send-GET
{
  param
  (
    [System.String]
    $url
  )

  [net.httpWebRequest] $req = [net.webRequest]::create($url)
  $req.Method = 'GET'
  $req.Accept = 'text/html'
  $req.CookieContainer = $CookieContainer
  [net.httpWebResponse] $res = $req.getResponse()
  $resst = $res.getResponseStream()
  $sr = New-Object -TypeName IO.StreamReader -ArgumentList ($resst)
  $result = $sr.ReadToEnd()
  return $result
}


function Send-POST
{
  param
  (
    [System.String]
    $url,

    [System.String]
    $data
  )

  $buffer = [text.encoding]::ascii.getbytes($data)
  [net.httpWebRequest] $req = [net.webRequest]::create($url)
  $req.method = 'POST'
  $req.ContentType = 'application/x-www-form-urlencoded'
  $req.ContentLength = $buffer.length
  $req.KeepAlive = $true
  $req.CookieContainer = $CookieContainer
  $reqst = $req.getRequestStream()
  $reqst.write($buffer, 0, $buffer.length)
  $reqst.flush()
  $reqst.close()
  [net.httpWebResponse] $res = $req.getResponse()
  $resst = $res.getResponseStream()
  $sr = New-Object -TypeName IO.StreamReader -ArgumentList ($resst)
  $result = $sr.ReadToEnd()
  $res.close()
  return $result
}


# Request to get session id
$x = SendGET ('http://102.169.34.63/properties/authentication/login.php')
# Post login to get new session id
$x = SendPOST ('http://102.169.34.63/userpost/xerox.set') ('_fun_function=HTTP_Authenticate_fn&NextPage=%2Fproperties%2Fauthentication%2FluidLogin.php&webUsername=admin&webPassword=1111&frmaltDomain=default')

# Post reboot command with loggedin session id
$x = SendPOST ('http://102.169.34.63/userpost/xerox.set') ('_fun_function=HTTP_Machine_Reset_fn&NextPage=/status/rebooted.php')

############## script end ##############