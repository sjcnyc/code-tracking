 
 # range  
 [string]$IP = "10.12.114"
 # start  
 [int]$sRange = 1
 # end  
 [int]$eRange = 10  
 
 $MaxIPs = 10  
  
 # start jobs  
 $count = 1  
 $sRange..$eRange | %{    
         start-job -ArgumentList "$IP`.$_" -scriptblock { $test = test-connection $args[0] -count 2 -quiet; return $args[0],$test } | out-null    
         if ($count -gt $MaxIPs) {  
             $count = 1  
         } else {  
            $count++  
         }  
     }  
   
 get-job | wait-job  
   
   # push to array  
   $jobs = get-job  
   # hash results  
   $results = @()  
   foreach ($job in $jobs) {   
       $temp = receive-job -id $job.id -keep  
      $results += ,($temp[0],$temp[1])  
   }  
      
   get-job | stop-job  
   get-job | remove-job  
    
   foreach ($result in $results) {  
      if ($result[1]) {  
           write-host -f Green "$($result[0]) is responding"  
       } else {  
          write-host -f Red "$($result[0]) is not responding"  
       }  
   } 
