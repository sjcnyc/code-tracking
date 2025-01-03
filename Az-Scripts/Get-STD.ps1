$tmp_path = "d:\TEMP\tmp.xml"

$NetworkServiceTag = Get-AzNetworkServiceTag -Location eastus2

$data = $NetworkServiceTag.Values.Properties | Where-Object { $_.SystemService -eq "" } | Where-Object { $_.Region -ne "" }

$json = $data | ConvertTo-Json

$json | Out-File "D:\temp\file.json"

$doc = New-Object -Type System.Xml.XmlDocument
$root = $doc.CreateElement('AzurePublicIpAddresses')
$doc.AppendChild($root)
 
$data | ForEach-Object {
  $region_name = $_.Region
  $subnets = $_.AddressPrefixes
  $region_elem = $doc.CreateElement('Region')
  $root.AppendChild($region_elem) | Out-Null
  $region_elem.SetAttribute('Name', $region_name)

  $subnets | ForEach-Object {
    $subnet_elem = $doc.CreateElement('IpRange')
    $region_elem.AppendChild($subnet_elem) | Out-Null
    $subnet_elem.SetAttribute('Subnet', $_)
  }    
}
 
$doc.Save($tmp_path)
Get-Content $tmp_path