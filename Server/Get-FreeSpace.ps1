
filter Out-Color{
    
    param(    
                [ScriptBlock]$FilterScript,
        [System.ConsoleColor]$Color='Red'        
     )
   
    $fgc=[console]::ForegroundColor

	if( &$FilterScript )
    {
                [console]::ForegroundColor=$color
                $_
    }
    else{
                [console]::ForegroundColor=$fgc
                $_
    }
    [console]::ForegroundColor=$fgc
}



Function Get-FreeSpace {
	
[CmdletBinding()]
	
	PARAM
	(
		[parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [alias("CN","__SERVER","CNAME","Computer")]
		[String[]]$ComputerName = $env:COMPUTERNAME,
		[switch]$NoPing,
		[switch]$ListUnreachable,
		[switch]$ShowProgress,
		[INT]$PingCount = 2
	)
	
	Begin {
		Write-Host
		Write-Host
		Write-Host
		Write-Host
		Write-Host "	Begin querying computers" -ForegroundColor Green
		Write-Host "*************************************" -ForegroundColor Green
		$IDC = 0
		If ($File){
			$ComputerName = Get-Content $File
		}
	}
	

	
	Process {
		Foreach ($Computer in $ComputerName){
			$Computer = $Computer.TrimEnd("$")
			$Ping = Test-Connection -ComputerName $Computer -Quiet -Count $PingCount
			If ($NoPing){
				$Ping = $true
			}
			$IDC++;$IDD = 0
			If ($Ping){ 
				gwmi win32_logicalDisk -ComputerName $Computer -Filter "DriveType=3" | Foreach-Object{
				    $IDD++
					if ($_.Size -eq $null){
						Return
					}
					New-Object PSObject -Property @{		
						ID = "$IDC.$IDD"
						ComputerName = $_.SystemName
						DiskName = $_.Caption
						VolumeName = $_.VolumeName
						FreeSpaceGB = [Math]::Round($_.FreeSpace / 1gb,2)
						FreeSpacePercent = [Math]::Round((($_.FreeSpace / $_.size) *100),2)
						DiskSizeGB = [Math]::Round($_.Size / 1gb,2)
						UsedSpaceGB = [Math]::Round((($_.Size - $_.FreeSpace) / 1gb),2)
						FileSystem = $_.FileSystem
						Compressed = $_.Compressed
						Description = $_.Description
						SN = $_.VolumeSerialNumber
						
					} |Select-Object ID,ComputerName,DiskName,VolumeName,FreeSpaceGB,FreeSpacePercent,UsedSpaceGB,DiskSizeGB,FileSystem,Compressed,Description,SN
				}		
			}Else{
					if ($ListUnreachable){
							New-Object PSObject -Property @{		
							ID = "$IDC.$IDD"
							ComputerName = $Computer
							DiskName = "N/A"
							VolumeName = "N/A"
							FreeSpaceGB = "N/A"
							FreeSpacePercent = "N/A"
							DiskSizeGB = "N/A"
							UsedSpaceGB = "N/A"
							FileSystem = "N/A"
							Compressed = "N/A"
							Description = "N/A"
							SN = "N/A"
							
						} |Select-Object ID,ComputerName,DiskName,VolumeName,FreeSpaceGB,FreeSpacePercent,UsedSpaceGB,DiskSizeGB,FileSystem,Compressed,Description,SN
					}
			}
						if ($ShowProgress){
				$I++
				Write-Progress -Activity "Querying Computer : $Computer" -PercentComplete -1 -CurrentOperation "Computer Number $I" -Status "Progress->" 
				Start-Sleep 1
			}
		}
		
	}
	
	End {
	
		Write-Host
		Write-Host "Done !!!" -ForegroundColor Green
	}
	

}

get-freespace ly2,ny1 | ft -auto

