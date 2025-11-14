# Centralized Log Management with rsyslog and syslog-ng

## System Diagram

```
[Linux Client(s)] --TCP/TLS (Port 6514)--> [Central Log Server]
  |                                           |
  | - System Logs                             | - /var/log/remote/
  | - Auth Logs                               |   - remote-hosts.log (general remote logs)
  | - Kernel Messages                         |   - auth.log (filtered authentication)
  | - Custom Application Logs                 |   - system.log (kernel events)
  |                                           | - Rotation: Daily, 7-day retention, compressed
  v                                           v
Local Syslog --> Encrypted Forwarding --> Centralized Auditing & Verification Script
```

This architecture collects logs from multiple clients into a single secure server, with filtering for reliability and rotation for storage management. Focus: **Security** (TLS encryption), **Auditing** (integrity checks), and **Monitoring** (automated scripts).

## Objectives
- Install and configure rsyslog as a central log server with TLS encryption.
- Set up clients to forward logs securely over TCP/TLS.
- Implement log rotation and retention policies.
- Apply filters for system, authentication, and custom logs.
- Verify collection, integrity, and real-time auditing.
- Document troubleshooting and production best practices.

## Step-by-Step Configuration

### Step 1: Preparation (Server and Clients)
Update systems and install rsyslog with TLS support:
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install rsyslog rsyslog-gnutls net-tools -y
sudo systemctl enable --now rsyslog
```
Verify connectivity from client to server:
```bash
ping -c 3 <server-ip>  # Expected: 100% packet loss 0%
```

### Step 2: Configure Central Server (rsyslog)
Create secure log directories:
```bash
sudo mkdir -p /var/log/remote/{system,auth,custom}
sudo chown syslog:adm /var/log/remote -R
sudo chmod 750 /var/log/remote -R
```

Generate self-signed TLS certificates (for lab; use CA in production):
```bash
sudo apt install openssl -y
sudo mkdir -p /etc/rsyslog.d/certs
cd /etc/rsyslog.d/certs
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout server.key -out server.crt -subj "/CN=<server-ip>"
sudo chown syslog:adm server.*
sudo chmod 600 server.key
sudo chmod 644 server.crt
```

Edit `/etc/rsyslog.conf` (append to end):
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
```bash
sudo ufw allow from <subnet> to any port 6514 proto tcp  # e.g., 192.168.0.0/24
sudo ufw reload
```

Restart and verify:
```bash
sudo systemctl restart rsyslog
sudo systemctl status rsyslog  # Expected: active (running); CA warnings normal for self-signed
sudo netstat -tuln | grep 6514  # Expected: tcp 0 0 0.0.0.0:6514 0.0.0.0:* LISTEN
```

### Step 3: Configure Client for Secure Forwarding
Copy server certificate to client:
```bash
sudo mkdir -p /etc/rsyslog.d/certs
sudo scp <user>@<server-ip>:/etc/rsyslog.d/certs/server.crt /etc/rsyslog.d/certs/
sudo chown syslog:adm /etc/rsyslog.d/certs/server.crt
```

Edit `/etc/rsyslog.conf` (append to end):
```
# gtls TLS forwarding
$ActionSendStreamDriver gtls
$ActionSendStreamDriverMode 1
$ActionSendStreamDriverAuthMode anon
$DefaultNetstreamDriverCertFile /etc/rsyslog.d/certs/server.crt

*.* @@<server-ip>:6514
```

Restart and verify:
```bash
sudo systemctl restart rsyslog
sudo systemctl status rsyslog  # Expected: active (running); no 514 connection errors
```

### Step 4: Log Rotation and Retention
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

Test rotation:
```bash
sudo logrotate -f /etc/logrotate.d/remote-logs
ls -la /var/log/remote/remote-hosts.log*  # Expected: .1.gz (compressed old log)
```

### Step 5: Testing and Verification
Generate test logs on client:
```bash
logger "Test system log from client"
logger -p auth.info "Test auth login attempt from client"
sudo logger -p kern.warning "Test kernel warning from client"
echo "Custom app log from client" | logger -t myapp
```

Verify on server:
```bash
sudo tail -f /var/log/remote/remote-hosts.log  # Expected: logs arrive in 2-5 seconds
sudo tail -f /var/log/remote/auth.log  # Auth-specific
sudo tail -f /var/log/remote/system.log  # Kernel-specific
```

Integrity check (hash example):
```bash
# On client
echo "Test system log from client" | sha256sum

# On server
sudo grep "Test system log" /var/log/remote/remote-hosts.log | awk '{print $NF}' | sha256sum  # Hashes match
```

### Auditing Script
Create `/usr/local/bin/audit-logs.sh`:
```bash
sudo nano /usr/local/bin/audit-logs.sh
```
Paste:
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
Make executable and run:
```bash
sudo chmod +x /usr/local/bin/audit-logs.sh
sudo /usr/local/bin/audit-logs.sh  # Expected: Summary with logs, usage, status
```

Schedule hourly audit:
```bash
sudo crontab -e
```
Add: `0 * * * * /usr/local/bin/audit-logs.sh >> /var/log/audit-summary.log`

## Example Outputs
- **tail remote-hosts.log**:
  ```
  Nov 13 22:11:12 ubuntu rootygui: Test warnings OK 1: Sistema GUI
  Nov 13 22:11:38 ubuntu rootygui: Test warnings OK 2: Auth GUI
  ```
- **Audit Script**:
  ```
  === Centralized Logs Audit (TLS Enabled) ===
  Date: Thu Nov 13 10:13:30 PM UTC 2025
  Disk Usage: 68K /var/log/remote
  rsyslog Status: active
  Recent Logs (10):
  [test logs and system events]
  Recent Auth (5):
  [sudo events]
  Recent Kernel (5):
  [kernel events]
  ```
- **netstat 6514**: `tcp 0 0 0.0.0.0:6514 0.0.0.0:* LISTEN`

This lab demonstrates a robust, secure logging pipeline. Test in production-like environments for reliability.
