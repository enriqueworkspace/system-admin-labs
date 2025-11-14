# Bash Automation Lab: Log Backup and Rotation

This lab implements automated log backups on Ubuntu Server using a Bash script, including compression, file rotation to retain only the last 7 backups, and scheduling via cron for daily maintenance.

## 1. Environment Preparation
Establish the backup directory structure and set ownership:
```
sudo mkdir -p /opt/backups/logs
sudo chown $USER:$USER /opt/backups/logs
```
This creates `/opt/backups/logs` (with parents if needed) and assigns ownership to the current user for non-sudo access.

## 2. Create Backup Script
Generate the script file:
```
nano ~/backup_logs.sh
```

Insert the following content:
```bash
#!/bin/bash
# Variables
BACKUP_DIR="/opt/backups/logs"
LOG_DIR="/var/log"
DATE=$(date +'%Y-%m-%d')
BACKUP_FILE="logs-$DATE.tar.gz"
# Create compressed backup
tar -czf "$BACKUP_DIR/$BACKUP_FILE" "$LOG_DIR"
# Keep only last 7 backups
cd "$BACKUP_DIR"
ls -tp | grep -v '/$' | tail -n +8 | xargs -I {} rm -- {}
# Log activity
echo "$(date '+%Y-%m-%d %H:%M:%S') Backup created: $BACKUP_FILE" >> "$BACKUP_DIR/backup.log"
```

Save and exit (Ctrl+O, Enter, Ctrl+X).

Render executable:
```
chmod +x ~/backup_logs.sh
```

## 3. Manual Test
Execute the script:
```
bash ~/backup_logs.sh
```

Inspect outcomes:
```
ls -lh /opt/backups/logs
cat /opt/backups/logs/backup.log
```
Expected: `logs-YYYY-MM-DD.tar.gz` file present; log entry with timestamp.

## 4. Automate with Cron
Edit the user crontab:
```
crontab -e
```

Append this entry (replace `/home/your_user/` with the actual path):
```
0 2 * * * /home/your_user/backup_logs.sh
```
- `0 2`: Executes at 2:00 AM.
- `* * *`: Runs daily.

Save and exit (Ctrl+O, Enter, Ctrl+X).

List jobs for confirmation:
```
crontab -l
```

## 5. Test Cron Execution
For immediate testing, edit crontab to:
```
*/2 * * * * /home/your_user/backup_logs.sh
```
This schedules runs every 2 minutes.

Monitor after a few minutes:
```
ls -lh /opt/backups/logs
cat /opt/backups/logs/backup.log
```

Revert to the original schedule (`0 2 * * *`) once verified.

## Notes
- `tar -czf` applies gzip compression to reduce storage.
- `ls -tp | grep -v '/$' | tail -n +8 | xargs rm` sorts files by time and removes all but the newest 7.
- Use `crontab -l` to review scheduled tasks.
- The `backup.log` file records execution history for auditing.

## Summary
- Backup directory prepared and script created with compression and rotation.
- Manual execution tested successfully.
- Cron scheduled for daily 2:00 AM runs, with verification method.

This automation ensures consistent log archiving and space management.
