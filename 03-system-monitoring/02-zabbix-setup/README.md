# Zabbix Server and Agents Setup Lab: Hands-On System Monitoring

This lab deploys Zabbix 7.0 on Ubuntu 24.04.3 LTS for server-side monitoring, with agents on Ubuntu (self-monitoring) and Windows hosts. It covers installation, database setup, host integration, custom items, triggers, alerts, and dashboard creation for unified cross-platform metrics (CPU, memory, disk, services) and proactive notifications.

## 1. Install Zabbix Server on Ubuntu 24.04.3 LTS (Bash)
On Ubuntu VM (IP: 192.168.0.179), update and add repository:
```
sudo apt update && sudo apt upgrade -y
sudo apt install -y wget curl gnupg2 software-properties-common
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-2+ubuntu24.04_all.deb
sudo dpkg -i zabbix-release_7.0-2+ubuntu24.04_all.deb
sudo apt update
```

Install components:
```
sudo apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts mysql-server
```

Secure MySQL:
```
sudo mysql_secure_installation
```
Set root password; confirm Y for anonymous removal, remote root disallowance, test DB removal, privilege reload; enable MEDIUM password policy.

Create database/user:
```
sudo mysql -u root -p
```
In MySQL:
```sql
CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER 'zabbix'@'localhost' IDENTIFIED WITH mysql_native_password BY '[ZABBIX_PASSWORD_HERE]';
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

Import schema (set `GLOBAL log_bin_trust_function_creators = 1` if needed):
```
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -u zabbix -p zabbix
```

Configure server:
```
sudo nano /etc/zabbix/zabbix_server.conf
```
Set: `DBHost=localhost`, `DBName=zabbix`, `DBUser=zabbix`, `DBPassword=[ZABBIX_PASSWORD]`.

Start services:
```
sudo systemctl restart apache2 zabbix-server
sudo systemctl enable apache2 zabbix-server
sudo systemctl status zabbix-server
sudo nano /etc/zabbix/apache.conf  # Add: php_value date.timezone America/New_York
sudo systemctl restart apache2
```

Access UI at `http://192.168.0.179/zabbix`; complete wizard (MySQL localhost:3306, zabbix DB/user/password; server 192.168.0.179:10051). Login: Admin/zabbix (change password). Verified ~200 tables.

## 2. Install Zabbix Agent on Ubuntu Server (Self-Monitoring, Bash)
```
sudo apt install -y zabbix-agent2
sudo nano /etc/zabbix/zabbix_agent2.conf
```
Set: `Server=192.168.0.179`, `ServerActive=192.168.0.179`, `Hostname=ubuntu-host`, `UnsafeUserParameters=1`.

Start:
```
sudo systemctl restart zabbix-agent2
sudo systemctl enable zabbix-agent2
sudo systemctl status zabbix-agent2
sudo ufw allow 10050/tcp
```

## 3. Add Ubuntu Host in Web UI
Configuration > Hosts > Create host: Name `ubuntu-host`, Group `Linux servers`, Interface Agent (IP 192.168.0.179:10050), Template `Template OS Linux by Zabbix agent`.

Verified: Monitoring > Latest data > ubuntu-host: Items (e.g., system.cpu.load ~0.5, agent.ping=1) updating every 30s; ~50 items active.

## 4. Install Zabbix Agent on Windows Host (PowerShell as Admin)
On Windows (IP: 10.0.2.15):
```
$tempPath = "C:\temp"
New-Item -Path $tempPath -ItemType Directory -Force
Invoke-WebRequest -Uri "https://cdn.zabbix.com/zabbix/binaries/stable/7.0/7.0.19/zabbix_agent2-7.0.19-windows-amd64-openssl.msi" -OutFile "$tempPath\zabbix_agent2.msi"
msiexec /i "$tempPath\zabbix_agent2.msi" /qn SERVER="192.168.0.179" SERVERACTIVE="192.168.0.179" HOSTNAME="windows-host" STARTSERVICE=1
sc.exe config "Zabbix Agent 2" start= auto
Get-Service -Name "Zabbix Agent 2" | Start-Service -ErrorAction SilentlyContinue
Get-Service -Name "Zabbix Agent 2"
New-NetFirewallRule -DisplayName "Zabbix Agent" -Direction Inbound -Protocol TCP -LocalPort 10050 -Action Allow
```

## 5. Add Windows Host in Web UI
Configuration > Hosts > Create host: Name `windows-host`, Group `Windows servers`, Interface Agent (IP 10.0.2.15:10050), Template `Template OS Windows by Zabbix agent`.

Verified: Monitoring > Latest data > windows-host: Items (e.g., system.cpu.util ~3.2%, agent.ping=1) updating; ~40 items active.

## 6. Create Custom Item (Windows Service Status)
Configuration > Hosts > windows-host > Items > Create item: Name `Windows Update Service Status`, Type `Zabbix agent`, Key `service_state[Windows Update,wuauserv]`, Info `Numeric (unsigned)`, Interval `1m`.

Verified: Value=0 (running).

## 7. Set Up Triggers and Alerts
Trigger (Ubuntu high CPU): Configuration > Hosts > ubuntu-host > Triggers > Create: Name `High CPU Usage`, Expression `{ubuntu-host:system.cpu.load[percpu,avg1].last()}>2`, Severity `Warning`.

Action: Configuration > Actions > Trigger actions > Create: Name `Alert High CPU`, Condition `Trigger name contains "High CPU"`, Operation: Email to Admin (setup: Administration > Users > Admin > Media > Email with SMTP).

Tested media: Success.

## 8. Build Basic Dashboard
Monitoring > Dashboards > Create: Name `System Health Overview`.

Widgets: Graph (system.cpu.util for both hosts), Problems (active alerts).

## 9. Verification and Demonstration
Simulate: `sudo apt install stress -y; stress --cpu 4 --timeout 60s` (Ubuntu).

Monitored: Problems showed trigger; email received. Logs: `sudo tail -f /var/log/zabbix/zabbix_server.log` (no errors). Firewall: Ports 10050/10051 allowed. Continuous data flow.

![Zabbix Web UI Dashboard](screenshots/zabbix-web-ui-dashboard.png)

## Summary
- Zabbix server installed on Ubuntu with MySQL backend and web UI configured.
- Agents deployed on Ubuntu (self) and Windows hosts; integrated via templates.
- Custom item, trigger, and alert for CPU/service monitoring.
- Dashboard for visualization; simulation verified end-to-end functionality.

This establishes scalable, proactive infrastructure monitoring across platforms.
