function Get-ShareConnection {
    param ( 
        [Parameter(Position=0, Mandatory=$true,HelpMessage='Please enter a server name')] 
        [string] $Server = '',
        [Parameter(Position=1,Mandatory=$false)] 
        [alias('share')]
        [string] $sharename = 'all'
     ) 

process {
    $serverconnection = Get-WmiObject -ComputerName $Server -Class Win32_SessionConnection

    $users = @()
    foreach ($connection in $serverconnection){
        $conn = '' | Select-Object 'ip','user','share'
        $split = $connection.Dependent.split(',')
        $conn.ip = $split[0].replace('Win32_ServerConnection.computername=','').replace('"','')
        $conn.user = $split[2].replace('UserName=','').replace('"','')
        $conn.share = $split[1].replace('sharename=','').replace('"','')
        if ($sharename -eq 'all'){$users += $conn}
        else{if ($conn.share -eq $sharename){$users += $conn}}
    }
    return $users
}

}

get-shareConnection -Server usnaspwfs01 -sharename HOME$