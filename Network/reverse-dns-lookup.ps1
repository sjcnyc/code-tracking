# reverse dns lookup

 $dns = "Cookham1"  
 $records = get-wmiobject -class MicrosoftDNS_PTRType -namespace root\MicrosoftDNS -computer $dns  
  
 "Computers reverse registered on DNS Server: $DNS" 
  
 # Loop through and display results 
 foreach ($record in $records) { 
  
 # Get owner name and ip address string 
 $on = $record.ownerName.split(".") 
 $ownerip = $on[3] + "." + $on[2] + "." + $on[1] + "." + $on[0] 
  
 # Display details 
 "{0, -15} {1,-40}  {2,-10} " -f $ownerip, $record.ptrdomainname, $record.timestamp 
 }  