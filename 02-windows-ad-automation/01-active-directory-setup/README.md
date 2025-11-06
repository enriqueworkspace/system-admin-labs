Lab 01: Installation and Configuration of an Active Directory Domain

Overview

This lab demonstrates the installation and configuration of a Windows Server as an Active Directory Domain Controller (DC). It covers:

*Installing the Active Directory Domain Services (AD DS) role.
*Promoting the server to a DC and creating a new domain.
*Creating Organizational Units (OUs), users, and groups.
*Verifying AD functionality and connectivity.
*All tasks in this lab were performed entirely using PowerShell, without using GUI tools.

---

Step 0: Connect to the Windows Server via RDP

Before starting the lab, I connected to the Windows Server VM using Remote Desktop Protocol (RDP) from another PC.


All commands to configure and access RDP were executed in PowerShell, maintaining the lab focus on command-line operations.

Enable Remote Desktop via PowerShell

```
# Check current Remote Desktop status

Get-ItemProperty -Path "HKLM:\System\CurrentControlSe\Control\Terminal Server" -Name "fDenyTSConnections"
```
Reads the registry key fDenyTSConnections.
Value 1 → RDP is disabled.
Value 0 → RDP is enabled.
```
# Enable Remote Desktop

Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
```

Changes the registry value to 0, enabling RDP connections.
This allows remote PCs to connect to the server.
```
# Enable Remote Desktop firewall rule

Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
```
Opens the Windows Firewall for RDP connections.
Ensures that external machines can reach the server on TCP port 3389.

```
# Optional: verify firewall rule is enabled

Get-NetFirewallRule -DisplayGroup "Remote Desktop"
```
Confirms that the firewall allows RDP traffic.
Connect from another PC
Open the Run dialog on the client machine.

Execute:

```
mstsc /v:192.168.0.121
```

Replace 192.168.0.121 with the server’s IP address.
Enter administrator credentials when prompted.

This approach ensured full remote access via RDP, allowing me to perform all subsequent AD setup commands entirely in PowerShell.

---

Step 1: Configure Static IP and DNS

Active Directory requires a static IP and a stable DNS configuration for proper domain functionality.

Commands and Explanation

```
# List network adapters to identify the correct interface

Get-NetAdapter
```
Shows all network interfaces and their names. Needed to configure the static IP.

```
# Assign a static IP address

New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress 192.168.0.121 -PrefixLength 24 -DefaultGateway 192.168.1.1
```
InterfaceAlias: the network adapter name.

IPAddress: static IP of the server.

PrefixLength 24: subnet mask 255.255.255.0.

DefaultGateway: network gateway.

```
# Set the server's own IP as DNS

Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.0.121
```
Points DNS to the server itself, required for Active Directory installation.


Verification

```
# Check the assigned IP address

Get-NetIPAddress -InterfaceAlias "Ethernet"


# Check DNS server configuration

Get-DnsClientServerAddress -InterfaceAlias "Ethernet"


# Optional: test connectivity to an external IP

Test-Connection 8.8.8.8
```

Step 2: Install the Active Directory Domain Services (AD DS) Role

```
# Install AD DS role with management tools

Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
```

AD-Domain-Services: installs core Active Directory functionality.

IncludeManagementTools: installs administrative tools such as Active Directory Users and Computers.

Verification

```
# Check installation status

Get-WindowsFeature -Name AD-Domain-Services
```

The Installed column should show True.

```
# Check AD-related features

Get-WindowsFeature | Where-Object {$_.Name -like "*AD*"}
```

Lists all installed AD features.

```
# Import deployment module to confirm availability

Import-Module ADDSDeployment
```

Confirms that the module required for promoting the server to a DC is available.

```
# Check AD DS service status

Get-Service -Name ntds
```

Expected to show Stopped before promotion to DC.


Step 3: Promote the Server to a Domain Controller

```
Import-Module ADDSDeployment
```
Loads the module necessary to deploy Active Directory.

```
Install-ADDSForest `
-DomainName "corp.local" `
-DomainNetbiosName "CORP" `
-InstallDns `
-CreateDnsDelegation:$false `
-SafeModeAdministratorPassword (ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force) `
-Force
```
Explanation of Parameters

DomainName: full domain name to create.

DomainNetbiosName: short name of the domain.

InstallDns: installs a DNS server on the DC.

CreateDnsDelegation:$false: do not create an external DNS delegation.

SafeModeAdministratorPassword: password for Directory Services Restore Mode (DSRM).

Force: executes without interactive prompts.

After executing this command, the server automatically restarts and becomes the first domain controller of corp.local.


Step 4: Create Organizational Units (OUs), Groups, and Users

After the DC is ready, the Active Directory environment can be structured logically.
```
# Import the AD module to manage objects

Import-Module ActiveDirectory
```

Create Organizational Units
```
New-ADOrganizationalUnit -Name "IT" -Path "DC=corp,DC=local"

New-ADOrganizationalUnit -Name "HR" -Path "DC=corp,DC=local"
```
IT and HR are OUs to group users and groups by department.

Create Groups

```
New-ADGroup -Name "IT-Admins" -GroupScope Global -Path "OU=IT,DC=corp,DC=local"

New-ADGroup -Name "HR-Staff" -GroupScope Global -Path "OU=HR,DC=corp,DC=local"
```
Groups allow collective permission assignments.
GroupScope Global makes the group usable across the domain.

Create Users
```
New-ADUser -Name "John Smith" -GivenName "John" -Surname "Smith" -SamAccountName "jsmith" -AccountPassword (ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force) -Enabled $true -Path "OU=IT,DC=corp,DC=local"

New-ADUser -Name "Mary Jones" -GivenName "Mary" -Surname "Jones" -SamAccountName "mjones" -AccountPassword (ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force) -Enabled $true -Path "OU=HR,DC=corp,DC=local"
```
Users are created with initial passwords and enabled.

SamAccountName is the login username.


Add Users to Groups
```
Add-ADGroupMember -Identity "IT-Admins" -Members "jsmith"

Add-ADGroupMember -Identity "HR-Staff" -Members "mjones"
```
Assigns users to their respective groups.


Step 5: Verify the Configuration

```
# View all OUs

Get-ADOrganizationalUnit -Filter *


# View users in IT OU

Get-ADUser -Filter * -SearchBase "OU=IT,DC=corp,DC=local"


# View users in HR OU

Get-ADUser -Filter * -SearchBase "OU=HR,DC=corp,DC=local"


# View group members

Get-ADGroupMember -Identity "IT-Admins"

Get-ADGroupMember -Identity "HR-Staff"
```
Confirms that OUs, users, and groups were correctly created and assigned.

