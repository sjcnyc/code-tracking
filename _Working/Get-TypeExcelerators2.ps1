([appdomain]::CurrentDomain.GetAssemblies()) |
Out-GridView

[AppDomain]::CurrentDomain.GetAssemblies() |
ForEach-Object { $PSItem.GetTypes() } |
ForEach-Object { $PSItem.GetMethods() } |
Where-Object { $PSItem.IsStatic } |
Select-Object DeclaringType, Name |
Out-GridView -PassThru -Title '.NET types and their static methods'

<#
($Assembly_Infos = ([appdomain]::CurrentDomain.GetAssemblies()) | 
Where {$PSItem.Modules.name.contains("presentationframework.dll")})
#>

($Assembly_Infos = ([appdomain]::CurrentDomain.GetAssemblies()) |
  Where-Object { $PSItem.Location -Match 'presentationframework.dll' })

$Assembly_Infos.GetModules().gettypes() | 
Where-Object { $PSItem.isPublic -AND $PSItem.isClass } | 
Select-Object Name, BaseType | 
Out-GridView -Title '.Net Assembly Type information.'

# all the built-in .NET type accelerators in PowerShell:
[PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get |
Out-GridView

# Using a type accelerator
[ADSI].FullName

# Finding the properties of a .NET class
[System.Environment].DeclaredProperties.Name
[ADSI].DeclaredProperties.Name

[appdomain] | Get-Member -MemberType method

$UserName = 'Username'
[SecureString]$SecurePassword = ConvertTo-SecureString -String 'Password' -AsPlainText -Force
$Credential = [PSCredential]::New($UserName, $SecurePassword)

$Credential

[System.Collections.Concurrent]::New()

[System.Collections.Generic.List[object]]::new()

