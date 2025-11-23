# Azure AD Integration Lab

This lab integrates an on-premises Windows Server 2022 VM with Azure Active Directory (Azure AD) using PowerShell, enabling hybrid identity management. It covers module installation, connection, user/group operations, and logging for auditing.

## 1. Scripts Description

### 1.1 setup-azuread.ps1
Installs the AzureAD module, verifies connectivity, connects to the tenant, and logs to `setup-azuread-log.txt`.

Usage:
```
C:\Scripts\setup-azuread.ps1
```

Expected log:
```
2025-11-10 17:54:01 - AzureAD module installed successfully.
2025-11-10 17:54:01 - AzureAD module imported.
2025-11-10 17:54:01 - Connected to Azure AD tenant successfully.
```

### 1.2 az-ad-ops.ps1
Lists users, creates/verifies "Lab-Test-Group", assigns members idempotently, and logs to `az-ad-ops-log.txt`.

Usage:
```
C:\Scripts\az-ad-ops.ps1
```

Expected log:
```
2025-11-10 18:08:53 - === Starting Azure AD operations ===
2025-11-10 18:09:00 - Connected to Azure AD successfully.
2025-11-10 18:09:01 - Users listed: 10
2025-11-10 18:09:02 - Lab-Test-Group verified/created successfully.
2025-11-10 18:09:03 - Users assigned to Lab-Test-Group successfully.
```

## 2. Verification Commands
Confirm operations post-execution:

List users:
```
Get-AzureADUser -Top 10
```

List groups:
```
Get-AzureADGroup -Top 10
```

Verify group:
```
Get-AzureADGroup -All $true | Where-Object { $_.DisplayName -eq "Lab-Test-Group" }
```

List members:
```
Get-AzureADGroupMember -ObjectId (Get-AzureADGroup -Filter "DisplayName eq 'Lab-Test-Group'").ObjectId
```

## Summary
- AzureAD module installed and imported via `setup-azuread.ps1`.
- Operations (user listing, group creation/membership) executed idempotently via `az-ad-ops.ps1`.
- All actions logged; verifications confirm tenant connectivity and object management.

This setup bridges on-premises and cloud identities for unified administration.
