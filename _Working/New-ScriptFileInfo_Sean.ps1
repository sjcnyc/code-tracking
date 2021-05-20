$Parms = @{
  Path                       = "D:\POWERSHELL\Powershell-Scripts\Working_Scripts\Restart-WindowsService1.ps1"
  Verbose                    = $True
  Version                    = "1.0.0"
  Author                     = "sconnea@sonymusic.com.com"
  Description                = " Restart Windows Service over Wmi on local and remote system"
  CompanyName                = "Sony Music"
  Copyright                  = "2020 Sony Music. All rights reserved."
  Tags                       = @("Windows WMI Remote Service Restart", "Tag2", "Tag3")
  ProjectUri                 = "https://contoso.com"
  LicenseUri                 = "https://contoso.com/License"
  IconUri                    = "https://contoso.com/Icon"
  PassThru                   = $True
  ReleaseNotes               = @("Contoso script now supports the following features:",
    "Feature 1",
    "Feature 2",
    "Feature 3",
    "Feature 4",
    "Feature 5")
  RequiredModules            =
  "1",
  "2",
  "RequiredModule1",
  @{ModuleName = "RequiredModule2"; ModuleVersion = "1.0" },
  @{ModuleName = "RequiredModule3"; RequiredVersion = "2.0" },
  "ExternalModule1"
}
New-ScriptFileInfo @Parms