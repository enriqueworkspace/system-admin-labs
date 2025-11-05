Lab 07: Implement Shared Samba Server
Objectives

Configured a Samba file-sharing server on Ubuntu.

Shared folders between Linux and Windows.

Tested cross-platform access and permissions.

Documented setup, testing, and troubleshooting steps.

Step 1: System Update and Install Samba
```
# Update the package list
sudo apt update

# Install Samba
sudo apt install samba -y
```


Explanation:
Updating ensures we have the latest packages. Installing Samba provides the tools to create shared folders accessible from Windows and other Linux systems.

Step 2: Create the Shared Folder
```
# Create the folder to share
sudo mkdir -p /srv/samba/shared

# Set permissions: owner/group can read/write, setgid to inherit group
sudo chmod 2770 /srv/samba/shared

# Set ownership to nobody:nogroup for guest access
sudo chown nobody:nogroup /srv/samba/shared
```


Explanation:

mkdir -p creates the folder, including parent directories if missing.

chmod 2770 sets read/write/execute for owner and group, and ensures new files inherit the group.

chown nobody:nogroup is required for guest access without a specific Samba user.

Step 3: Configure Samba Share
```
sudo nano /etc/samba/smb.conf
```

Add the following at the bottom of the file:
```
[SharedFolder]
   path = /srv/samba/shared
   browseable = yes
   read only = no
   guest ok = yes
```

Explanation:

[SharedFolder] is the share name that appears in Windows.

path specifies the folder to share.

browseable = yes makes it visible in network browsing.

read only = no allows writing to the folder.

guest ok = yes allows access without a Samba user, useful for testing.

Step 4: Apply Configuration
```
# Restart Samba to apply changes
sudo systemctl restart smbd

# Test Samba configuration for syntax errors
testparm

# Allow Samba through firewall
sudo ufw allow 'Samba'
```

Explanation:

Restarting Samba applies the new share.

testparm verifies the configuration for errors.

The firewall must allow Samba traffic for clients to connect.

Step 5: Access from Windows

Open File Explorer.

Enter the server path:
```
\\192.168.0.150\SharedFolder
```

Create a file, e.g., test.txt, write some text, and save.

Verify from Ubuntu:
```
ls -l /srv/samba/shared
cat /srv/samba/shared/test.txt
```

Explanation:
This confirms read/write access from Windows and proper folder integration.

Step 6: Troubleshooting Notes

Firewall issues: If Windows cannot connect, ensure Samba is allowed:
```
sudo ufw allow 'Samba'
```

Network discovery: On Windows, make sure “Network Discovery” and “File Sharing” are enabled.

Access control: If guest access is disabled or restricted, create a Samba user:
```
sudo adduser labuser
sudo smbpasswd -a labuser
sudo smbpasswd -e labuser
sudo chown labuser:nogroup /srv/samba/shared
```

Disconnecting clients: If Windows sessions remain open:
```
sudo smbstatus         # check active connections
sudo smbcontrol <PID> close-share SharedFolder
sudo kill <PID>        # force close if needed
```

Temporarily disabling the share: Comment out the [SharedFolder] section in smb.conf and restart Samba.

Step 7: Observations

Samba successfully shared a folder accessible from Windows.

File creation, reading, and writing worked correctly.

Firewall and network discovery are common points to check when troubleshooting.

Guest access simplifies testing, but creating a Samba user is recommended for controlled environments.