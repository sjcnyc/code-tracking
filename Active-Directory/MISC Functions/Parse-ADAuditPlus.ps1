#Audit Report mod
#vars
Clear-Host
$XLSName = 'AllFileorFolderChanges'
$currentdate = get-date
$currentdate = $currentdate.ToString('MMMddyyyy')
$path = '\\storage\worldwide$\SecurityLogs\ADAuditPlus\bmg.bagint.com\FileandFolderAuditing'
$descMOD = 'File or Folder Changes - (Excluding USA-GBL USLYNPWFS04 SOXDATA RnC)'
$descALL = 'File or Folder Changes - (ALL Users)'
$folders = Get-ChildItem $path -Directory
$attachments =@()
$debug = $true
$exclude = Get-QADGroupMember 'USA-GBL USLYNPWFS04 SOXDATA RnC' | Select-Object samaccountname
$processing = $false

# main loop
foreach ($folder in $folders)
{
  if ($folder.name -eq $currentdate) # compare folder name to current date
  {
    $processing = $true
    if($debug){write-host 'Start Processing...'}
    $folderpath = Get-ChildItem $folder.FullName
    foreach ($subfolder in $folderpath) # loop subfolders
    {
      $subf = Get-ChildItem $subfolder.FullName
      foreach ($file in $subf) # loop xls files
      {
        if ($file.name -eq "$($XLSName).xls") # match file to $XLSName
        {
          $workFile = $($file.FullName).Replace('.xls','') # var: path/filename with extension removed
          if($debug){write-host 'Processing xls file...'}
          # create new Excel COM object
          $xlCSV = 6
          $Excel = New-Object -Com Excel.Application 
          $Excel.visible = $False 
          $Excel.displayalerts=$False 
          $WorkBook = $Excel.Workbooks.Open("$($workFile).xls") # open xls file
          $Workbook.SaveAs("$($workFile).csv",$xlCSV) # save xls as csv
          $Excel.quit() # close Excel COM object
          # load csv into array
          if($debug){write-host 'Stripping junk content from csv array...'}
          get-content "$($workFile).csv" | 
          select-object -last ((get-content "$($workFile).csv").count - 6) | # strip usless junk from header :|
          out-file "$($workFile).txt" # export to txt file
          # create csv no group member filter
          $modTocsv = import-csv "$($workFile).txt" -WarningAction 0
          $modTocsv | 
          foreach-object { $_ } | 
          select-object 'Server','File / Folder Name','Location','Time Accessed','Accessed by','Message' |
          export-csv "$($workFile)_ALLUSER.csv" -notype 
          $NewLine = '{0}' -f "`n`n$($descALL)`nServer: USLYNPWFS04`nGenerated: $((get-date -f G))" # construct header info
          $NewLine | add-content -path "$($workFile)_ALLUSER.csv" # append header info               
          
          # create csv filtering group members
          if($debug){write-host 'Filtering txt file...'}
          $modTocsv = import-csv "$($workFile).txt" -WarningAction 0 # import txt into csv object 
          $modTocsv | 
          foreach-object { $_ } | 
          select-object 'Server','File / Folder Name','Location','Time Accessed','Accessed by','Message' |
          where-object { @($exclude.samaccountname) -notcontains $_.'Accessed By' }  | # filter groupMembers
          export-csv "$($workFile)_MODIFIED.csv" -notype  
          $NewLine = '{0}' -f "`n`n$($descMOD)`nServer: USLYNPWFS04`nGenerated: $((get-date -f G))" # construct header info
          $NewLine | add-content -path "$($workFile)_MODIFIED.csv" # append header info 
          
          if($debug){write-host 'Cleaning up...'}              
          remove-item "$($workFile).txt" # remove txt file
          remove-item "$($workFile).csv" # remove csv file
          if($debug){write-host "Adding to attachment array...`n"}
          $attachments += "$($workFile)_MODIFIED.csv"
          $attachments += "$($workFile)_ALLUSER.csv"
          
        }
      }                     
    }
    
    if($debug){write-host 'Done processing!'} # this was harder that i thought it would be sheesh! 
  } 
}
 

if($processing) {
  
# Construct HTML Header and CSS
$HeaderHTML = @"
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<html><head><title>My Systems Report</title>
<style type="text/css">
<!--
body, p, th, td, h1, a:link {font-family:Verdana,Arial;font-size:8.5pt;color:#7b7b7b;text-decoration:none;}
h1 {font-size:12pt;letter-spacing:1pt;word-spacing:1pt;font-weight:bold;color:#b12424}
-->
</style>
</head>
<body>
"@
  
  # construct Body and footer HTML
  $BodyHTML = @"
<h1>All File or Folder Changes by Server.</h1>
<p>
<b>Domain Name: </b> bmg.bagint.com<br>
<b>Showing reports for:</b><br> 
&nbsp;&nbsp;&nbsp;<i>All File or Folder Changes Grouped by Server (ALL Users)<br>
&nbsp;&nbsp;&nbsp;All File or Folder Changes Grouped by Server (Excluding USA-GBL USLYNPWFS04 SOXDATA RnC)</i><br>
<b>Report Generated at: </b> $(get-date -f F)<br>
<b>Object Name(s): </b> USLYNPWFS04<br><br>
<b>Contact: </b><a href="mailto:sconnea@sonymusic.com?subject=AuditMod"> Sean Connealy</a> - 201-777-3487
</p>
</body>
</html>
"@
  
  $MailHTML = $headerHTML + $BodyHTML
  
  # email params
  $EmailParams =@{
    smtp    = 'ussmtp01.bmg.bagint.com'
    from    = 'poshalerts@sonymusic.com'   
    to      = 'sean.connealy@sonymusic.com' #,"Alex.Moldoveanu@sonymusic.com","kim.lee@sonymusic.com"
    subject = 'All File or Folder Changes by Server.'
    body    = ($MailHTML | Out-String)
    bodyAsHtml = $true
    attachments = $attachments
}
  
  # Email information
  Send-MailMessage @EmailParams
}
else {
  write-host 'Nothing to process, Miller time!'
}