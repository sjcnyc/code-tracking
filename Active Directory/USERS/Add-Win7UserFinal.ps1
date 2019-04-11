
Clear-Host

Function Add-Win7user {
  [cmdletBinding(SupportsShouldProcess=$True)]
param (
  [Parameter(Mandatory=$true)][string]$user)

begin{} 
process {
    try {
         $output = get-qaduser $user -IncludeAllProperties
         $loc = $output.DN.Split(',')[-4] 
         $usr = $output.DN.Split(',')[-7]
         $group =@('USA-GBL New Logon Script','USA-GBL MapO Logon Isilon Outlook','USA-GBL MapS Logon Isilon Data')

        if ($loc -eq 'OU=USA') { write-host "User: $user is in: $loc,$usr" }
            else {           
                  write-host "Moving $user to: OU=USA,$usr" -NoNew
                  Move-QADObject -I $user -NewParentContainer "$usr,ou=usr,ou=gbl,ou=usa,dc=bmg,dc=bagint,dc=com" | out-null
                  1..(50 - ($loc.length + $usr.length +1)) | % { write-host '.' -Fore Cyan -NoNew;Start-Sleep -M .5;}
                  Write-Host '[ OK ]' -Fore Cyan 
                  }

         foreach ($grp in $group) {
            isMember $user
            } 

    } catch {$_.exception.message;continue}
  } 
end{}
} 


function isMember ($user){

    if (Get-QADUser $user | Get-QADMemberOf | % {$f=$_;$f} | Where-Object { $f.name -eq $grp}){ write-host "User: $user is member of: " $grp }
    else {
          write-host "Adding $user to:" $grp -NoNew; Add-QADGroupMember -I $grp -Member $user | out-null
         1..(50 - $grp.Length) | % { write-host '.' -Fore Cyan -NoNew;Start-Sleep -M .5;}
        Write-Host '[ OK ]' -Fore Cyan 
        }
}


Add-Win7user sconnea