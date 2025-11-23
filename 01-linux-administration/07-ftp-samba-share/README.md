# Samba Shared Folder Implementation

This lab configures a Samba server on Ubuntu for sharing folders with Windows clients, enabling read/write access, guest permissions, and firewall integration. It includes testing and resolution of common issues.

## 1. System Update and Install Samba
Update packages and install Samba:
```
sudo apt update
sudo apt install samba -y
```
This ensures current packages and provides Samba tools for cross-platform sharing.

## 2. Create the Shared Folder
Establish the directory and set permissions:
```
sudo mkdir -p /srv/samba/shared
sudo chmod 2770 /srv/samba/shared
sudo chown nobody:nogroup /srv/samba/shared
```
- `mkdir -p`: Creates the path, including parents.
- `chmod 2770`: Grants owner/group read/write/execute; setgid inherits group on new files.
- `chown nobody:nogroup`: Enables guest access.

## 3. Configure Samba Share
Edit the configuration file:
```
sudo nano /etc/samba/smb.conf
```

Append:
```
[SharedFolder]
   path = /srv/samba/shared
   browseable = yes
   read only = no
   guest ok = yes
```
- `[SharedFolder]`: Visible share name.
- `path`: Target directory.
- `browseable = yes`: Allows network visibility.
- `read only = no`: Permits writes.
- `guest ok = yes`: Supports anonymous access.

## 4. Apply Configuration
Restart Samba and validate:
```
sudo systemctl restart smbd
testparm
sudo ufw allow 'Samba'
```
- Restart applies changes.
- `testparm`: Checks syntax.
- Firewall rule opens Samba ports.

## 5. Access from Windows
In File Explorer, connect via:
```
\\192.168.0.150\SharedFolder
```
Create `test.txt` with content and save.

Verify on Ubuntu:
```
ls -l /srv/samba/shared
cat /srv/samba/shared/test.txt
```
This tests bidirectional read/write functionality.

## 6. Troubleshooting
- **Firewall**: Re-allow if blocked: `sudo ufw allow 'Samba'`.
- **Network Discovery**: Enable "Network Discovery" and "File Sharing" on Windows.
- **Access Control**: For authenticated access:
  ```
  sudo adduser labuser
  sudo smbpasswd -a labuser
  sudo smbpasswd -e labuser
  sudo chown labuser:nogroup /srv/samba/shared
  ```
- **Disconnect Clients**:
  ```
  sudo smbstatus  # View connections
  sudo smbcontrol <PID> close-share SharedFolder
  sudo kill <PID>  # Force if necessary
  ```
- **Disable Share**: Comment `[SharedFolder]` in `smb.conf` and restart Samba.

## 7. Observations
- Share accessible from Windows with full read/write.
- Guest mode simplifies testing; authenticated users enhance security.
- Firewall and discovery settings are frequent troubleshooting targets.

## Summary
- Samba installed and configured for guest-accessible sharing.
- Folder permissions and firewall integrated.
- Cross-platform access verified; troubleshooting covers connectivity and sessions.

This setup facilitates file exchange in mixed environments.
