# Automated User Management in Linux

This lab covers automated user onboarding and basic offboarding in Linux using a Bash script that processes a CSV file. It addresses user creation, group assignment, password management, home directory permissions, and account disabling for secure access control.

## Overview
The process simulates administrative workflows for adding multiple users efficiently. The script handles group creation, secure defaults, and verification, reducing manual errors in production environments.

## Objectives
- Automate user creation from a CSV input.
- Assign primary and secondary groups dynamically.
- Set temporary passwords with enforced changes on first login.
- Secure home directories with 700 permissions.
- Disable user accounts for offboarding.

## Files

### onboarding.sh
This Bash script reads `users.csv` to perform the following:
- Create users and their home directories.
- Establish primary and secondary groups if absent.
- Assign a default password (`Welcome123!`) and require change on initial login.
- Set home directory permissions to 700 (owner-only access).
- Disable a specified user (e.g., `rbrown`) as an offboarding example.

### users.csv
CSV file with user data in the format:
```
username,full_name,primary_group,secondary_groups
jdoe,John Doe,development,"sales,management"
asmith,Alice Smith,sales,"development"
rbrown,Robert Brown,management,"sales"
```
- `secondary_groups`: Comma-separated list in quotes for parsing.

## Usage Instructions
Prepare the CSV for Unix compatibility:
```
dos2unix users.csv
```

Make the script executable:
```
chmod +x onboarding.sh
```

Execute as root:
```
sudo ./onboarding.sh
```

## Expected Output
- Users `jdoe`, `asmith`, and `rbrown` are added with assigned primary/secondary groups.
- Home directories (`/home/<username>`) are created with 700 permissions.
- Default password `Welcome123!` is applied, with first-login change enforced via `chage`.
- Account `rbrown` is locked (disabled) post-creation.

Script output includes confirmation messages for each action, such as group/user creation and permission updates.

## Verification
Confirm users (system users start at UID 1000):
```
awk -F: '$3 >= 1000 {print $1}' /etc/passwd
```
Expected: `jdoe asmith rbrown`.

Check groups:
```
getent group | grep -E 'development|sales|management'
```
Expected: Entries for each group with member lists.

Inspect home directories:
```
ls -ld /home/jdoe /home/asmith /home/rbrown
```
Expected: `drwx------` permissions.

Verify disabled account:
```
sudo passwd -S rbrown
```
Expected: Status shows `L` (locked).
