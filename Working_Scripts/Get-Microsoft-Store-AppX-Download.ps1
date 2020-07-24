#Requires -runasadministrator

if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Write-Warning "This script must be run as an Administrator"
  Break
}

Clear-Host

# Recursively enumerate installed packages and copy corresponding bundled package/dependencies to c:\appx_install.
function Copy-Bundled ($up, $root) {
  $count = $up.count
  For ($i = 0; $i -lt $count; $i++) {
    $folder = ("$root\$($up.item($i).title)") -replace "\.", "_"
    if (!(Test-Path $folder -PathType Container)) {
      $ftemp = New-Item -ItemType Directory -Force $folder
    }
    try {
      write-host "Copying files to $folder"
      $up.item($i).CopyFromCache($folder, $False)
    }
    catch {
      if ($_ -like "*0x80246010*") {
        write-host "`n$folder with identity $($up.item($i).Identity.updateid) does not exist. Will try to download...."
        download-updates $up
        $up.item($i).CopyFromCache($folder, $False)
        if ($?) {
          write-host "`nCopy successfull`n"
        }
      }
      elseif (!($_ -like "*0x80070050*")) {
        #Ignore "The file exists." errors.
        write-host "`n $_ `n"
      }
    }
    if (($up.item($i).bundledupdates.count)) {
      Copy-Bundled $up.item($i).bundledupdates $root
    }
  }

}

# Recursively enumerate installed packages and copy corresponding package/dependencies to c:\appx_install.
Function Copy-Updates ($up, $root) {
  $count = $up.count
  For ($i = 0; $i -lt $count; $i++) {
    $folder = ("$root\$($up.item($i).title)") -replace "\.", "_"
    if (!(Test-Path $folder -PathType Container)) {
      $ftemp = New-Item -ItemType Directory -Force $folder
    }
    Copy-Bundled $up.item($i).bundledupdates $folder
  }
}

Function Download-Updates ($updates) {
  $UpdatesToDownload = New-Object -Com Microsoft.Update.UpdateColl
  For ($i = 0; $i -lt $updates.count; $i++) {
    $UpdatesToDownload.Add($updates.item($i)) | out-null
  }
  $Downloader = (New-Object -Com Microsoft.Update.Session).CreateUpdateDownloader()
  $Downloader.IsForced = $True                                               # https://docs.microsoft.com/en-us/windows/win32/api/wuapi/nn-wuapi-iupdatedownloader?redirectedfrom=MSDN
  $Downloader.Updates = $UpdatesToDownload
  $Downloader.Download() | Out-Null
  Write-Host "`nDownload Finished.`n"
}

Function Find-Updates {
  $Session = New-Object -ComObject Microsoft.Update.Session
  $Searcher = $Session.CreateUpdateSearcher()
  $Searcher.ServiceID = '855e8a7c-ecb4-4ca3-b045-1dfa50104289'                # Microsoft Store Service ID.
  $Searcher.SearchScope = 2                                                   # https://docs.microsoft.com/en-us/windows/win32/api/wuapi/ne-wuapi-searchscope
  $Searcher.ServerSelection = 3                                               # https://docs.microsoft.com/en-us/previous-versions/windows/desktop/aa387280(v=vs.85)
  $Searcher.Online = $False                                                   # Do not change this to $True.
  $Criteria = "IsInstalled = 1"                                               # https://docs.microsoft.com/en-us/windows/win32/api/wuapi/nf-wuapi-iupdatesearcher-search
  Write-Host "`nEnumerating main package list....`n"
  $SearchResult = $Searcher.Search($Criteria)
  $Updates = ($SearchResult.Updates)
  Write-Host "`n$($updates.count) packages found.`n"
  $Updates
}

$Updates = Find-Updates
Write-Output "`nDownloading currently installed software packages and dependencies. This may take a while...`n"
Download-updates $Updates

Write-Output "`nCopying packages and dependencies to c:\appx_install...`n"
if (!(Test-Path "c:\appx_install" -PathType Container)) { New-Item -ItemType Directory -Force "c:\appx_install\" | Out-Null }
Copy-Updates $updates "c:\appx_install"

Write-Output "`nScript completed. Your downloaded files are located in c:\appx_install."
Write-Output "Files that do not have an extension can be renamed to .appx (or any other extension that the app installer supports."