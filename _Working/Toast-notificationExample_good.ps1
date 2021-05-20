## Displays a Windows 10 Toast Notification for a ConfigMgr Application deployment
## To be used in a compliance item

## References
# Options for audio: https://docs.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-audio#attributes-and-elements
# Toast content schema: https://docs.microsoft.com/en-us/windows/uwp/design/shell/tiles-and-notifications/toast-schema
# Datetime format for deadline: Ref: https://msdn.microsoft.com/en-us/library/system.datetime(v=vs.110).aspx


$object = [pscustomobject]@{

  Name         = $($ENV:USERNAME)
  HostName     = $($ENV:COMPUTERNAME)
  Domain       = $($ENV:USERDOMAIN)
  IPAddress    = $(Resolve-DnsName -Type A -Name $env:computername | Select-Object -ExpandProperty IPAddress)

  MappedDrives = & {
    foreach ($service in (Get-SMBMapping)) {
      Write-Output ([pscustomobject][ordered]@{
          Drive = $service.LocalPath
          Path  = $service.RemotePath
        }
      )
    }
  }
}

$UserObject = [pscustomobject]@{
  Name         = $object.Name
  HostName     = $object.HostName
  Domain       = $object.Domain
  IPAddress    = $object.IPAddress
  MappedDrives = (($object).MappedDrives | Out-String).Trim()
}

$UserObject


# Required parameters
#$Title = "IP Addresser 3.0"
#$SoftwarecenterShortcut = "softwarecenter:SoftwareID=ScopeId_8E25450A-4C7E-4508-B501-B3F0E2C91541/Application_abd1dcbe-275a-4be1-9800-1c1e9a0ce7ff"
$AudioSource = "ms-winsoundevent:Notification.Default"
#$SubtitleText = "IP Addresser 3.0"
$BodyText = "User Name:`t$($UserObject.Name)`r`nHost Name:`t$($UserObject.HostName)`r`nIP Address:`t$($UserObject.IPAddress)"
$HeaderFormat = "TitleOnly" # Choose from "TitleOnly", "ImageOnly" or "ImageAndTitle"

# Optional parameters
# Base64 string for an image, see Images section below to create the string
#$Base64Image = "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"
# Deployment deadline
#[datetime]$Deadline = "21 June 2018 15:00"


# Calculated parameters
If ($Deadline) {
  $TimeSpan = $Deadline - [datetime]::Now
}

## Images
# Convert an image file to base64 string
<#
$File = "C:\Users\tjones\Pictures\ICON_EV_LOGO_Resized.png"
$Image = [System.Drawing.Image]::FromFile($File)
$MemoryStream = New-Object System.IO.MemoryStream
$Image.Save($MemoryStream, $Image.RawFormat)
[System.Byte[]]$Bytes = $MemoryStream.ToArray()
$Base64 = [System.Convert]::ToBase64String($Bytes)
$Image.Dispose()
$MemoryStream.Dispose()
$Base64 | out-file "C:\Users\tjones\Pictures\ICON_EV_LOGO_Resized.txt" # Save to text file, copy and paste from there to the $Base64Image variable
#>

# Create an image file from base64 string and save to user temp location
If ($Base64Image) {
  $ImageFile = "$env:TEMP\ToastLogo.png"
  [byte[]]$Bytes = [convert]::FromBase64String($Base64Image)
  [System.IO.File]::WriteAllBytes($ImageFile, $Bytes)
}
 
# Load some required namespaces
$null = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
$null = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]

# Register the AppID in the registry for use with the Action Center, if required
$app = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
$AppID = "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\\WindowsPowerShell\\v1.0\\powershell.exe"
$RegPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings'

if (!(Test-Path -Path "$RegPath\$AppId")) {
  $null = New-Item -Path "$RegPath\$AppId" -Force
  $null = New-ItemProperty -Path "$RegPath\$AppId" -Name 'ShowInActionCenter' -Value 1 -PropertyType 'DWORD'
}


# Define the toast notification in XML format
[xml]$ToastTemplate = @"
<toast scenario="reminder">
    <visual>
    <binding template="ToastGeneric">
        <group>
            <subgroup>
                <text hint-style="title" hint-wrap="true" >$Title</text>
            </subgroup>
        </group>
        <group>
            <subgroup>
                <text hint-style="subtitle" hint-wrap="true" >$SubtitleText</text>
            </subgroup>
        </group>
        <group>
            <subgroup>
                <text hint-style="body" hint-wrap="true" >$BodyText</text>
            </subgroup>
        </group>
    </binding>
    </visual>
    <actions>
      <action content="Install now" activationType="protocol" arguments="$SoftwarecenterShortcut" />
      <action content="Another time..." arguments="" />
    </actions>
    <audio src="$AudioSource"/>
</toast>
"@

# Change up the headers as required
If ($HeaderFormat -eq "TitleOnly") {
  $ToastTemplate.toast.visual.binding.group[0].subgroup.InnerXml = "<text hint-style=""title"" hint-wrap=""true"" >$Title</text>"
}
If ($HeaderFormat -eq "ImageOnly") {
  $ToastTemplate.toast.visual.binding.group[0].subgroup.InnerXml = "<image src=""$ImageFile""/>"
}
If ($HeaderFormat -eq "ImageAndTitle") {
  $ToastTemplate.toast.visual.binding.group[0].subgroup.InnerXml = "<text hint-style=""title"" hint-wrap=""true"" >$Title</text><image src=""$ImageFile""/>"
}

# Add a deadline if required
If ($Deadline) {
  $DeadlineGroups = @"
        <group>
            <subgroup>
                <text hint-style="base" hint-align="left">Deadline</text>
                 <text hint-style="caption" hint-align="left">$(Get-Date -Date $Deadline -Format "dd MMMM yyy HH:mm")</text>
            </subgroup>
            <subgroup>
                <text hint-style="base" hint-align="right">Time Remaining  .</text>
                <text hint-style="caption" hint-align="right">$($TimeSpan.Days) days $($TimeSpan.Hours) hours $($TimeSpan.Minutes) minutes  .</text>
            </subgroup>
        </group>
"@
  $ToastTemplate.toast.visual.binding.InnerXml = $ToastTemplate.toast.visual.binding.InnerXml + $DeadlineGroups

}

# Load the notification into the required format
$ToastXml = New-Object -TypeName Windows.Data.Xml.Dom.XmlDocument
$ToastXml.LoadXml($ToastTemplate.OuterXml)

# Display
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app).Show($ToastXml)