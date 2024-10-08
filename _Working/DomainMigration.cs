using System;
using System.DirectoryServices;
using System.DirectoryServices.ActiveDirectory;
using System.Net;
using System.Net.NetworkInformation;
using System.Security;

/// <summary>
/// Manages the process of migrating domains by creating trust relationships and configuring DNS forwarders.
/// </summary>
class DomainMigration
{
    /// <summary>
    /// The main entry point for the domain migration process.
    /// </summary>
    /// <param name="args">Command line arguments.</param>
    [STAThread]
    static int Main(string[] args)
    {
        // Check for help argument
        if (args.Length > 0 && (args[0] == "--help" || args[0] == "-h"))
        {
            DisplayHelp();
            return 0;
        }

        #region Step 1: Add conditional forwarder to local DC
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.WriteLine("1. Add a conditional forwarder on this DC to the remote forest");
        Console.ResetColor();

        Console.Write("Enter the DNS domain of the remote forest: ");
        string dnsName = Console.ReadLine();

        Console.Write("Enter the remote forest DC IP: ");
        string dnsIP = Console.ReadLine();

        try
        {
            AddDnsServerConditionalForwarderZone(dnsName, dnsIP);
            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine($"{dnsName} has been added to conditional forwarders\n");
            Console.ResetColor();
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine($"DNS conditional forwarder failed to add:\n\tError: {ex.Message}");
            Console.ResetColor();
            return 1;
        }
        #endregion

        #region Step 2: Add conditional forwarder to remote DC
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.WriteLine("2. Add a conditional forwarder on the remote DC to this forest");
        Console.ResetColor();

        Console.Write("Enter a remote forest account with admin rights (using DOMAIN\\Account): ");
        string remoteAdmin = Console.ReadLine();

        Console.Write("Enter the remote forest admin account's password: ");
        SecureString remoteAdminPassword = GetSecureString();

        string localIP = GetLocalIPAddress();

        Console.Write("Enter remote DC FQDN: ");
        string remoteFQDN = Console.ReadLine();

        string localRootDomain = Forest.GetCurrentForest().RootDomain.Name;

        try
        {
            AddRemoteDnsServerConditionalForwarderZone(remoteFQDN, remoteAdmin, remoteAdminPassword, localRootDomain, localIP);
            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine("Conditional forwarder to this domain has been successfully added on remote DC\n");
            Console.ResetColor();
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine($"Failed to add conditional forwarder on remote DC:\n\tError: {ex.Message}");
            Console.ResetColor();
            return 1;
        }
        #endregion

        #region Step 3: Create trust between forests
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.WriteLine("3. Create the trust between the 2 forests");
        Console.ResetColor();

        // Confirm user wants to proceed with trust creation
        bool validInputTrust;
        do
        {
            Console.Write($"A trust relationship will be created to forest {dnsName}, do you wish to continue? [y/n]: ");
            string validTrust = Console.ReadLine().ToLower();

            if (validTrust == "y")
            {
                validInputTrust = true;
            }
            else if (validTrust == "n")
            {
                return 0;
            }
            else
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("Invalid Input, try again");
                Console.ResetColor();
                validInputTrust = false;
            }
        } while (!validInputTrust);

        // Get trust direction from user
        TrustDirection trustDirection = TrustDirection.Bidirectional; // Default value
        bool validInput;
        do
        {
            Console.Write("Enter the trust direction: Bidirectional, Inbound, Outbound [B/I/O]: ");
            string strTrustDirection = Console.ReadLine().ToLower();

            switch (strTrustDirection)
            {
                case "b":
                    trustDirection = TrustDirection.Bidirectional;
                    validInput = true;
                    break;
                case "i":
                    trustDirection = TrustDirection.Inbound;
                    validInput = true;
                    break;
                case "o":
                    trustDirection = TrustDirection.Outbound;
                    validInput = true;
                    break;
                default:
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine("Invalid Input, Try again");
                    Console.ResetColor();
                    validInput = false;
                    continue;
            }

            // Confirm trust direction
            bool confirm;
            do
            {
                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.WriteLine($"Selected trust direction: {trustDirection}");
                Console.ResetColor();

                Console.Write("Proceed? [y/n]: ");
                string continueInput = Console.ReadLine().ToLower();

                if (continueInput == "y")
                {
                    confirm = true;
                }
                else if (continueInput == "n")
                {
                    confirm = false;
                    validInput = false;
                    break;
                }
                else
                {
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine("Invalid Input, Try again");
                    Console.ResetColor();
                    confirm = false;
                }
            } while (!confirm);

        } while (!validInput);

        Console.ForegroundColor = ConsoleColor.Yellow;
        Console.WriteLine($"Proceeding with Trust Direction: {trustDirection}...");
        Console.ResetColor();

        // Create trust relationship
        try
        {
            DirectoryContext remoteContext = new DirectoryContext(DirectoryContextType.Forest, dnsName, remoteAdmin, remoteAdminPassword);
            Forest localForest = Forest.GetCurrentForest();
            Forest remoteForest = Forest.GetForest(remoteContext);

            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine($"{remoteForest.Name} exists");
            Console.ResetColor();

            localForest.CreateTrustRelationship(remoteForest, trustDirection);

            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine($"{trustDirection} trust has been created with forest {remoteForest.Name}");
            Console.ResetColor();
        }
        catch (Exception ex)
        {
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine($"Could not create {trustDirection} trust with forest {dnsName}\n\tError: {ex.Message}");
            Console.ResetColor();
            return 1;
        }
        #endregion

        return 0;
    }

    /// <summary>
    /// Adds a conditional forwarder zone to the local DNS server.
    /// </summary>
    /// <param name="name">The DNS domain name for the conditional forwarder.</param>
    /// <param name="masterServer">The IP address of the master DNS server for the forwarded zone.</param>
    static void AddDnsServerConditionalForwarderZone(string name, string masterServer)
    {
        // Use DirectoryEntry to interact with the local DNS server
        using (DirectoryEntry dnsRoot = new DirectoryEntry("WinNT://./MicrosoftDNS"))
        {
            // Create a new DNS zone entry
            DirectoryEntry newZone = dnsRoot.Children.Add(name, "DnsZone");

            // Set the master server for the zone
            newZone.Properties["MasterServers"].Add(masterServer);

            // Set the zone type to conditional forwarder (type 4)
            newZone.Properties["ZoneType"].Value = 4;

            // Commit the changes to the DNS server
            newZone.CommitChanges();
        }
    }

    /// <summary>
    /// Adds a conditional forwarder zone to a remote DNS server.
    /// </summary>
    /// <param name="remoteFQDN">The FQDN of the remote DNS server.</param>
    /// <param name="remoteAdmin">The username with administrative rights on the remote server.</param>
    /// <param name="remoteAdminPassword">The password for the remote admin account.</param>
    /// <param name="localRootDomain">The root domain of the local forest.</param>
    /// <param name="localIP">The IP address of the local DNS server.</param>
    static void AddRemoteDnsServerConditionalForwarderZone(string remoteFQDN, string remoteAdmin, SecureString remoteAdminPassword, string localRootDomain, string localIP)
    {
        // Use DirectoryEntry to interact with the remote DNS server, providing credentials
        using (DirectoryEntry dnsRoot = new DirectoryEntry($"WinNT://{remoteFQDN}/MicrosoftDNS", remoteAdmin, new NetworkCredential(string.Empty, remoteAdminPassword).Password))
        {
            // Create a new DNS zone entry on the remote server
            DirectoryEntry newZone = dnsRoot.Children.Add(localRootDomain, "DnsZone");

            // Set the master server (local IP) for the zone
            newZone.Properties["MasterServers"].Add(localIP);

            // Set the zone type to conditional forwarder (type 4)
            newZone.Properties["ZoneType"].Value = 4;

            // Commit the changes to the remote DNS server
            newZone.CommitChanges();
        }
    }

    /// <summary>
    /// Displays help information for the Domain Migration tool.
    /// </summary>
    private static void DisplayHelp()
    {
        Console.WriteLine("Domain Migration Tool");
        Console.WriteLine("Usage: DomainMigration.exe [options]");
        Console.WriteLine();
        Console.WriteLine("Options:");
        Console.WriteLine("  --help, -h     Display this help message");
        Console.WriteLine();
        Console.WriteLine("Description:");
        Console.WriteLine("  This tool facilitates the process of migrating domains by creating");
        Console.WriteLine("  trust relationships and configuring DNS forwarders. It guides you");
        Console.WriteLine("  through the following steps:");
        Console.WriteLine("  1. Adding a conditional forwarder on the local DC to the remote forest");
        Console.WriteLine("  2. Adding a conditional forwarder on the remote DC to the local forest");
        Console.WriteLine("  3. Creating a trust relationship between the two forests");
        Console.WriteLine();
        Console.WriteLine("Note: This tool requires administrative privileges to perform");
        Console.WriteLine("      Active Directory and DNS operations.");
    }

    /// <summary>
    /// Retrieves the local IP address of the machine.
    /// </summary>
    /// <returns>The IPv4 address of the local machine as a string.</returns>
    static string GetLocalIPAddress()
    {
        // Get all IP addresses associated with the local host
        return Dns.GetHostEntry(Dns.GetHostName())
            .AddressList
            // Find the first IPv4 address
            .FirstOrDefault(ip => ip.AddressFamily == System.Net.Sockets.AddressFamily.InterNetwork)
            ?.ToString();
    }

    /// <summary>
    /// Securely reads a password from the console without displaying it.
    /// </summary>
    /// <returns>A SecureString containing the entered password.</returns>
    static SecureString GetSecureString()
    {
        SecureString secureString = new SecureString();
        ConsoleKeyInfo keyInfo;

        do
        {
            keyInfo = Console.ReadKey(true);
            if (keyInfo.Key != ConsoleKey.Enter)
            {
                secureString.AppendChar(keyInfo.KeyChar);
                Console.Write("*"); // Display asterisk for each character
            }
        } while (keyInfo.Key != ConsoleKey.Enter);

        Console.WriteLine();
        return secureString;
    }
}