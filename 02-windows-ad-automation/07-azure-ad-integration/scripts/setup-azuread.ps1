# setup-azuread.ps1
# Purpose: Install and connect to Azure AD from Windows Server 2022

# Log file
$logFile = "C:\Scripts\setup-azuread-log.txt"

# Function for logging
function Write-Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -FilePath $logFile -Append
}

Write-Log "=== Starting Azure AD setup ==="

# Step 1: Check for AzureAD module
if (!(Get-Module -ListAvailable -Name AzureAD)) {
    Write-Log "AzureAD module not found. Installing..."
    try {
        Install-Module -Name AzureAD -Force -AllowClobber -ErrorAction Stop
        Write-Log "AzureAD module installed successfully."
    } catch {
        Write-Log "Error installing AzureAD module: $_"
        exit 1
    }
} else {
    Write-Log "AzureAD module already installed."
}

# Step 2: Import module
try {
    Import-Module AzureAD -ErrorAction Stop
    Write-Log "AzureAD module imported."
} catch {
    Write-Log "Failed to import AzureAD module: $_"
    exit 1
}

# Step 3: Connect to Azure AD
try {
    Write-Log "Attempting connection to Azure AD..."
    Connect-AzureAD
    Write-Log "Connected successfully."
} catch {
    Write-Log "Connection failed: $_"
    exit 1
}

# Step 4: Verify connection
try {
    $tenant = Get-AzureADTenantDetail
    Write-Log "Connected to tenant: $($tenant.DisplayName)"
} catch {
    Write-Log "Unable to verify connection: $_"
    exit 1
}

Write-Log "=== Azure AD setup completed successfully ==="
exit 0
