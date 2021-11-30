$newtonsoftPath = (get-module az.accounts).Path | `
    split-path | `
    join-path -childpath "\PreloadAssemblies\Newtonsoft.json.10.dll"
    
$newtonsoft = [System.Reflection.Assembly]::LoadFrom($newtonsoftPath)
$onAssemblyResolveEventHandler = [System.ResolveEventHandler] {
  param($sender, $e)
  # You can make this condition more or less version specific as suits your requirements
  if ($e.Name.StartsWith("Newtonsoft.Json")) {
    return $newtonsoft
  }
  foreach($assembly in [System.AppDomain]::CurrentDomain.GetAssemblies()) {
    if ($assembly.FullName -eq $e.Name) {
      return $assembly
    }
  }
  return $null
}
[System.AppDomain]::CurrentDomain.add_AssemblyResolve($onAssemblyResolveEventHandler)