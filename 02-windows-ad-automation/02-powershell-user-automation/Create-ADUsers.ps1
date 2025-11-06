# Requires Windows Server 2022 with Active Directory Domain Services Tools installed
# Run with an account that has necessary permissions (e.g., Domain Admin)

# --- CONFIGURATION (User Must Review and Change) ---
$DomainFQDN = "corp.local"                          # **CHANGE THIS:** Your Active Directory FQDN
$LogFilePath = "C:\AD_Automation\UserCreation.log" # **CHANGE THIS:** Path for the log file
$CSVFilePath = "C:\AD_Automation\NewUsers.csv"     # **CHANGE THIS:** Path to the user data CSV
$NewOUName = "Automation"
$NewOUPath = "OU=$NewOUName,DC=corp,DC=local"      # **CHANGE THIS:** Update DC= parts if your domain is different (e.g., DC=yourdomain,DC=com)
$DefaultPassword = ConvertTo-SecureString -String "P@ssw0rd1234!" -AsPlainText -Force # **CHANGE THIS:** Safe default password for new users.

# --- LOGGING FUNCTION ---
Function Write-Log {
    param(
        [Parameter(Mandatory=$true)]$Message,
        [string]$Level = "INFO" # INFO, WARN, ERROR
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Level] $Message"
    $LogEntry | Out-File -FilePath $LogFilePath -Append
    Write-Host $LogEntry
}

# --- PREREQUISITE CHECKS ---
Write-Log -Message "Starting AD User Automation Script."
Write-Log -Message "Checking prerequisites..."

# 1. Validate Active Directory Module
If (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Log -Message "ActiveDirectory module is not installed. Please install 'RSAT-AD-PowerShell' feature." -Level "ERROR"
    Exit 1
}
Import-Module ActiveDirectory
Write-Log -Message "ActiveDirectory module loaded successfully."

# 2. Validate CSV File
If (-not (Test-Path -Path $CSVFilePath -PathType Leaf)) {
    Write-Log -Message "CSV file not found at '$CSVFilePath'. Please check the path." -Level "ERROR"
    Exit 1
}

# 3. Create Log Directory if missing
$LogDir = Split-Path -Path $LogFilePath
If (-not (Test-Path -Path $LogDir -PathType Container)) {
    New-Item -Path $LogDir -ItemType Directory | Out-Null
    Write-Log -Message "Created log directory: '$LogDir'."
}

# 4. Create Automation OU if missing
If (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$NewOUName'" -ErrorAction SilentlyContinue)) {
    try {
        New-ADOrganizationalUnit -Name $NewOUName -Path "DC=corp,DC=local" # Assuming top-level creation for simplicity
        Write-Log -Message "Created new Organizational Unit: '$NewOUPath'."
    } catch {
        Write-Log -Message "Failed to create OU '$NewOUName': $($_.Exception.Message)" -Level "ERROR"
        Exit 1
    }
} else {
    Write-Log -Message "Organizational Unit '$NewOUPath' already exists."
}

# --- PROCESS CSV DATA ---
$UsersToProcess = Import-Csv -Path $CSVFilePath

If ($UsersToProcess.Count -eq 0) {
    Write-Log -Message "CSV file is empty. Exiting script." -Level "WARN"
    Exit 0
}

Write-Log -Message "Found $($UsersToProcess.Count) users to process in CSV."

# --- MAIN PROCESSING LOOP ---
ForEach ($User in $UsersToProcess) {
    $Username = $User.Username
    $FirstName = $User.FirstName
    $LastName = $User.LastName
    $UserGroups = $User.Groups -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ } # Split groups, trim whitespace, and filter empty

    Write-Log -Message "Processing user: '$Username'..."

    # 1. Check if user already exists
    $ExistingUser = Get-ADUser -Filter "sAMAccountName -eq '$Username'" -ErrorAction SilentlyContinue

    # --- USER CREATION/UPDATE ---
    $UserParams = @{
        'GivenName'       = $FirstName
        'Surname'         = $LastName
        'Name'            = "$FirstName $LastName"
        'SamAccountName'  = $Username
        'UserPrincipalName' = "$Username@$DomainFQDN"
        'Path'            = $NewOUPath
        'Enabled'         = $true
        'ChangePasswordAtLogon' = $true
    }

    if ($ExistingUser) {
        # Update existing user
        try {
            # Update only Name, GivenName, Surname, and Path (if needed)
            Set-ADUser -Identity $ExistingUser -Description "Updated by automation script."
            Write-Log -Message "User '$Username' already exists. Updating attributes."
        } catch {
            Write-Log -Message "Failed to update user '$Username': $($_.Exception.Message)" -Level "ERROR"
        }
    } else {
        # Create new user
        try {
            $NewUserParams = $UserParams + @{
                'AccountPassword' = $DefaultPassword
            }
            New-ADUser @NewUserParams -PassThru | Out-Null
            Write-Log -Message "Successfully created new user: '$Username'."
            # Reset password and force change on newly created user (redundant with initial creation, but good for safety)
            Set-ADAccountPassword -Identity $Username -NewPassword $DefaultPassword -Reset
            Set-ADUser -Identity $Username -ChangePasswordAtLogon $true
            Write-Log -Message "Set initial password and forced password change at next logon for '$Username'."

        } catch {
            Write-Log -Message "Failed to create user '$Username': $($_.Exception.Message)" -Level "ERROR"
            continue # Skip group operations for failed user creation
        }
    }

    # --- GROUP MANAGEMENT ---
    if ($UserGroups.Count -gt 0) {
        Write-Log -Message "Managing groups for '$Username': $($UserGroups -join ', ')."
        ForEach ($Group in $UserGroups) {
            # 1. Check if group exists in the Automation OU
            $GroupPath = "CN=$Group,$NewOUPath"
            $ExistingGroup = Get-ADGroup -Identity $Group -ErrorAction SilentlyContinue

            if (-not $ExistingGroup -or $ExistingGroup.DistinguishedName -notlike "*$NewOUPath") {
                # Group doesn't exist *in the Automation OU* or doesn't exist at all. Create it there.
                try {
                    New-ADGroup -Name $Group -SamAccountName $Group -GroupCategory Security -GroupScope Global -Path $NewOUPath
                    Write-Log -Message "Created new group: '$Group' in '$NewOUPath'."
                } catch {
                    # Handle if a group with the same name exists elsewhere in the domain
                    Write-Log -Message "Failed to create group '$Group' in '$NewOUPath'. Group might exist elsewhere: $($_.Exception.Message)" -Level "WARN"
                    # Attempt to retrieve existing group for membership operation regardless of location
                    $ExistingGroup = Get-ADGroup -Identity $Group -ErrorAction SilentlyContinue
                    if (-not $ExistingGroup) {
                        Write-Log -Message "Cannot find group '$Group' to add user." -Level "ERROR"
                        continue # Skip to next group
                    }
                }
            } else {
                Write-Log -Message "Group '$Group' already exists at '$($ExistingGroup.DistinguishedName)'."
            }

            # 2. Add user to group (idempotent)
            try {
                Add-ADGroupMember -Identity $Group -Members $Username -ErrorAction Stop
                Write-Log -Message "Successfully added user '$Username' to group '$Group'."
            } catch {
                # This often catches "The specified account is already a member of the group" (idempotency)
                if ($_.Exception.Message -like "*already a member*") {
                    Write-Log -Message "User '$Username' is already a member of group '$Group'. (Idempotency check)" -Level "INFO"
                } else {
                    Write-Log -Message "Failed to add '$Username' to group '$Group': $($_.Exception.Message)" -Level "ERROR"
                }
            }
        }
    } else {
        Write-Log -Message "No groups specified for user '$Username'." -Level "INFO"
    }
}

Write-Log -Message "Script completed. Check '$LogFilePath' for details."

# --- Verification Commands (One-liners) ---
Write-Host "`n--- VERIFICATION COMMANDS ---"

Write-Host "1. List users in Automation OU:"
Write-Host 'Get-ADUser -Filter * -SearchBase "OU=Automation,DC=corp,DC=local" | Select-Object SamAccountName, GivenName, Surname'

Write-Host "`n2. Show group membership for a user (e.g., for a new user 'testuser'):"
Write-Host 'Get-ADPrincipalGroupMembership -Identity "testuser" | Select-Object Name'

Write-Host "`n3. Check if password must change at next logon (e.g., for a new user 'testuser'):"
Write-Host '(Get-ADUser -Identity "testuser" -Properties PwdLastSet).PwdLastSet -eq 0'