Function Install-Software            
{            
    PARAM(            
         $File,            
         $Arguments                     
         )            
            
$Install = Start-Process $File -ArgumentList $Arguments -Wait -PassThru           
            
 if ($Install.ExitCode -eq 0){ 
    write-host 'Installation was OK' -fore Green }            
 else { write-host "Installation failed $("$Install.ExitCode")" -fore Red            
    }            
}

Install-Software -file 'C:\foobar.exe' -Arguments '/f /o /b /r path="c:\foobar"'