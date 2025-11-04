Bash Automation Lab
Objective

Automate maintenance tasks and backups on Ubuntu Server using Bash scripts.

Contents

Log backup scripts

File rotation

Backup compression

Steps
1. Environment Preparation

Create backup directory:
```
sudo mkdir -p /opt/backups/logs
sudo chown $USER:$USER /opt/backups/logs
```

Explanation:

mkdir -p creates the folder /opt/backups/logs, including parent directories.

chown $USER:$USER assigns ownership to the current user, avoiding the need for sudo every time.

2. Create Backup Script

Create the script file:
```
nano ~/backup_logs.sh
```

Paste:
```
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

Save and exit (Ctrl + O, Enter, Ctrl + X).

Make it executable:
```
chmod +x ~/backup_logs.sh
```
3. Manual Test

Run the script:
```
bash ~/backup_logs.sh
```

Verify results:
```
ls -lh /opt/backups/logs
cat /opt/backups/logs/backup.log
```

Expected outcome:

logs-YYYY-MM-DD.tar.gz created

Entry in backup.log with timestamp

4. Automate with Cron

Open user cron:
```
crontab -e
```

Add:
```
0 2 * * * /home/your_user/backup_logs.sh
```

Explanation:

0 → minute 0

2 → hour 2 (2:00 AM)

* * * → every day, month, and weekday

Save (Ctrl + O, Enter) and exit (Ctrl + X).

Check cron:
```
crontab -l
```
5. Test Cron Execution

To test without waiting until 2:00 AM, temporarily change the line:
```
*/2 * * * * /home/your_user/backup_logs.sh
```

This runs the script every 2 minutes.

Wait a few minutes and check:
```
ls -lh /opt/backups/logs
cat /opt/backups/logs/backup.log
```

Once confirmed, revert cron to original schedule.

6. Notes and Observations

tar -czf compresses backups to save space

ls -tp | grep -v '/$' | tail -n +8 | xargs rm keeps only the last 7 backups

Always verify cron jobs with crontab -l

Keep backup.log to track script execution history