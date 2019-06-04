Add-PSSnapin Quest.ActiveRoles.ADManagement

Function Add-Win7user {
  param (
  [Parameter(Mandatory=$true)][string]$user)

  begin{} 
  process {
    try {
         $output = get-qaduser $user -IncludeAllProperties
         $u  = $output | % { $_.DN.Split(',')[-8] } 
         $ou = $output | % { $_.DN.Split(',')[-4] }
         $usr= $output | % { $_.DN.Split(',')[-7] }
         $grp= $output | % { $_.memberof }
         
         if ($ou -ne 'OU=USA') {             
            write-host "Moving $user to: CN=$user,$usr,OU=USR,OU=GBL,OU=USA,DC=bmg,DC=bagint,DC=com" 
            Move-QADObject -Identity $user -NewParentContainer "$usr,ou=usr,ou=gbl,ou=usa,dc=bmg,dc=bagint,dc=com" | out-null
             } 
         else {
            write-host "User: $user in"$ou 
            }           
         if (!$grp -eq 'CN=USA-GBL New Logon Script'){
             write-host "Adding $user to: USA-GBL New Logon Script"
             add-QADGroupMember -identity 'USA-GBL New Logon Script' -member $user | out-null
             }
             if (!$grp -eq 'CN=USA-GBL MapO Logon Isilon Outlook') {
                      write-host "Adding $user to: USA-GBL MapO Logon Isilon Outlook"
                      add-QADGroupMember -identity 'USA-GBL MapO Logon Isilon Outlook' -member $user | out-null
                      }
             if (!$grp -eq 'CN=USA-GBL MapS Logon Isilon Data') {
                      write-host "Adding $user to: USA-GBL MapS Logon Isilon Data"
                      add-QADGroupMember -identity 'USA-GBL MapS Logon Isilon Data' -member $user | out-null
                      write-host ''
                      } 
          else {            
            write-host "User: $user is in the correct groups"
            }
            
    } catch {$_.exception.message;continue}
  }
  
  end{}
}