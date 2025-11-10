Automated Backup and Snapshot Lab



Objective



Automate file backups using PowerShell and Windows Task Scheduler to ensure data protection and operational resilience.



Lab Overview



In this lab, I created an automated backup system using a PowerShell script and Task Scheduler.

The goal was to back up important directories regularly and log every action for auditing and troubleshooting.



Steps and Process

1. Script Preparation



I created a folder called C:\Scripts to store the automation script.

Inside it, I created a file named Backup-Files.ps1.



2. Script Logic and Full Script



The script performs the following:



Defines the source folder (C:\Users\rooty\Desktop\TestData) and backup root folder (C:\Backups).



Generates a timestamped folder inside C:\Backups (e.g., Backup_2025-11-09_22-38-03).



Copies all files from the source folder into this new folder.



Writes a detailed log file (C:\Backups\BackupLog.txt) including start time, completion, and any errors.



Ignores folders or files with restricted access, so the backup continues without stopping.



Here is the complete script:



# Backup-Files.ps1
# Automated backup script with error handling and logging

# Paths
$SourcePath = "C:\Users\rooty\Desktop\TestData"   # Folder to back up
$DestinationRoot = "C:\Backups"                  # Backup root folder
$DateTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$DestinationPath = Join-Path $DestinationRoot "Backup_$DateTime"
$LogFile = Join-Path $DestinationRoot "BackupLog.txt"

# Ensure backup root exists
if (!(Test-Path -Path $DestinationRoot)) {
    New-Item -Path $DestinationRoot -ItemType Directory | Out-Null
}

# Create timestamped backup folder
New-Item -Path $DestinationPath -ItemType Directory | Out-Null

# Start log
"$((Get-Date).ToString('MM/dd/yyyy HH:mm:ss')) Backup started from $SourcePath to $DestinationPath" | Out-File $LogFile -Append

# Copy files with error handling
Try {
    Get-ChildItem -Path $SourcePath -Recurse -ErrorAction SilentlyContinue | Copy-Item -Destination $DestinationPath -Recurse -Force -ErrorAction Stop
    "$((Get-Date).ToString('MM/dd/yyyy HH:mm:ss')) Backup completed successfully to $DestinationPath" | Out-File $LogFile -Append
}
Catch {
    "$((Get-Date).ToString('MM/dd/yyyy HH:mm:ss')) ERROR: $($_.Exception.Message)" | Out-File $LogFile -Append
}



3. Testing the Script



I ran the script manually using PowerShell:


```
powershell.exe -ExecutionPolicy Bypass -File "C:\Scripts\Backup-Files.ps1"
```




I verified that:



A new folder appeared in C:\Backups with the timestamp.



The files file1.txt and file2.txt from TestData were copied.



The log file correctly recorded the backup actions.



4. Automation with Task Scheduler



To automate the backup, I created a scheduled task:



Name: AutomatedBackup



Trigger: Daily at 03:00 AM



Action: Run PowerShell with the script:


```
powershell.exe -ExecutionPolicy Bypass -File "C:\Scripts\Backup-Files.ps1"
```




Run with highest privileges: Enabled



Run whether user is logged on or not: Enabled



I tested it manually from Task Scheduler, and it executed successfully, creating the backup folder and updating the log.



5. Verification Commands



List recent backup folders:


```
Get-ChildItem "C:\Backups" | Sort-Object LastWriteTime -Descending | Select-Object -First 3
```




View contents of the latest backup:


```
Get-ChildItem "C:\Backups\<backup_folder_name>"
```




View last 10 log entries:


```
Get-Content "C:\Backups\BackupLog.txt" -Tail 10
```




Check Task Scheduler status:


```
Get-ScheduledTask -TaskName "AutomatedBackup" | Get-ScheduledTaskInfo
```


6. Idempotency and Error Handling



Running the script multiple times creates new timestamped folders, avoiding overwrites.



Folders or files without permission are skipped, and errors are logged.



Successful copies are logged clearly for auditing.

