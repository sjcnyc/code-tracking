﻿# Robocopy example code for more info see the series on my blog 
# http://thepowershellguy.com/blogs/posh/archive/tags/robocopy/default.aspx

#############################################################################################
## Make RoboCopy Help Object
#############################################################################################


$RoboHelp = Robocopy.exe /? | Select-String '::'
$r = [regex]'(.*)::(.*)'
$RoboHelpObject = $RoboHelp | Select-Object `
    @{Name='Parameter';Expression={ $r.Match( $_).groups[1].value.trim()}}, 
    @{Name='Description';Expression={ $r.Match( $_).groups[2].value.trim()}}

$RoboHelpObject = $RoboHelpObject |% {$Cat = 'General'} {
    if ($_.parameter -eq '') { if ($_.Description -ne ''){
        $cat = $_.description -replace 'options :',''}
    } else {
        $_ | Select-Object @{Name='Category';Expression={$cat}},parameter,description
    }
}


#############################################################################################
## Robocopy example command :
#############################################################################################


Robocopy.exe 'c:\test1' c:\PowerShellRoboTest /r:2 /w:5 /s /v /np |
  Tee-Object -Variable RoboLog


#############################################################################################
## Process the Output
#############################################################################################


$null,$StartBegin,$StartEnd,$StopBegin = $RoboLog | Select-String  '----' |% {$_.linenumber}

$RoboStatus = New-Object object

# Start information 

$robolog[$StartBegin..$StartEnd] | % {
  Switch -regex ($_) {
    'Started :(.*)' {
      Add-Member -InputObject $RoboStatus -Name StartTime `
       -Value ([datetime]::ParseExact($matches[1].trim(),'ddd MMM dd HH:mm:ss yyyy',$null)) `
       -MemberType NoteProperty
    }
    'Source :(.*)' {
      Add-Member -InputObject $RoboStatus -Name Source `
        -Value ($matches[1].trim()) -MemberType NoteProperty
    }
    'Dest :(.*)' {
      Add-Member -InputObject $RoboStatus -Name Destination `
        -Value ($matches[1].trim()) -MemberType NoteProperty
    }    
    'Files :(.*)' {
      Add-Member -InputObject $RoboStatus -Name FileName `
        -Value ($matches[1].trim()) -MemberType NoteProperty
    }
    'Options :(.*)' {
      Add-Member -InputObject $RoboStatus -Name Options `
        -Value ($matches[1].trim()) -MemberType NoteProperty
    }
  }
}

# Stop Information

$robolog[$StopBegin..( $RoboLog.Count  -1)] |% {
  Switch -regex ($_) {

    'Ended :(.*)' {
        Add-Member -InputObject $RoboStatus -Name StopTime `
          -Value ([datetime]::ParseExact($matches[1].trim(),'ddd MMM dd HH:mm:ss yyyy',$null))`
          -MemberType NoteProperty
    }

    'Speed :(.*) Bytes' {
        Add-Member -InputObject $RoboStatus -Name BytesSecond `
          -Value ($matches[1].trim()) -MemberType NoteProperty
    }

    'Speed :(.*)MegaBytes' {
        Add-Member -InputObject $RoboStatus -Name MegaBytesMinute `
          -Value ($matches[1].trim()) -MemberType NoteProperty
    }    

    '(Total.*)' {
      $cols = $_.Split() |Where-Object {$_}
    }

    'Dirs :(.*)' {
      $fields = $matches[1].Split() |Where-Object {$_}
      $dirs = new-object object
      0..5 |% {
          Add-Member -InputObject $Dirs -Name $cols[$_] -Value $fields[$_] -MemberType NoteProperty
          Add-Member -InputObject $Dirs -Name 'toString' -MemberType ScriptMethod `
            -Value {[string]::Join(' ',($this.psobject.Properties |
              % {"$($_.name):$($_.value)"}))} -force
      }
      Add-Member -InputObject $RoboStatus -Name Directories -Value $dirs -MemberType NoteProperty
    }

    'Files :(.*)' {
      $fields = $matches[1].Split() |Where-Object {$_}
      $Files = new-object object
      0..5 |% {
          Add-Member -InputObject $Files -Name $cols[$_] -Value $fields[$_] -MemberType NoteProperty
          Add-Member -InputObject $Files -Name 'toString' -MemberType ScriptMethod -Value `
            {[string]::Join(' ',($this.psobject.Properties |% {"$($_.name):$($_.value)"}))} -force
      }
      Add-Member -InputObject $RoboStatus -Name files -Value $files -MemberType NoteProperty
    }

    'Bytes :(.*)' {
      $fields = $matches[1].Split() |Where-Object {$_}
      $fields = $fields |% {$new=@();$i = 0 } {
          if ($_ -match '\d') {$new += $_;$i++} else {$new[$i-1] = ([double]$new[$i-1]) * "1${_}B" }
      }{$new}

      $Bytes = new-object object
      0..5 |% {
          Add-Member -InputObject $Bytes -Name $cols[$_] `
            -Value $fields[$_] -MemberType NoteProperty
          Add-Member -InputObject $Bytes -Name 'toString' -MemberType ScriptMethod `
            -Value {[string]::Join(' ',($this.psobject.Properties |
            % {"$($_.name):$($_.value)"}))} -force
      }
      Add-Member -InputObject $RoboStatus -Name bytes -Value $bytes -MemberType NoteProperty
    }
  }
}

# Process the details log 

$re = New-Object regex('(.*)\s{2}([\d\.]*\s{0,1}\w{0,1})\s(.*)')
$RoboDetails = $robolog[($StartEnd +1)..($stopbegin -3)] |Where-Object {$_.StartsWith([char]9)} | Select-Object `
    @{Name='Action';Expression={$re.Match($_) |% {$_.groups[1].value.trim()}}},
    @{Name='Size';Expression={$re.Match($_) |% {$_.groups[2] |% {$_.value.trim()}}}},
    @{Name='Directory';Expression={if(!($re.Match($_) |% {$_.groups[1].value.trim()})){
      '-';$Script:dir = $re.Match($_) |% {$_.groups[3] |
      % {$_.value.trim()}} }else {$script:dir}}},
    @{Name='Name';Expression={$re.Match($_) |% {$_.groups[3] |% {$_.value.trim()}}}}

# convert all values to bytes (but is also possible switch on robocopy )

0..($RoboDetails.count -1) |% {
  if ($Robodetails[$_].Directory -eq '-') {
    $Robodetails[$_].Action = 'Directory'
    $Robodetails[$_].Directory = split-path $Robodetails[$_].Name
  }
  if ($Robodetails[$_].size -match '[mg]') {
    $Robodetails[$_].size = [double]($roboDetails[$_].size.trim('mg ')) * 1mb
  }
}

#Add-Member -InputObject $RoboDetails -Name 'toString' -MemberType ScriptMethod `
  -Value {'Details : ' + $this.count} -force
Add-Member -InputObject $RoboStatus -Name Details `
  -Value $RoboDetails -MemberType NoteProperty

# Process warnings and errors 

$reWarning = New-Object regex('(.*)(ERROR.*)(\(.*\))(.*)\n(.*)')
$roboWarnings = $reWarning.matches(($robolog | out-string)) | Select-Object `
    @{Name='Time';Expression={[datetime]$_.groups[1].value.trim()}},
    @{Name='Error';Expression={$_.groups[2].value.trim()}},
    @{Name='Code';Expression={$_.groups[3].value.trim()}},
    @{Name='Message';Expression={$_.groups[5].value.trim()}},
    @{Name='Info';Expression={$_.groups[4].value.trim()}} 

#Add-Member -InputObject $RoboWarnigs -Name 'toString' `
  -MemberType ScriptMethod -Value {'Details : ' + $this.count} -force
Add-Member -InputObject $RoboStatus -Name Warnings `
  -Value $roboWarnings -MemberType NoteProperty

$reErrors = New-Object regex('\) (.*)\n(.*)\nERROR:(.*)')
$roboErrors = $reErrors.matches(($robolog |Where-Object {$_}| out-string)) | Select-Object `
    @{Name='Error';Expression={$_.groups[3].value.trim()}},
    @{Name='Message';Expression={$_.groups[2].value.trim()}},
    @{Name='Info';Expression={$_.groups[1].value.trim()}}

#Add-Member -InputObject $RoboErrors -Name 'toString' `
  -MemberType ScriptMethod -Value {'Details : ' + $this.count} -force
Add-Member -InputObject $RoboStatus -Name Errors `
  -Value $RoboErrors -MemberType NoteProperty


#############################################################################################
## Use $roboStatus Object created to get and format the statistics :
#############################################################################################


# check status 

$RoboStatus

# Calculate time running 

"Time elapsed : $($RoboStatus.StopTime - $RoboStatus.StartTime)"

# Get Help for Options given

$RoboStatus.Options.split()[1..100] |
  % { $par = $_ ;$RoboHelpObject |Where-Object {$_.parameter -eq $par} } | Format-Table -a

# Details on files and directories (to string overruled!) :

$RoboStatus.files
$RoboStatus.Directories

# Group Details

$RoboStatus.Details | Group-Object action

# List Errors and Warnings

$RoboStatus.Errors | Format-List

$RoboStatus.Warnings

# Get count of warnings

$RoboStatus.Warnings |Group-Object info | Format-Table count,Name -a

# Only warnings that resoved in a failed copy

$RoboStatus.Warnings | 
  Select-Object *, @{name='Failed';e={($RoboStatus.errors |% {$_.info}) -contains $_.info}}

# Action Details with warnings

$RoboStatus.details |Where-Object {$_.action} | Select-Object *,
  @{name='Failed';e={$d = $_;($RoboStatus.errors |
  % {$_.info}) -match '\\'+([regex]::escape($d.name))}} |Where-Object {$_.failed} |
  Group-Object action,directory,name | Format-Table -a name,count

# Count of warnings per error

$RoboStatus.Errors | 
  Select-Object *,@{name='Warnings';e={$e = $_;($robostatus.warnings |Where-Object {$_.info -eq $e.info}).count}}

# List of Warnings per error

$RoboStatus.Errors | 
  Select-Object *,@{name='Warnings';e={$e = $_;($robostatus.warnings |Where-Object {$_.info -eq $e.info})}} |% {
    $_ | Format-List error,Info ;$_.warnings | Sort-Object -u info,message | Format-Table [tecm]* -a  
}