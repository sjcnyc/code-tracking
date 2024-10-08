using NUnit.Framework;
using Moq;
using System;
using System.DirectoryServices;
using System.DirectoryServices.ActiveDirectory;
using System.Security;

[TestFixture]
public class DomainMigrationTests
{
    private Mock<DirectoryEntry> mockDnsRoot;
    private Mock<DirectoryEntry> mockNewZone;
    private Mock<PropertyCollection> mockProperties;
    private Mock<PropertyValueCollection> mockMasterServers;
    private Mock<PropertyValueCollection> mockZoneType;

    [SetUp]
    public void Setup()
    {
        mockDnsRoot = new Mock<DirectoryEntry>();
        mockNewZone = new Mock<DirectoryEntry>();
        mockProperties = new Mock<PropertyCollection>();
        mockMasterServers = new Mock<PropertyValueCollection>();
        mockZoneType = new Mock<PropertyValueCollection>();

        mockDnsRoot.Setup(m => m.Children).Returns(new MockDirectoryEntries(mockNewZone.Object));
        mockNewZone.Setup(m => m.Properties).Returns(mockProperties.Object);
        mockProperties.Setup(m => m["MasterServers"]).Returns(mockMasterServers.Object);
        mockProperties.Setup(m => m["ZoneType"]).Returns(mockZoneType.Object);
    }

    [Test]
    public void AddDnsServerConditionalForwarderZone_ShouldAddZoneCorrectly()
    {
        // Arrange
        string dnsName = "test.com";
        string masterServer = "192.168.1.1";

        // Act
        DomainMigration.AddDnsServerConditionalForwarderZone(dnsName, masterServer);

        // Assert
        mockDnsRoot.Verify(m => m.Children.Add(dnsName, "DnsZone"), Times.Once);
        mockMasterServers.Verify(m => m.Add(masterServer), Times.Once);
        mockZoneType.Verify(m => m.Value = 4, Times.Once);
        mockNewZone.Verify(m => m.CommitChanges(), Times.Once);
    }

    [Test]
    public void GetSecureString_ShouldReturnSecureString()
    {
        // Arrange
        string testInput = "password";
        var consoleInput = new StringReader(testInput + Environment.NewLine);
        Console.SetIn(consoleInput);

        // Act
        SecureString result = DomainMigration.GetSecureString();

        // Assert
        Assert.That(result, Is.Not.Null);
        Assert.That(result.Length, Is.EqualTo(testInput.Length));
    }

    // Mock class for DirectoryEntries
    private class MockDirectoryEntries : System.DirectoryServices.DirectoryEntries
    {
        private readonly DirectoryEntry _mockEntry;

        public MockDirectoryEntries(DirectoryEntry mockEntry)
        {
            _mockEntry = mockEntry;
        }

        public override DirectoryEntry Add(string name, string schemaClassName)
        {
            return _mockEntry;
        }
    }
}