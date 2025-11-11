# az-ad-ops.ps1
# Purpose: Perform sample operations in Azure AD

# Log file
$logFile = "C:\Scripts\az-ad-ops-log.txt"

function Write-Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -FilePath $logFile -Append
}

Write-Log "=== Starting Azure AD operations ==="

# Verify session
try {
    $testConn = Get-AzureADTenantDetail
    Write-Log "Connection verified. Tenant: $($testConn.DisplayName)"
} catch {
    Write-Log "Not connected. Please run setup-azuread.ps1 first."
    exit 1
}

# Example 1: List first 5 users
try {
    Write-Log "Listing first 5 users..."
    $users = Get-AzureADUser -Top 5
    $users | ForEach-Object { Write-Log "User: $($_.DisplayName) - $($_.UserPrincipalName)" }
} catch {
    Write-Log "Error listing users: $_"
}

# Example 2: List first 5 groups
try {
    Write-Log "Listing first 5 groups..."
    $groups = Get-AzureADGroup -Top 5
    $groups | ForEach-Object { Write-Log "Group: $($_.DisplayName)" }
} catch {
    Write-Log "Error listing groups: $_"
}

# Example 3: Create sample group (idempotent)
$groupName = "Lab-Test-Group"
try {
    $existing = Get-AzureADGroup -All $true | Where-Object { $_.DisplayName -eq $groupName }
    if ($existing) {
        Write-Log "Group '$groupName' already exists. Skipping creation."
    } else {
        New-AzureADGroup -DisplayName $groupName -MailEnabled $false -SecurityEnabled $true -MailNickname "LabTestGroup"
        Write-Log "Group '$groupName' created successfully."
    }
} catch {
    Write-Log "Error creating or checking group: $_"
}

Write-Log "=== Azure AD operations completed successfully ==="
exit 0
