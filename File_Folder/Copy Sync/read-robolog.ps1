
Function Read-RoboLog {

Param(
	[string]$files
	)

$pat1 = $null
$pat2 = $null
$pat3 = $null
$pat4 = $null
$pattern1 = $null  
$pattern2 = $null  
$pattern3 = $null  
$pattern4 = $null 
$output=@() 
foreach ($file in $files)  
    {  
    $output = "Working on : $($file)`n`n"  
    $pat1 = select-string $file -pattern ' Started : '
    $pat1 = $pat1.ToString().Replace($file, '')
    $output += "$($pat1.Remove(0,5))`n"

    $pat2 = select-string $file -pattern 'Source : '
    $pat2 = $pat2.ToString().Replace($file, '')
    $output += "$($pat2.Remove(0,6))`n"     
    $pat3 = select-string $file -pattern 'Dest : '
    $pat3 = $pat3.ToString().Replace($file, '')
    $output += "$($pat3.Remove(0,8))`n`n"
    
    $pattern1 = select-string $file -pattern 'Files :  '  
    $pattern1 = $pattern1.tostring() -replace '\s+', ' '  
    $pattern2 = $pattern1.tostring().split(' ')  
    $output += "Total files on source:`t $($pattern2[3])`n"  
    $output += "Total files copied:`t`t $($pattern2[4])`n"  
    $output += "Total files skipped:`t $($pattern2[5])`n"  
    $output += "Total files failed:`t`t $($pattern2[7])`n"  
    $pattern3 = select-string $file -pattern 'Bytes : '  
    $pattern3 = $pattern3.tostring() -replace ' 0 ', ' 0 m '  
    $pattern3 = $pattern3.tostring() -replace '\s+', ' '  
    $pattern4 = $pattern3.tostring().split(' ')  
    $output += "Total bytes on source:`t $($pattern4[3] + "`t" + $pattern4[4])`n"  
    $output += "Total bytes copied:`t`t $($pattern4[5] + "`t" + $pattern4[6])`n"  
    $output += "Total bytes skipped:`t $($pattern4[7] + "`t" + $pattern4[8])`n"  
    $output += "Total bytes failed:`t`t $($pattern4[11] + "`t" + $pattern4[12])`n`n"  
    $error1 = select-string $file -pattern '0x00000002'  
    $output += "File not found error :$($error1.count)`n"  
    $error2 = select-string $file -pattern '0x00000003'  
    $output += "File not found errors :$($error2.count)`n"  
    $error3 = select-string $file -pattern '0x00000005'  
    $output += "Access denied errors :$($error3.count)`n"  
    $error4 = select-string $file -pattern '0x00000006'  
    $output += "Invalid handle errors :$($error4.count)`n"  
    $error5 = select-string $file -pattern '0x00000020'  
    $output += "File locked errors :$($error5.count)`n"  
    $error6 = select-string $file -pattern '0x00000035'  
    $output += "Network path not found errors :$($error6.count)`n"  
    $error7 = select-string $file -pattern '0x00000040'  
    $output += "Network name unavailable errors :$($error7.count)`n"              
    $error8 = select-string $file -pattern '0x00000070'  
    $output += "Disk full errors :$($error8.count)`n"  
    $error9 = select-string $file -pattern '0x00000079'  
    $output += "Semaphore timeout errors :$($error9.count)`n"  
    $error10 = select-string $file -pattern '0x00000033'  
    $output += "Network path errors :$($error10.count)`n"  
    $error11 = select-string $file -pattern '0x0000003a'  
    $output += "NTFS security errors :$($error11.count)`n"         
    $error12 = select-string $file -pattern '0x0000054f'  
    $output += "Internal errors :$($error12.count)`n`n"  
    $pat4 = select-string $file -pattern 'Ended : '
    $pat4= $pat4.ToString().Replace($file, '')
    $output += "$($pat4.Remove(0,9))`n"
    #sendmail
    $output   
    }
} 

function sendmail{
send-mailmessage -from sconnea@sonymusic.com -to sconnea@sonymusic.com -subject test -body $output -priority High -smtpServer 'cmailsony.servicemail24.de'
} 