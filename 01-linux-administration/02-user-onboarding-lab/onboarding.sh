#!/bin/bash

# ----------------------------------------------------
# AUTOMATED USER ONBOARDING SCRIPT (GITHUB LAB)
# Demonstrates: Bulk Creation, Group Management, Security
# Usage: sudo bash onboarding.sh
# ----------------------------------------------------

# Input data file (excludes comments and empty lines)
USER_FILE="users.csv"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ ERROR: This script must be run as root (using sudo)."
    exit 1
fi

echo "🚀 Starting User Onboarding Process..."

# 1. Main loop to process each user
# Uses IFS (Internal Field Separator) to handle commas and reads the file
grep -v '^#' "$USER_FILE" | while IFS=, read -r username full_name primary_group secondary_groups || [ -n "$username" ]; do

    # Clean up surrounding whitespace from variables
    username=$(echo "$username" | xargs)
    full_name=$(echo "$full_name" | xargs)
    primary_group=$(echo "$primary_group" | xargs)
    secondary_groups=$(echo "$secondary_groups" | tr -d '"' | xargs) # Remove quotes from group list

    if [ -z "$username" ]; then
        continue
    fi
    
    echo "----------------------------------------"
    echo "👤 Processing user: $username ($full_name)"

    # --- Point 2: Create Primary Group (if it doesn't exist) ---
    if ! getent group "$primary_group" >/dev/null; then
        echo "   -> Creating primary group: $primary_group"
        groupadd "$primary_group"
    fi

    # --- Point 1, 5: User and Home Directory Creation ---
    # -m: Creates the home directory
    # -g: Assigns the primary group
    # -c: Adds the full name (comment)
    if useradd -m -g "$primary_group" -c "$full_name" "$username"; then
        echo "   ✅ User and Home directory created."

        # --- Point 3: Assigning Secondary Groups ---
        IFS=',' read -ra ADDR <<< "$secondary_groups"
        for GRP in "${ADDR[@]}"; do
            GRP=$(echo "$GRP" | xargs)
            if [ -n "$GRP" ]; then
                if ! getent group "$GRP" >/dev/null; then
                    echo "   -> Creating secondary group: $GRP"
                    groupadd "$GRP"
                fi
                echo "   -> Adding user to secondary group: $GRP"
                usermod -aG "$GRP" "$username"
            fi
        done

        # --- Point 4: Security Configuration (Password and Forced Change) ---
        # Generate a simple initial password (for lab demonstration)
        INITIAL_PASS="Welcome123!" 
        echo "$username:$INITIAL_PASS" | chpasswd
        
        # Force user to change password on first login
        chage -d 0 "$username" 
        echo "   🔒 Initial password set. Change forced upon first login."

        # --- Point 5 (Cont.): Home Directory Permissions ---
        # Set rwx permissions only for the owner (basic segregation)
        chmod 700 "/home/$username"
        echo "   📂 Home permissions configured (chmod 700)."

    else
        echo "   ❌ ERROR: Failed to create user $username."
    fi
done

# --- Point 6: Access Control Demonstration (e.g., Disabling a test account) ---
echo "----------------------------------------"
echo "♻️ Demonstrating Basic Offboarding/Access Control (Disabling 'rbrown')"
if id "rbrown" &>/dev/null; then
    usermod -L "rbrown"  # Lock the user's password (disabling the account)
    echo "   🛑 User 'rbrown' has been disabled (password locked)."
else
    echo "   (User 'rbrown' does not exist, skipping disablement.)"
fi

echo "✅ Onboarding process completed."