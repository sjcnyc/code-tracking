#requires -version 2.0

Param (
[string[]]$computers=@($env:computername),
[string]$Path='c:\users\sconnea\desktop\drivereport.htm'
)

$Title='Drive Report'

#embed a stylesheet in the html header
$head = @"
<style>
body { background-color:#FFFFFF;font-family:Tahoma;font-size:12pt; }
td, th { border:0px solid #000033;border-collapse:collapse; }
th { color:black;}
table, tr, td, th { padding: 4px; margin: 4px }
table { margin-left:10px; }
</style>
<Title>$Title</Title>
<br>
"@ 

#define an array for html fragments
$fragments=@()

#get the drive data
$data=get-wmiobject -Class Win32_logicaldisk -filter 'drivetype=3' -computer $computers

#group data by computername
$groups=$Data | Group-Object -Property SystemName

#this is the graph character
[string]$g=[char]0x2588 

#create html fragments for each computer
#iterate through each group object
        
ForEach ($computer in $groups) {
    
    $fragments+="<H2>$($computer.Name)</H2>"
    $fragments+="<table border='1px' width='50%'><tr><td>"
    #define a collection of drives from the group object
    $Drives=$computer.group
    
    #create an html fragment
    $html=$drives | Select-Object @{Name='Drive';Expression={$_.DeviceID}},
    @{Name='SizeGB';Expression={$_.Size/1GB  -as [int]}},
    @{Name='UsedGB';Expression={'{0:N2}' -f (($_.Size - $_.Freespace)/1GB) }},
    @{Name='FreeGB';Expression={'{0:N2}' -f ($_.FreeSpace/1GB) }},
    @{Name='Usage';Expression={
      $UsedPer= (($_.Size - $_.Freespace)/$_.Size)*100
      $UsedGraph=$g * ($UsedPer/2)
      $FreeGraph=$g * ((100-$UsedPer)/2)
      #I'm using place holders for the < and > characters
      'xoFont color=redxc{0}xo/FontxcxoFont Color=Greenxc{1}xo/fontxc' -f $usedGraph,$FreeGraph }} | ConvertTo-Html -Fragment 
    
    #replace the tag place holders. It is a hack but it works.
    $html=$html -replace 'xo','<'
    $html=$html -replace 'xc','>'
    
    #add to fragments
    $Fragments+=$html
    
    #insert a return between each computer
    $fragments+='<br>'
    
} #foreach computer

#add a footer
$fragments+='</td></tr></table>'
$footer=('<br><I>Report run {0} by {1}\{2}<I>' -f (Get-Date -displayhint date),$env:userdomain,$env:username)
$fragments+=$footer

#write the result to a file
ConvertTo-Html -head $head -body $fragments  | Out-File $Path