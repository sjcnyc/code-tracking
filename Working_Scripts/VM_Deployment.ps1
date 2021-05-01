param(
    [parameter(Mandatory = $true)]
    [string[]]$hostnames  
)

#create objects via function because a few are the same format
function build-object {
    param($var, $count)

    for ($i = 0; $i -lt $count; $i++) {
        [pscustomobject]@{
            Number = $i
            Name   = $var[$i]
        }
    }
}

$vcenterfolder = "Folder-group-v17"
$vcenterip = "192.168.1.1"

Import-Module vmware.vimautomation.core -WarningAction SilentlyContinue -ErrorAction SilentlyContinue  | Out-Null
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null

Connect-VIServer $vcenterip -Credential (Get-Credential -Message "Enter Password" -UserName administrator@vsphere.local -ErrorAction SilentlyContinue) -ErrorAction SilentlyContinue | Out-Null

#set up a few menu choices
$cluster = (Get-Cluster).name
$folder = (Get-Folder | Where-Object { $_.parentid -eq $vcenterfolder }).name
$temp = (Get-Template).name

#hastable to iterate through
$list = @{
    cluster = $cluster
    folder  = $folder
    temp    = $temp
}

#build our menu options and select choices.
foreach ($l in $list.keys) {

    #dynamic variable creation (2spooky4me)
    Remove-Variable -Name $str -ErrorAction SilentlyContinue | Out-Null
    
    $str = $l + "_built"
    New-Variable -Name $str -Value @(build-object -var @($list[$l]) -count $list[$l].count)

    $a = Get-Variable -Name $str -ValueOnly

    #menu and select
    Clear-Host
    Write-Host "Choose A " (Get-Culture).TextInfo.ToTitleCase($l)
    Write-Output $a | Format-Table -AutoSize
    
    $choice = Read-Host -Prompt "Enter The Number You Want To Choose"
    Clear-Host

    $str2 = $str + "_choice"
    Remove-Variable -Name $str2 -ErrorAction SilentlyContinue | Out-Null
    New-Variable -Name $str2 -Value (((Get-Variable -Name $str).Value | Where-Object { $_.number -eq $choice }).name)
}

#get hosts based on cluster and get the current usage.
$host_built = $(foreach ($c in (Get-Cluster $cluster_built_choice | Get-VMHost)) {
        [pscustomobject]@{
            Name = $c.name
            CPU  = ([math]::round(($c.CpuTotalMhz - $c.CpuUsageMhz), 0))
            RAM  = ([math]::round(($c.MemoryTotalGB - $c.MemoryUsageGB), 0))
        }
    }) | Sort-Object ram -Descending | ForEach-Object { $i = 0 } {
    [pscustomobject]@{
        Number   = $i
        Name     = $_.name
        Free_CPU = $_.cpu
        Free_RAM = $_.ram
    }
    ++$i
}

Write-Host "Choose a Host"
Write-Output $host_built | Format-Table -AutoSize
$host_built_choice = ($host_built[$(Read-Host -Prompt "Enter The Number You Want To Choose")].name)
Clear-Host

#system resources
$memory = $null
while (!($memory)) {
    try {
        Clear-Host
        [int]$memory = Read-Host -Prompt "Enter Amount Of RAM As Gigabyte, Number Only."
    }
    catch {}
}

$cpu = $null
while (!($cpu)) {
    try {
        Clear-Host
        [int]$cpu = Read-Host -Prompt "Enter Amount Of CPU, Number Only."
    }
    catch {}
}

$coreoptions = $(for ($i = 1; $i -le $cpu; $i++) {
        if ($cpu % $i -eq 0) {
            if ($($cpu / $i) -le 4) {
                [pscustomobject]@{
                    Core   = $cpu / $i
                    Socket = $i
                }
            }
        }
    }) | ForEach-Object { $i = 0 } {
    [pscustomobject]@{
        Number = $i
        Core   = $_.core
        Socket = $_.socket
    }
    ++$i
}

Clear-Host
Write-Host "Core And Socket Count"
Write-Output $coreoptions | Format-Table -AutoSize
$core_choice = Read-Host -Prompt "Choose The Core And Socket Count"
Clear-Host

Write-Host "Finding DataStores..."
$datastore = Get-Datastore | Where-Object { $_.ExtensionData.host.key -eq (Get-VMHost $host_built_choice).Id } | Sort-Object freespacegb -Descending | Select-Object -First 10
Clear-Host

$datastore_built = for ($i = 0; $i -lt $datastore.count; $i++) {
    [pscustomobject]@{
        Number = $i
        Name   = $datastore[$i].name
        Size   = [math]::round($datastore[$i].freespacegb, 0)
    }
}

Write-Host "Choose A Datastore"
Write-Output $datastore_built | Format-Table -AutoSize

$choice = Read-Host -Prompt "Enter The Number You Want To Choose"
Clear-Host
$datastore_built_choice = ($datastore_built | Where-Object { $_.number -eq $choice }).name

foreach ($h in $hostnames) {

    $gobuild = ""
    while ("y" -notcontains $gobuild) {

        Clear-Host
        Read-Host -Prompt "Press Enter To Configure $h"

        #disk count
        $diskcount = $null
        while (!($diskcount)) {
            try {
                Clear-Host
                [int]$diskcount = Read-Host -Prompt "How Many Disks Do You Need In Addition To The C Drive?"
                
                if ($diskcount -lt 1) {
                    break
                }
            }
            catch {}
        }

        Get-Variable -Name "disk_$($h)_*" -ErrorAction SilentlyContinue | ForEach-Object { Remove-Variable $_.name }

        #create variables, use [char] to increment a letter so you see C, D drive.
        for ($i = 1; $i -le $diskcount; ++$i) {
            Clear-Host
            New-Variable -Name "disk_$($h)_$i" -Value (Read-Host -Prompt "Enter The Size of Your $([char](67 + $i)) Drive")
            Clear-Host
        }
    
        #build an object so we can check out settings before we deploy.
        $buildspecs = [pscustomobject]@{
            Name      = $h
            Cluster   = $cluster_built_choice
            DataStore = $datastore_built_choice
            Folder    = $folder_built_choice
            Template  = $temp_built_choice
            Host      = $host_built_choice
            RAM       = $memory
            CPU       = $cpu
            Core      = $coreoptions[$core_choice].Core
        }
    
        #add disks dynamically because there can be any number.
        $diskvarcount = (Get-Variable "disk_$($h)_*").count
        for ($i = 1; $i -le $diskvarcount; $i++) {
            $buildspecs | Add-Member -MemberType NoteProperty -Name "Disk_$($h)_$i" -Value $((Get-Variable "disk_$($h)_$i").value)
        }
    
        Write-Output $buildspecs | Format-Table -AutoSize -Property *
        $gobuild = ""
        $gobuild = Read-Host -Prompt "Are The Build Spec's Correct? Y or N"
        Clear-Host

        #switch on check, restart the while if we see anything but y.
        switch ($gobuild) {
            Y { break }
            N { continue }
            Default { continue }
        }
    }

    #deploy VM based on the settings, run async for multiple deployments.
    $newvm = New-VM -Template $temp_built_choice `
        -VMHost $(Get-VMHost $host_built_choice) `
        -Name $h `
        -Location $(Get-Folder $folder_built_choice | Where-Object { $_.parentid -eq $vcenterfolder }) `
        -Datastore $(Get-Datastore $datastore_built_choice) `
        -DiskStorageFormat Thin `
        -Confirm:$false `
        -RunAsync `

}

#wait for the deployment to finish all vms
while (Get-Task | Where-Object { $_.name -eq "CloneVM_Task" -and $_.state -eq "Running" }) {
    Start-Sleep -Seconds 5
}

for ($h = 0; $h -lt ($hostnames).Count; $h++) {
    
    Write-Host "Configuring " $hostnames[$h]
    
    #get vm for config tasks
    $vm = Get-VM $hostnames[$h]

    #create the disk start at index 1 as to not recreate the c drive sized disk
    for ($i = 1; $i -le (Get-Variable "disk_$($hostnames[$h])_*").count; $i++) {
        
        [void](New-HardDisk -VM $vm -DiskType Flat -CapacityGB (Get-Variable "disk_$($hostnames[$h])_$i").Value -StorageFormat Thin -Datastore $buildspecs.datastore -Confirm:$false -WarningAction SilentlyContinue | Out-Null)
            
        if ($i -eq (Get-Variable "disk_$($hostnames[$h])_*").count) {
            continue
        }
        else {
            while (Get-Task | Where-Object { $_.name -eq "ReconfigVM_Task" -and $_.state -eq "Running" -and $_.ObjectId -eq $vm.Id }) {
                Start-Sleep -Seconds 5
            }
        }
    }
    
    #set vm resources
    Set-VM -VM $vm -MemoryGB $buildspecs.ram -NumCpu $buildspecs.cpu -Confirm:$false -RunAsync | Out-Null

    $spec = New-Object -TypeName vmware.vim.virtualmachineconfigspec -Property @{"NumCoresPerSocket" = $buildspecs.core }
    ($vm).extensiondata.reconfigvm_task($spec) | Out-Null
}

while (Get-Task | Where-Object { $_.name -eq "ReconfigVM_Task" -and $_.state -eq "Running" }) {
    Start-Sleep -Seconds 5
}

#start the vm 
try {
    $start = $hostnames | ForEach-Object { Start-VM -VM $_ -Confirm:$false -RunAsync | Out-Null }
}
catch {}