# Domain Migration Tool

This tool facilitates the process of migrating domains by creating trust relationships and configuring DNS forwarders.

## Project Structure

- `DomainMigration.cs`: Contains the main logic for domain migration.
- `DomainMigrationTests.cs`: Contains unit tests for the DomainMigration class.

## Dependencies

- .NET Framework (version 4.7.2 or later recommended)
- NUnit (for running tests)
- Moq (for mocking objects in tests)

## Setting Up the Project

1. Ensure you have the .NET Framework installed on your system.
2. Install the required NuGet packages:
   - NUnit
   - NUnit3TestAdapter (for running tests in Visual Studio)
   - Moq

You can install these packages using the NuGet Package Manager in Visual Studio or by running the following commands in the Package Manager Console:

```
Install-Package NUnit
Install-Package NUnit3TestAdapter
Install-Package Moq
```

## Running the Tests

1. Open the solution in Visual Studio.
2. Build the solution (Build > Build Solution).
3. Open the Test Explorer (Test > Windows > Test Explorer).
4. Click "Run All" in the Test Explorer to run all tests.

Alternatively, you can run the tests using the `dotnet test` command in the terminal:

```
dotnet test
```

## Running the Domain Migration Tool

To run the Domain Migration tool:

1. Compile the DomainMigration.cs file:
   ```
   csc /reference:System.DirectoryServices.dll,System.DirectoryServices.ActiveDirectory.dll DomainMigration.cs
   ```
2. Run the compiled executable:
   ```
   DomainMigration.exe
   ```

### Command-line Options

The tool now supports a help option:

- `--help` or `-h`: Displays usage information and a brief description of the tool.

Example:
```
DomainMigration.exe --help
```

This will display information about the tool's functionality and usage.

Note: Running this tool requires administrative privileges as it performs Active Directory and DNS operations.

## Contributing

When contributing to this project, please:

1. Write unit tests for any new functionality.
2. Ensure all existing tests pass before submitting a pull request.
3. Follow the existing code style and commenting practices.
4. Update the README if you add any new dependencies or change the project structure.

## License

[Specify your license here]