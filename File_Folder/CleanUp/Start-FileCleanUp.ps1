# File cleanup script 
#mjolinor 5/10/2010 
 
# Notes 
# "filespec" is the full path and file spec of the files to process. 
# "retain" is how long to keep files before they are considered "old" and eligible for deletion. 
# "diskspace" is the maximum amount of disk space the log files are expected to consume. 
# "enforce" determines whether files newer than the minium age will be deleted in order to enforce the diskspace limit. 
# "deleteby" is the file date property (CreationTime, LastWriteTime, or LastAccessTime) used for ageing.  
# "keepevents" is a switch that determines if a detail log is kept. 
# "mailto" is the recipient address alert emails will be sent to. 
 
# To run as a scheduled task, use the -batch switch.  
# This will silently run all job configs in the script directory. 
#Use the -job_dir parameter to specify an alternate directory where the job config files are located (default is ./). 
 
#events logged in the application event log 
# Event 10120 - Script started. 
# Event 10121 - Job started. 
# Event 10123 - Job ended. 
# Event 10125 - Script ended. 
 
param ([switch]$batch,$job_dir = './') 
 
$mailhost = '<smtp mail host>' 
$admin_email = '<administrator email address>' 
 
 
$cmdline = [Environment]::commandline 
$script_started = get-date 
 
 
 
#Create event log source if it doesn't already exist 
if(![System.Diagnostics.EventLog]::SourceExists('file_cleanup')){[system.diagnostics.eventlog]::createeventsource('file_cleanup','Application')} 
$app_log = new-object system.diagnostics.eventlog ('Application','.') 
$app_log.source = 'file_cleanup' 
 
#Job config parameter list 
 
$job_props = @('Filespec','Retain','DiskSpace','Enforce','DeleteBy','KeepEvents','MailTo') 
 
# Config parameter validations and sanity checks 
 
$filespec_valid = {test-path $job.filespec} 
$retain_valid = {[int]$job.retain -ge 3 -and [int]$job.retain -le 400} 
$diskspace_valid = {[int]$job.diskspace -ge 5 -and [int]$job.diskspace -le 10000} 
$enforce_valid = {$job.enforce -match "^(true|false)$"} 
$deleteby_valid = {$job.deleteby -match "^(CreationTime|LastWriteTime|LastAccessTime)$"}  
$keepevents_valid = {$job.keepevents -match "^(true|false)$"} 
$mailto_valid =  {($job.mailto -match '\w+\@\w+\.\w+') -or ($job.mailto -eq 'NoEmail')} 
 
function to-kmg { 
  param ($bytes,$precision='1') 
  foreach ($i in ('Bytes','KB','MB','GB','TB')) { 
    if (($bytes -lt 1000) -or ($i -eq 'TB')){ 
      $bytes = ($bytes).tostring('F0' + "$precision") 
      return $bytes + " $i" 
    } 
    else {$bytes /= 1KB} 
  } 
} 
 
#Set config parameters 
 
$set_filespec = {while (-not (&$filespec_valid)){ 
    $job.filespec = read-host "`nEnter filespec (eg "c:\logfiles\*.log" or UNC)" 
    Write-Host "`nTesting FileSpec" 
    if (-not (Test-Path $filespec)){Write-Host "Test-path failed. Valid path required.`n"} 
  } 
  Write-Host 'Test-path success.' 
  write-host "`nOption FileSpec = $($job.filespec)" 
  $job.filespec 
} 
              
$set_retain = { while (-not (&$retain_valid)){ 
    $job.retain = read-host "`nEnter days to retain files. (3-999)" 
  } 
  write-host "`nOption Retain = $($job.retain)" 
  $job.retain 
} 
                 
$set_diskspace = {while (-not (&$diskspace_valid)){ 
    $job.diskspace = read-host "`nEnter disk space limit, in MB (5-9999)" 
  } 
  write-host "`nOption DiskSpace = $($job.diskspace)" 
  $job.diskspace 
} 
                
$set_enforce = {While ($select_enforce -notmatch 'y|n'){ 
    $select_enforce = read-host "`nEnforce disk space limit? (y/n)" 
  } 
  if ($select_enforce -match 'y'){$job.enforce = 'True'} 
  else {$job.enforce = 'False'} 
  write-host "`nOption Enforce = $($job.enforce)" 
  $job.enforce 
} 
                 
$set_keepevents = {While ($keepevents -notmatch 'y|n'){ 
    $keepevents = read-host "`nKeep event history file? (y/n)" 
  } 
  if ($keepevents -match 'y'){$job.keepevents  = 'True'} 
  else {$job.keepevents = 'False'} 
  write-host "`nOption KeepEvents = $($job.keepevents)" 
  $job.keepevents 
} 
 
$set_deleteby = {While ($deleteby_selection -notmatch "^(C|W|A)$"){ 
    $deleteby_selection = read-host "`nDelete by:`nC - CreationTime`nW - LastWriteTime`nA - LastAccessTime`nSelect" 
    switch ($deleteby_selection) { 
      'C' {$job.deleteby = 'CreationTime'} 
      'A' {$job.deleteby = 'LastAccessTime'} 
      'W' {$job.deleteby = 'LastWriteTime'} 
    } 
  } 
  Write-host "`nOption DeleteBy = $($job.deleteby)" 
  $job.deleteby 
} 
                 
$set_mailto = {while (($mailto -ne 'N') -and -not (&$mailto_valid)){ 
    $mailto = read-host "`nNotification email recipient (email address), N for no email." 
    if ($mailto -eq 'N'){$job.mailto = 'Noemail'} 
    else{$job.mailto = $mailto} 
    Write-host "`nOption MailTo = $($job.mailto)" 
  }  
  $job.mailto 
} 
             
#Script blocks 
 
$get_jobs = {Get-ChildItem job_*.xml} 
             
$check_cfg = {foreach ($prop in $job_props){ 
    if (Invoke-Expression ('&$' + $prop + '_valid')){$passed += 1} 
  } 
  if ($passed -eq $job_props.count){$true} 
  else {return $false} 
} 
 
$select_cfg = { 
  write-host "`nSelect job  (1 - $($jobcfgs.count))`n" 
  $valid_selections = @() 
  $i=1 
  foreach($jobcfg in $jobcfgs){ 
    $jobcfg -match 'job_(.+)\.xml' >$nul 
    $jobname = $matches[1] 
    $valid_selections += $i.tostring() 
    write-host $($i.tostring() + ' ' + $jobname) 
    $i++ 
  } 
  while ($valid_selections -notcontains $selection) {$selection = read-host "`nSelect job"} 
  Write-Host "Selected job $($selection) $($jobcfgs[$($selection - 1)])" 
  $job = import-clixml $jobcfgs[$selection - 1] 
  $job | Add-Member -MemberType NoteProperty -Name filename -Value $jobcfg 
  return $job 
}     
 
$create_cfg = { 
  Clear-Host 
  $jobcfg_name = read-host "`nEnter job name (config file name)" 
  $job = '' | Select-Object $job_props 
  $job_props |%{Invoke-Expression ('$job.' + $_ + ' = &$set_' + $_)} 
  $newjob_cfg = 'job_' + $jobcfg_name + '.xml' 
  $job | export-clixml $newjob_cfg  
  $job 
} 
  
$delete_cfg = { 
  Write-Host "`n Deleting job $($job.filename)" 
  Remove-Item $job.filename  
} 
   
$list_cfg = { 
  Write-Host "`nJob settings: `n"  
  $job_props |% {Write-host "$($_) `= $($job.$_)"}  
} 
 
$edit_cfg = { 
  $i=1 
  Write-Host "`n" 
  $job_props |% {Write-Host "$i $_ $($job.$_)";$i++} 
  $selection = read-Host "`nSelect property to edit (1 - $($job_props.count))`nD if done`nSelect" 
  if ($selection -match 'd'){ 
    &$select_maint 
  } 
  else { 
    if($job_props[$selection -1]){ 
      $sel_prop = $job_props[$selection -1] 
      $job.$sel_prop = '' 
      $job.$sel_prop = Invoke-Expression $('&$set_' + $job_props[$selection -1];$job.$job_props[$selection -1]) 
      $job  | Select-Object $job_props | Export-Clixml $job.filename 
      &$edit_cfg 
    } 
  } 
} 
      
$select_maint = { 
  Write-Host "`nSelect maintenance" 
  $maint = '' 
  while ($maint -notmatch '[c|e|d|s|w|r|x]'){ 
    $maint = read-host "c -create`ne -edit`nd -delete`ns -show`nw -whatif`nr -run`nx -exit`n" 
  } 
  $jobcfgs = @(&$get_jobs) 
  switch ($maint) { 
    'c' {&$create_cfg} 
    'e' {$job = &$select_cfg;&$edit_cfg;} 
    'd' {$job = &$select_cfg;&$delete_cfg} 
    's' {$job = &$select_cfg;&$list_cfg} 
    'w' {$job = &$select_cfg;&$whatif_run} 
    'r' {$job = &$select_cfg;&$run_job} 
    'x' {write-host 'Exiting';exit}  
  } 
  &$select_maint 
} 
  
$send_email = { 
  $subj = "File cleanup on $($env:computername)" 
  $SmtpClient = new-object system.net.mail.smtpClient  
  $SmtpClient.Host = $mailhost 
  $mailmessage = New-Object system.net.mail.mailmessage  
  $mailmessage.from = $admin_email  
  $mailmessage.To.add($mailto) 
  $mailmessage.Subject = $subj 
  $mailmessage.Body = $events 
  $smtpclient.Send($mailmessage) 
  if (!($?)) {$app_log.writeentry("Email notification failed. Check relay $($mailhost).",'Error',10123)}  
} 
 
 
$whatif_run = { 
  write-host "`n ***Whatif***`n" 
  if (&$check_cfg){ 
    $ret_max = [int]$job.diskspace * 1MB 
    $ret_min_date = $(get-date).adddays(-$job.retain) 
    Write-Host "Retention date is $($ret_min_date)" 
    $deleteby = $job.deleteby 
    
    if (test-path $job.filespec){ 
      $dir = Get-ChildItem $job.filespec | Sort-Object $deleteby 
      $start_stats = $dir | Measure-Object -Property length -Sum 
      $start_size = $start_stats.sum 
      write-host "`nFound $($dir.count) files totaling  $(to-kmg $start_size) matching filespec $($job.filespec). `n" 
      
      $old_files = $dir |Where-Object {$_.$deleteby -lt $ret_min_date} 
      
      if ($old_files.count){ 
        $old_file_stats = $old_files | Measure-Object -Property length -Sum 
        $old_size = $old_file_stats.sum 
        write-host "Found $($old_files.count) files totaling $(to-kmg $old_size) that would be deleted by age. `n" 
        $result_count = $dir.count - $old_files.count 
        $result_size = $start_size - $old_size 
        write-host "There would be $($result_count) files totaling $(to-kmg $result_size) left after deletion of old files. `n" 
        if ($ret_max -lt $result_size){ 
          
          $over_limit = $result_size - $ret_max 
          write-host  "Directory would be $(to-kmg $over_limit) over the specified disk quota after cleanup of old files. `n" 
          
          if ($job.enforce){ 
            $enforced_deletes = @() 
            $result_dir = Get-ChildItem $job.filespec |Where-Object {$_.$deleteby -ge $ret_min_date} | Sort-Object $deleteby  
            $i = 0 
            while ($ret_max -lt $result_size){ 
              $result_size -= $result_dir[$i].length 
              $enforced_deletes += $result_dir[$i].fullname 
              $i++ 
            } 
            write-host "There would be $i files from $($job.filespec) deleted that were within the`n retention window in order to enforce configured disk quota of $($job.diskspace) MB `n" 
            $last_ret = $result_dir[$i].$deleteby 
            $ret_depth = ((Get-Date) - $last_ret).days 
            Write-Host "Retention history depth would be reduced from $($job.retain) to $($ret_depth) days.`n`n" 
          } #end if enforce 
        }   
      }  
      
      While ($show_detail -notmatch 'y|n'){$show_detail = read-host 'Show detail? (y/n)'} 
      if ($show_detail -match 'y'){ 
        
        foreach ($file in $dir){ 
          if ($old_files -contains $file){write-host "$($file.name) `t  would be deleted by age.`t $deleteby `t $($file.$deleteby)"} 
          else {if ($enforced_deletes -contains $file.fullname){write-host "$($file.name) `t would be deleted to enforce disk quota.`t $deleteby `t $($file.$deleteby)"} 
          else {write-host "$($file.name) `t would be retained. `t $deleteby `t $($file.$deleteby)"}} 
        }   
      }  
    } 
  } 
  else {Write-Host 'Config file failed validation checks'} 
}   
         
$run_job = { 
  $event_type = 'Information' 
  if (&$check_cfg){ 
    $start = Get-Date 
    $ret_max = [int]$job.diskspace * 1MB 
    $ret_min_date = $start.adddays(-$job.retain) 
    $deleteby = $job.deleteby 
    $ret_min_date = $(get-date).adddays(-$job.retain) 
    $events += $entry_text 
    $jobname = $job.filename.basename.substring(4) 
    $eventfile = $jobname + '_evt.txt' 
    Add-Content $eventfile $events 
    
    
    $entry_text = "`nFile Cleanup job $($jobname) started $($start).`n" 
    $entry_text +=  "Retention date is $($ret_min_date)" 
    $entry_text += $($job | out-string) 
    $events += $entry_text 
    $app_log.writeentry("$entry_text",$event_type,10121) 
    
    if (test-path $job.filespec){ 
      $dir = Get-ChildItem $job.filespec 
      $start_stats = $dir | Measure-Object -Property length -Sum 
      $start_size = $start_stats.sum 
      $entry_text = "Found $($dir.count) files.  $(to-kmg $start_size). `n" 
      
      $old_files = $dir |Where-Object {$_.$deleteby -lt $ret_min_date} 
      
      if ($old_files.count){ 
        $old_file_stats = $old_files | Measure-Object -Property length -Sum 
        $old_size = $old_file_stats.sum 
        $entry_text += "Found $($old_files.count) deletion eligible files totaling $(to-kmg $old_size). `n" 
        foreach ($old_file in $old_files){Remove-Item $old_file} 
        $entry_text += "****deleted $($old_files.count) eligible files.***** `n" 
      } 
      else {$entry_text += "No old files were found to delete `n";$event_type = 'Warning'} 
      
      $cleaned_dir = Get-ChildItem $job.filespec | Sort-Object $deleteby  
      $cleaned_stats = $cleaned_dir | Measure-Object -Property length -Sum 
      $cleaned_size = $cleaned_stats.sum 
      if ($ret_max -lt $cleaned_size){ 
        $event_type = 'Warning' 
        $over_limit = $cleaned_size - $ret_max 
        $entry_text += "Warning - $($job.filespec) is $(to-kmg $over_limit) over the specified disk quota after cleanup of old files. `n"  
        
        if ($job.enforce -eq 'True' -and $ret_max -lt $cleaned_size){  
          $i = 0 
          while ($ret_max -lt $cleaned_size){ 
            remove-item $cleaned_dir[$i]  
            $cleaned_size -= $cleaned_dir[$i].length 
            $i++ 
          } 
          $entry_text += "Warning - Deleted $i files from $($job.filespec) that were within the`n retention window in order to enforce disk quota.`n"  
          $last_ret = $cleaned_dir[$i].$deleteby 
          $ret_depth = ((Get-Date) - $last_ret).days 
          $entry_text += "Retention history depth has been reduced from $($job.retain) to $($ret_depth) days.`n"     
        } 
      } 
    } 
    else { 
      $entry_text += "Warning - No files matching configured filespec $($job.filespec) were found.  Exiting " 
      $event_type = 'Error' 
      $admin_notify = $true 
    }  
  } 
  else { 
    $entry_text += "Error - Job $($jobname) configuration file failed validation checks.  Exiting " 
    $event_type = 'Error' 
    $admin_notify = $true 
  } 
  
  $entry_text = "`nFile Cleanup job $($jobname) ended $(get-date).`n" + $entry_text 
  $app_log.writeentry("$entry_text",$event_type,10123) 
  $events += $entry_text     
  if ($job.mailto -ne 'NoEmail'){$mailto = $job.mailto;&$send_email} 
  if ($job.keepevents -eq 'True'){Add-Content $eventfile $events} 
  if ([Environment]::UserInteractive){Write-Host "`nJob Completed`nJob Events:`n`n $($events)"} 
} 
 
 
#########START Script run 
 
 
if ([Environment]::userinteractive -and -not $batch.ispresent){ 
  
  if ($job_dir -ne './'){ 
    if (Test-Path $job_dir -PathType Container){Set-Location $job_dir} 
    else {Write-Host 'Invalid job config directory specified. Exiting';exit} 
  } 
  
  $ErrorActionPreference = 'silentlycontinue' 
  if (!(Test-Path 'job_*.xml')){ 
    while ($createnew -notmatch "^(y|n)$"){ 
      $createnew = read-host "`nNo job configs found.  Create new config? (y/n)" 
      if ($createnew -match 'n'){write-host 'Nothing to do.  Exiting';exit} 
      else {$job = &$create_cfg;$job;&$select_maint} 
    } 
  } 
  else { 
    $jobcfgs = @(&$get_jobs) 
    Write-Host "Found $($jobcfgs.count) config files.`n" 
    &$select_maint 
  } 
} 
  
elseif ($batch.ispresent){ 
  $script_started = get-date 
  $event_type = 'Information' 
  $entry_text = "Cleanup script started $script_started. `n $($cmdline) `n " 
  
  if ($job_dir -ne './'){ 
    if (Test-Path $job_dir -PathType Container){Set-Location $job_dir} 
    else { 
      $entry_text += 'Invalid job config directory specified.' 
      $event_type = 'Error' 
      $admin_notify = $true 
      $mailto = $admin_email;&$send_email 
      $app_log.writeentry("$entry_text",$event_type,10120) 
      exit 
    } 
  } 
  $jobcfgs = @(&$get_jobs) 
  if ($jobcfgs.count -eq 0){ 
    $event_type = 'Error' 
    $entry_text += 'No jobs were found to process' 
  } 
  else {$entry_text += "`nFound $($jobcfgs.count) jobs to process.`n" 
    $entry_text += ($jobcfgs | Format-Table name | Out-String) 
  } 
  $events += $entry_text 
  $app_log.writeentry("$entry_text",$event_type,10120) 
  
  $entry_text = $null 
  
  foreach ($jobcfg in $jobcfgs){ 
    $job = Import-Clixml $jobcfg 
    $job | Add-Member -MemberType NoteProperty -name filename -Value $jobcfg 
    
    &$run_job 
  } 
  $entry_text = "Cleanup script ended $(get-date). `n $cmdline `n " 
  $app_log.writeentry("$entry_text",$event_type,10125) 
  if ($admin_notify){$mailto = $admin_email;&$send_email}  
  
}  