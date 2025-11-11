Azure AD Integration Lab

Lab Overview



This lab demonstrates how to integrate an on-premises Windows Server 2022 environment with Azure Active Directory (Azure AD).



Objectives:



Install and configure required PowerShell modules (AzureAD).



Connect to Azure AD from an on-premises VM.



Perform basic Azure AD operations such as listing users, creating groups, and managing memberships.



Log all actions and results.



This lab highlights hybrid administration skills and cloud identity management.



Scripts Description

1\. setup-azuread.ps1



Purpose:



Installs and imports the AzureAD PowerShell module.



Verifies internet connectivity and module installation.



Connects to Azure AD.



Logs actions and errors to setup-azuread-log.txt.



Example usage:



C:\\Scripts\\setup-azuread.ps1





Expected log excerpt:



2025-11-10 17:54:01 - AzureAD module installed successfully.

2025-11-10 17:54:01 - AzureAD module imported.

2025-11-10 17:54:01 - Connected to Azure AD tenant successfully.



2\. az-ad-ops.ps1



Purpose:



Performs sample Azure AD operations:



Lists all users.



Creates a test group (Lab-Test-Group).



Adds users to the test group.



Ensures idempotent behavior: repeated runs do not duplicate objects.



Logs all actions to az-ad-ops-log.txt.



Example usage:



C:\\Scripts\\az-ad-ops.ps1





Expected log excerpt:



2025-11-10 18:08:53 - === Starting Azure AD operations ===

2025-11-10 18:09:00 - Connected to Azure AD successfully.

2025-11-10 18:09:01 - Users listed: 10

2025-11-10 18:09:02 - Lab-Test-Group verified/created successfully.

2025-11-10 18:09:03 - Users assigned to Lab-Test-Group successfully.



Verification Commands



After running the scripts, verify results:



\# List first 10 users

Get-AzureADUser -Top 10



\# List first 10 groups

Get-AzureADGroup -Top 10



\# Confirm Lab-Test-Group exists

Get-AzureADGroup -All $true | Where-Object { $\_.DisplayName -eq "Lab-Test-Group" }



\# List members of Lab-Test-Group

Get-AzureADGroupMember -ObjectId (Get-AzureADGroup -Filter "DisplayName eq 'Lab-Test-Group'").ObjectId

