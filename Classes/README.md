# Active Directory Classes

## Overview

This repository contains a collection of PowerShell scripts designed to automate various administrative tasks. These scripts are intended to simplify and streamline processes such as Active Directory management, system monitoring, and other routine operations.

## Contents

- **ADUser.ps1**: A script for managing Active Directory users, including creating, enabling, disabling, and updating user accounts.
- **Logger.ps1**: A logging utility to record script activities and errors.
- **TestADUser.ps1**: A script to test the functionality of the `ADUser.ps1` script.

## ADUser.ps1

### Description

The `ADUser.ps1` script provides a comprehensive set of functions for managing Active Directory user accounts. It includes methods for creating new users, enabling/disabling accounts, setting passwords, and updating user properties.

### Features

- **CreateNewUser**: Creates a new Active Directory user with specified properties.
- **Enable**: Enables a specified Active Directory user account.
- **Disable**: Disables a specified Active Directory user account.
- **SetPassword**: Sets a new password for a specified Active Directory user account.
- **SetDescription**: Updates the description for a specified Active Directory user account.
- **SetCompany**: Updates the company attribute for a specified Active Directory user account.
- **ClearExpiration**: Clears the account expiration date for a specified Active Directory user account.
- **AddToGroup**: Adds a specified Active Directory user to a specified group.
- **GetGroupMemberships**: Retrieves the group memberships for a specified Active Directory user account.

### Usage

To use the `ADUser.ps1` script, you need to import it into your PowerShell session and create an instance of the `ADUser` class. Here is an example:

```powershell
# Import the ADUser.ps1 script
. ./Classes/ADUser.ps1

# Create an instance of the ADUser class
$adUser = [ADUser]::new("jdoe")

# Create a new AD user
$adUser.CreateNewUser("John", "Doe", "jdoe", $true)