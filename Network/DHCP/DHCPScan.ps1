$RootDSE = Get-QADRootDSE -Service 'bmg.bagint.com:389'
# This will be used as the search root when searching Active Directory for a computer account
$RootNC = $RootDSE.rootDomainNamingContext
# The connfiguration portion of Active Directory
$ConfigNC =  $RootDSE.ConfigurationNamingContext
# Get-QADObject is used here, but we can write around it if installation is impossible.
Get-QADObject -SearchRoot "CN=NetServices,CN=Services,$ConfigNC" -LdapFilter '(objectClass=dHCPClass)' |
  ForEach-Object {
    # We're looping through the results of the search now.
  
    # The use of [Ordered] here requires PowerShell 3. Makes the output format nicer.
    # This is the information we're returning, this will be written to a CSV file.
    # Information we know (such as Name) is added, information we don't know yet is set to 
    # a default value until we know better.
    $Server = New-Object PsObject -Property ([Ordered]@{
      Name                       = $_.Name;
      AuthDN                     = $DN;
      PingResponds               = $false;
      DHCPServiceStatus          = 'NotPresent';
      DnsUpdateEnabled           = 'Unknown';
      DnsUpdateSetting           = 'Unknown';
      DnsDiscardForwardLookups   = 'Unknown';
      DnsUpdateNonDynamicClients = 'Unknown';
      ServerPasswordLastSet      = $null;
      ServerLastLogin            = $null;
    })

    # This section has moved, in the previous version it was under the "if (Test-Connection $Server.Name -Quiet -Count 2) {" statement.
    # 
    # Attempt to find the computer account. This will slow the script down, repeated searches like this aren't all
    # that efficient. The search targets the Global Catalog to account for all domains within a Forest (a single tree is assumed).
    $ComputerObject = Get-QADComputer -DnsName $Server.Name -SearchRoot $RootNC -GC -IncludedProperties PwdLastSet, LastLogonTimeStamp
    # Pull the PasswordLastSet field for this computer account from AD. Computers accounts reset this every 30 days (regardless of password policy).
    $Server.ServerPasswordLastSet = $ComputerObject.PwdLastSet
    # Pull the lastLogonTimeStamp. It may be up to 14 days out, but it's replicated and published into the GC so it's a great field for this.
    $Server.ServerLastLogin = $ComputerObject.LastLogonTimeStamp

    # Test-Connection is Ping. Sending 2 ICMP requests and hoping for a reply.
    if (Test-Connection $Server.Name -Quiet -Count 2) {
      # If it did reply, set that value on the Server object used to generate the report.
      $Server.PingResponds = $true

      # Pull a list of all services on the server and filter the list to see if the DhcpServer service is listed.
      # This is faster than running "Get-Service DhcpServer -ComputerName $Server.Name" as we don't have to timeout
      # the call if the service does not exist.      
      $DhcpService = Get-Service -ComputerName $Server.Name | Where-Object { $_.Name -eq 'DhcpServer' }
      
      # If the service does exist.
      if ($DhcpService) {
        # Pull the service status so we can write it to the report. This way we don't have to
        # test for lots of different values, if we find it we show the status as it is.
        $Server.DHCPServiceStatus = $DhcpService.Status
        
        # Use NetSh to grab the DnsConfig from the DHCP service. Tested on Windows 2008 R2, but claims to be valid from 2000 and above.        
        $DnsConfig = Invoke-Expression "netsh dhcp server \\$($Server.Name) show dnsconfig"
        
        # If we have a value for DnsConfig
        if ($DnsConfig) {
          # Use a set of regular expressions to parse it, pulling out the state of each element.
          # Write these values to the report.
          switch -RegEx ($DnsConfig) {
            '^Dynamic update[^:]+: (\w+)\.?'  { $Server.DnsUpdateEnabled = $Matches[1] }
            '^client acquires[^:]+: (.+)$'    { $Server.DnsUpdateSetting = $Matches[1] }
            '^Discard forward[^:]+: (\w+)\.?' { $Server.DnsDiscardForwardLookups = $Matches[1] }
            '^Do update[^:]+: (\w+)\.?'       { $Server.DnsUpdateNonDynamicClients = $Matches[1] }
          }
        }
      }
    }
    # The object we created for the report is now complete. Leave it as output so Export-Csv can pick it up below.
    $Server
  # The trailing } is required (it completes the ForEach-Object loop).
  # Results are exported to this CSV file name under the current path.
  } | Export-Csv 'c:\temp\DhcpServers.csv' -NoTypeInformation