# Centralized Log Management with rsyslog

This lab configures rsyslog as a central log server on Ubuntu, enabling secure TCP/TLS forwarding (port 6514) from Linux clients. It implements filtering for system/auth/kernel/custom logs, daily rotation with 7-day compressed retention, integrity verification, and automated auditing for secure, auditable collection.

## System Diagram
```
[Linux Client(s)] --TCP/TLS (Port 6514)--> [Central Log Server]
  | |
  | - System Logs | - /var/log/remote/
  | - Auth Logs | - remote-hosts.log (general remote logs)
  | - Kernel Messages | - auth.log (filtered authentication)
  | - Custom Application Logs | - system.log (kernel events)
  | | - Rotation: Daily, 7-day retention, compressed
  v v
Local Syslog --> Encrypted Forwarding --> Centralized Auditing & Verification Script
```

## 1. Preparation (Server and Clients)
Update packages and install rsyslog with TLS support:
```
sudo apt update && sudo apt upgrade -y
sudo apt install rsyslog rsyslog-gnutls net-tools -y
sudo systemctl enable --now rsyslog
```

Verify client-to-server connectivity:
```
ping -c 3 <server-ip>
```
Expected: 100% packet loss 0%.

## 2. Configure Central Server (rsyslog)
Create secure directories:
```
sudo mkdir -p /var/log/remote/{system,auth,custom}
sudo chown syslog:adm /var/log/remote -R
sudo chmod 750 /var/log/remote -R
```

Generate self-signed TLS certificates:
```
sudo apt install openssl -y
sudo mkdir -p /etc/rsyslog.d/certs
cd /etc/rsyslog.d/certs
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout server.key -out server.crt -subj "/CN=<server-ip>"
sudo chown syslog:adm server.*
sudo chmod 600 server.key
sudo chmod 644 server.crt
```

Append to `/etc/rsyslog.conf`:
```
# Input TLS with gtls
module(load="imtcp" StreamDriver.Name="gtls" StreamDriver.Mode="1" StreamDriver.AuthMode="anon" StreamDriver.PermitExpiredCerts="on")
input(type="imtcp" port="6514" streamDriver.CertFile="/etc/rsyslog.d/certs/server.crt" streamDriver.KeyFile="/etc/rsyslog.d/certs/server.key")
# Advanced filters
if $syslogfacility-text == 'authpriv' then /var/log/remote/auth.log
& stop
if $programname == 'kernel' then /var/log/remote/system.log
& stop
# Template for remote logs
:fromhost-ip, !isequal,"127.0.0.1" /var/log/remote/remote-hosts.log
& stop
```

Configure firewall:
```
sudo ufw allow from <subnet> to any port 6514 proto tcp  # e.g., 192.168.0.0/24
sudo ufw reload
```

Restart and verify:
```
sudo systemctl restart rsyslog
sudo systemctl status rsyslog
sudo netstat -tuln | grep 6514
```
Expected: Active (running); tcp LISTEN on 6514.

## 3. Configure Client for Secure Forwarding
Copy server certificate:
```
sudo mkdir -p /etc/rsyslog.d/certs
sudo scp <user>@<server-ip>:/etc/rsyslog.d/certs/server.crt /etc/rsyslog.d/certs/
sudo chown syslog:adm /etc/rsyslog.d/certs/server.crt
```

Append to `/etc/rsyslog.conf`:
```
# gtls TLS forwarding
$ActionSendStreamDriver gtls
$ActionSendStreamDriverMode 1
$ActionSendStreamDriverAuthMode anon
$DefaultNetstreamDriverCertFile /etc/rsyslog.d/certs/server.crt
*.* @@<server-ip>:6514
```

Restart and verify:
```
sudo systemctl restart rsyslog
sudo systemctl status rsyslog
```
Expected: Active (running); no connection errors.

## 4. Log Rotation and Retention
Create `/etc/logrotate.d/remote-logs`:
```
/var/log/remote/remote-hosts.log {
    su syslog adm
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 640 syslog adm
    sharedscripts
    postrotate
        /usr/lib/rsyslog/rsyslog-rotate
    endscript
}
```

Test:
```
sudo logrotate -f /etc/logrotate.d/remote-logs
ls -la /var/log/remote/remote-hosts.log*
```
Expected: `.1.gz` compressed.

## 5. Testing and Verification
Generate client logs:
```
logger "Test system log from client"
logger -p auth.info "Test auth login attempt from client"
sudo logger -p kern.warning "Test kernel warning from client"
echo "Custom app log from client" | logger -t myapp
```

Verify on server:
```
sudo tail -f /var/log/remote/remote-hosts.log  # General logs
sudo tail -f /var/log/remote/auth.log  # Auth-specific
sudo tail -f /var/log/remote/system.log  # Kernel-specific
```
Expected: Logs arrive in 2-5 seconds.

Integrity check:
```
# Client hash
echo "Test system log from client" | sha256sum
# Server match
sudo grep "Test system log" /var/log/remote/remote-hosts.log | awk '{print $NF}' | sha256sum
```
Expected: Matching hashes.

## 6. Auditing Script
Create `/usr/local/bin/audit-logs.sh`:
```
#!/bin/bash
LOG_DIR="/var/log/remote"
echo "=== Centralized Logs Audit (TLS Enabled) ==="
echo "Date: $(date)"
echo "Disk Usage: $(du -sh $LOG_DIR)"
echo "rsyslog Status: $(systemctl is-active rsyslog)"
echo ""
echo "Recent Logs (10):"
tail -n 10 $LOG_DIR/remote-hosts.log
echo ""
echo "Recent Auth (5):"
tail -n 5 $LOG_DIR/auth.log || echo "No auth logs"
echo "Recent Kernel (5):"
tail -n 5 $LOG_DIR/system.log || echo "No kernel logs"
```

Execute:
```
sudo chmod +x /usr/local/bin/audit-logs.sh
sudo /usr/local/bin/audit-logs.sh
```

Schedule hourly:
```
sudo crontab -e
```
Add: `0 * * * * /usr/local/bin/audit-logs.sh >> /var/log/audit-summary.log`

Example output:
```
=== Centralized Logs Audit (TLS Enabled) ===
Date: Thu Nov 13 10:13:30 PM UTC 2025
Disk Usage: 68K /var/log/remote
rsyslog Status: active
Recent Logs (10):
Nov 13 22:11:12 ubuntu rootygui: Test warnings OK 1: Sistema GUI
Nov 13 22:11:38 ubuntu rootygui: Test warnings OK 2: Auth GUI
...
```

## Summary
- rsyslog server configured with TLS input (6514) and filters for categorized logging.
- Clients forward encrypted logs; directories secured.
- Rotation ensures 7-day compressed retention.
- Verification confirms arrival, integrity; auditing script provides summaries.
- Best practices: Use CA certificates in production; monitor `/var/log/syslog` for TLS errors.

This pipeline supports scalable, secure auditing across environments.
