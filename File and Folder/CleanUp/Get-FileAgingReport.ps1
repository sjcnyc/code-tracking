function to_kmgt  {
    param
    (
      [System.Object]
      $bytes
    )

  foreach ($i in ('Bytes','KB','MB','GB','TB')) { if (($bytes -lt 1000) -or ($i -eq 'TB')) `
    { $bytes = ($bytes).tostring('F0' + '1') 
      return $bytes + " $i"
    }
    else {$bytes /= 1KB}
  }
}

Function Get-FileAgingReport { 
  Param( 
    #   [Parameter(Mandatory=$true)] 
    #   [string[]]$Computername, 
    [Parameter(Mandatory=$true)] 
  [String]$FolderFullPath) 
  $Object =@() 
 
  FUNCTION getUNCPath($infile) 
  { 
    $qualifier = Split-Path $infile -qualifier  
    $drive = $qualifier.substring(0,1)  
    $noqualifier = Split-Path $infile -noQualifier  
    “$drive`$$noqualifier” 
  } 
  # if (!(Test-Connection -ComputerName $Computername -Count 1 -Quiet)) 
  # { 
  #   Write-Output "Please check Computer -> $computername" 
  #   [System.Windows.Forms.MessageBox]::Show("Please check Computer -> $computername" , 'Status' , 4) 
  # } 
  # else 
  # { 
    $dir = $FolderFullPath 
  #   $dir= '\\storage\data$\HR3'
  #   #verify $Dir exists 
  #   if (Test-Path $dir) { 
 
      $now=Get-Date 
      $files=Get-ChildItem -path $dir -recurse | Where-Object {($_.GetType()).name -eq 'FileInfo'} 
      clear-host 
     
      #initialize 
      $Total5yr=0
      $Total2yr=0 
      $Total1yr=0
      $Total90=0  
      $Total180=0 
      $Total30=0 
      $Total7=0 
      $TotalCurrent=0 
      $2yrs=0 
      $5yrs=0
      $1yr=0 
      $6mo=0 
      $3mo=0 
      $1mo=0 
      $1wk=0 
      $current=0 
      $count=0 
     
      $Object1 =@() 
      $Object2 =@() 
      $Object3 =@() 
      $Object4 =@() 
      $Object5 =@() 
      $Object6 =@() 
      $object7=@() 
 
 
      foreach ($file in $files) { 
        $age=($now.subtract(($file.LastWriteTime))).days 
        $count=$count+1 
        Write-Progress -Activity 'File Aging Report' -status $file.DirectoryName -currentoperation $file.name  
        switch ($age) { 
          {$age -ge 1095} {$5yrs=$5yrs+1;$Total5yr=$Total5Yr+$file.length
            $Object1 += New-Object PSObject -Property @{ 
              FileList = $File.Name
              LastWriteTime=$file.LastWriteTime
            DirectoryName = $file.FullName};break} 
        #  {$age -ge 365} {$1yr=$1yr+1;$Total1yr=$Total1Yr+$file.length 
        #    $Object2 += New-Object PSObject -Property @{ 
        #      FileList = $File.Name
        #      LastWriteTime=$file.LastWriteTime 
        #    DirectoryName = $file.FullName};break} 
         #  {$age -ge 180} {$6mo=$6mo+1;$Total180=$Total180+$file.length; 
         #   $Object7 += New-Object PSObject -Property @{ 
          #    FileList = $File.Name.ToUpper(); 
          #    LastWriteTime=$file.LastWriteTime; 
          #  DirectoryName = $file.FullName;};break}    
         # {$age -ge 90} {$3Mo=$3Mo+1;$Total90=$Total90+$file.length; 
         #   $Object3 += New-Object PSObject -Property @{ 
         #     FileList = $File.Name.ToUpper(); 
         #     LastWriteTime=$file.LastWriteTime; 
         #   DirectoryName = $file.FullName;};break}  
         # {$age -ge 30} {$1Mo=$1Mo+1;$Total30=$Total30+$file.length; 
         #   $Object4 += New-Object PSObject -Property @{ 
         #     FileList = $File.Name.ToUpper(); 
         #     LastWriteTime=$file.LastWriteTime; 
         #   DirectoryName = $file.FullName;};break} 
         # {$age -ge 7} {$1wk=$1wk+1;$Total7=$Total7+$file.length; 
         #   $Object5 += New-Object PSObject -Property @{ 
         #     FileList = $File.Name.ToUpper(); 
         #     LastWriteTime=$file.LastWriteTime; 
         #   DirectoryName = $file.FullName;};break} 
         # {$age -lt 7}  {$current=$current+1;$TotalCurrent=$TotalCurrent+$file.Length; 
         #   $Object6 += New-Object PSObject -Property @{ 
         #     FileList = $File.Name.ToUpper(); 
         #     LastWriteTime=$file.LastWriteTime; 
         #   DirectoryName = $file.FullName;};break} 
         } 
      } 
 
      $GrandTotal=$Total5yr+$Total1yr+$TotalCurrent #$total180+$Total90+$Total30+$Total7+$TotalCurrent 
     
      #format file size totals to MB 
      $GrandTotal='{0:N2}' -f (to_kmgt($GrandTotal))
      $Total5yr='{0:N2}' -f (to_kmgt($Total5yr))  
     # $Total1yr='{0:N2}' -f (to_kmgt($Total1yr)) 
     # $Total90='{0:N2}' -f ($Total90/1048576)  
     # $Total180='{0:N2}' -f ($Total180/1048576)  
     # $Total1yr='{0:N2}' -f ($Total1yr/1048576) 
     # $Total30='{0:N2}' -f ($Total30/1048576) 
     # $Total7='{0:N2}' -f ($Total7/1048576) 
      $TotalCurrent='{0:N2}' -f (to_kmgt($TotalCurrent)) 
 
      $column1 = @{expression='FileList'; label='FileList'; alignment='left'} 
      $column2 = @{expression='DirectoryName'; label='DirectoryName'; alignment='left'} 
      $column3 = @{expression='LastWriteTime'; label='LastWriteTime'; alignment='left'} 


  
  $output = @"
'#'*80 
'File Age Report' 
"Generated $(get-date)" 
"Generated from $(gc env:computername)" 
'#'*80 
 
 "File Aging for - $dir" 
 
 "3 years : $5yrs files - $Total5yr "

 $( $Object1 | % {$_ } | ConvertTo-Csv)

 "Totals: $count - files : $GrandTotal" 
  
"@
     
     
 # $output | Out-File C:\TEMP\test.txt -NoClobber


     
      clear-host 
      '#'*80 
      'File Age Report' 
      "Generated $(get-date)" 
      "Generated from $(gc env:computername)" 
      '#'*80 
 
      Write-output "File Aging for - $dir" 
      Write-Output "3 years : $5yrs files - $Total5yr " 
     # Write-Output "2 years : $2yrs files - $Total2yr MB " 
      #Write-output '2 years:' $2yrs  'files' $Total2yr 'MB' -foregroundcolor "Red" 
      $object1|format-table $column1, $column2, $column3 -AutoSize 
     # Write-output "1 year : $1yr files - $Total1yr" 
     # $object2 | Format-Table $column1, $column2, $column3
     # Write-output "6months : $6Mo files - $Total180 MB" 
     # $object7|format-table $column1, $column2, $column3 
     # Write-output "3 months: $3Mo files - $Total90 MB" 
     # $object3|format-table $column1, $column2, $column3 
     # Write-output "1 month: $1mo files - $Total30 MB" 
     # $object4|format-table $column1, $column2, $column3 
     # Write-output "1 week: $1wk files - $Total7 MB"  
     # $object5|format-table $column1, $column2, $column3 
     # Write-output "Current: $current files - $TotalCurrent MB"  
     # $object6|format-table $column1, $column2, $column3 
      Write-output `n 
      Write-output "Totals: $count - files : $GrandTotal"  
      Write-output `n 
      #  $object1+$object12+$object3 |Out-GridView 
  #   } 
  #   else 
  #   { 
  #     Write-Output "Failed to find :  $Dir" 
  #     [System.Windows.Forms.MessageBox]::Show("Failed to find :  $Dir" , 'Status' , 4) 
 
  #    } 
  #  } 
 
} 


$paths = @"
\\storage\data$\DROYALTY\j
\\storage\data$\DROYALTY\RKrause
\\storage\data$\DROYALTY\1HR for ES Employees
\\storage\data$\DROYALTY\Talent
\\storage\data$\DROYALTY\astabile
\\storage\data$\DROYALTY\December 2009 Stmt Rendering
\\storage\data$\DROYALTY\Lillian migration project
\\storage\data$\DROYALTY\MSeabourne
\\storage\data$\DROYALTY\MariaC
\\storage\data$\DROYALTY\Folder Settings
\\storage\data$\DROYALTY\KStevenson
\\storage\data$\DROYALTY\1Royalty Calendar
\\storage\data$\DROYALTY\GRS2EROS
\\storage\data$\DROYALTY\KShah
\\storage\data$\DROYALTY\DCR
\\storage\data$\DROYALTY\Zack Curcio
\\storage\data$\DROYALTY\KMiroddi
\\storage\data$\DROYALTY\LCoutinho
\\storage\data$\DROYALTY\RMS
"@-split [environment]::NewLine

foreach ($path in $paths)
{
Get-FileAgingReport -FolderFullPath $path | Out-File c:\temp\aging2.txt -Append ascii -NoClobber -Width 1000

}