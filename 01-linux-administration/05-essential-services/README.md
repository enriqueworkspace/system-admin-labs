# Essential Services Configuration: SSH, Cron Jobs, Firewall, and Systemd Services

This lab covers the setup and verification of core Ubuntu Server services: secure SSH for remote access, cron for task automation, UFW firewall for access control, and a custom systemd service with dependencies. All operations were conducted in a VirtualBox Ubuntu Server VM.

## 1. SSH Configuration
Verify installation of the OpenSSH server package:
```
dpkg -l | grep openssh-server
```
Expected: `openssh-server` listed as installed.

Check service status:
```
sudo systemctl status ssh
```
Expected: Active (running) and enabled.

Enable on boot if required:
```
sudo systemctl enable ssh
```

Test local connection:
```
ssh rooty@localhost
```
Enter password to authenticate.

Test remote connection from host machine:
```
ssh rooty@192.168.0.150
```
VM IP: 192.168.0.150; Username: rooty. Successful login confirms network and service functionality.

## 2. Cron Jobs
Review existing job for daily backup execution:
```
crontab -l
```
Entry: `0 2 * * * /home/rooty/back_logs.sh` (runs at 2:00 AM).

Add test job for minute-by-minute logging:
```
crontab -e
```
Append: `* * * * * echo "Test cron $(date)" >> /home/rooty/cron_test.log`

Monitor execution:
```
tail -f /home/rooty/cron_test.log
```
Expected: New timestamp entries every minute.

Manage cron:
- Edit: `crontab -e`
- Service status: `sudo systemctl status cron` (expected: active and enabled).

Remove test job after verification via `crontab -e`.

## 3. Firewall Configuration (UFW)
Set default policies to deny incoming and allow outgoing traffic:
```
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

Permit SSH:
```
sudo ufw allow 22/tcp
```

Activate logging:
```
sudo ufw logging on
```

Enable and inspect status:
```
sudo ufw enable
sudo ufw status numbered
```
Expected: Only port 22/tcp allowed.

Test blocked port (e.g., 80, with Apache stopped):
```
nc -zv 192.168.0.150 80
```
Expected: Connection refused.

## 4. Systemd Service
Create the service file:
```
sudo nano /etc/systemd/system/test_service.service
```

Insert content:
```
[Unit]
Description=Test Service
After=ufw.service

[Service]
Type=simple
ExecStart=/bin/bash -c 'echo "Service started $(date)" >> /home/rooty/test_service.log'
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Reload daemon, enable, and start:
```
sudo systemctl daemon-reload
sudo systemctl enable test_service
sudo systemctl start test_service
```

View log output:
```
sudo cat /home/rooty/test_service.log
```
Expected: Timestamp entry on startup.

The service depends on UFW, restarts on failure, and activates at boot.

## Summary
- SSH installed, enabled, and tested for local/remote access.
- Cron configured for automated backups and verified through test logging.
- UFW implemented default-deny policy, allowing only SSH with logging enabled; blocked ports confirmed.
- Custom systemd service created with UFW dependency, enabled, and operational.

These configurations ensure secure, automated, and controlled server operations.
