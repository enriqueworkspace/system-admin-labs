Zabbix Server and Agents Setup Lab: Hands-On System Monitoring



Overview

In this hands-on lab, I set up a complete Zabbix 7.0 monitoring environment on Ubuntu 24.04.3 LTS as the server host, with agents installed on the same Ubuntu server (for self-monitoring) and a separate Windows host. The goal was to demonstrate active infrastructure monitoring, including item collection, trigger-based alerts, and dashboard visualization for proactive issue detection. All steps were executed successfully, with verification through real-time data collection and simulated alerts. This setup unifies cross-platform metrics (CPU, memory, disk, services) and enables automated notifications, showcasing skills in infrastructure control and rapid response.



Commands were run in Bash on the Ubuntu VM and PowerShell on Windows. Internet access was used for downloads.



Step 1: Install Zabbix Server on Ubuntu 24.04.3 LTS (Bash)

On the Ubuntu Server VM (IP: 192.168.0.179), I updated the system and added the Zabbix repository.



```bash

sudo apt update && sudo apt upgrade -y
sudo apt install -y wget curl gnupg2 software-properties-common
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-2+ubuntu24.04_all.deb
sudo dpkg -i zabbix-release_7.0-2+ubuntu24.04_all.deb  # Pressed Y to overwrite previous repo
sudo apt update

```



Installed components:

```bash

sudo apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts mysql-server

```



Secured MySQL:

```bash

sudo mysql_secure_installation

```

Set root password: [PASSWORD_HERE]
Removed anonymous users: Y
Disallowed remote root: Y
Removed test DB: Y
Reloaded privileges: Y
Enabled validate password: Y (MEDIUM policy)


Created DB and user:

```bash

sudo mysql -u root -p

```

In MySQL shell:

```sql

CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER 'zabbix'@'localhost' IDENTIFIED WITH mysql_native_password BY '[ZABBIX_PASSWORD_HERE]';
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
FLUSH PRIVILEGES;
EXIT;

```



Fixed import issues (dropped/recreated DB, set auth plugin) and imported schema:

```bash

sudo mysql -u root -p  # Set GLOBAL log_bin_trust_function_creators = 1
EXIT;
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -u zabbix -p zabbix

```



Configured server:

```bash

sudo nano /etc/zabbix/zabbix_server.conf

```

Updated:

```

DBHost=localhost
DBName=zabbix
DBUser=zabbix
DBPassword=[ZABBIX_PASSWORD]

```



Started services:

```bash

sudo systemctl restart apache2 zabbix-server
sudo systemctl enable apache2 zabbix-server
sudo systemctl status zabbix-server  # Active (running)
sudo nano /etc/zabbix/apache.conf  # Added php_value date.timezone America/New_York
sudo systemctl restart apache2

```



Accessed web UI at `http://192.168.0.179/zabbix`:

DB connection: MySQL, localhost:3306, zabbix DB/user/password.
Server details: 192.168.0.179:10051.
Completed wizard; logged in as Admin/zabbix (changed to \[ADMIN_PASSWORD]).



Outcome: Zabbix server operational, DB populated with ~200 tables (verified: `sudo mysql -u zabbix -p -e "SHOW TABLES FROM zabbix;" zabbix`).



Step 2: Install Zabbix Agent on Ubuntu Server (Self-Monitoring, Bash)

On the same Ubuntu VM:



```bash

sudo apt install -y zabbix-agent2
sudo nano /etc/zabbix/zabbix_agent2.conf

```

Updated:

```

Server=192.168.0.179
ServerActive=192.168.0.179
Hostname=ubuntu-host
UnsafeUserParameters=1

```



Started:

```bash

sudo systemctl restart zabbix-agent2
sudo systemctl enable zabbix-agent2
sudo systemctl status zabbix-agent2  # Active (running)
sudo ufw allow 10050/tcp

```



Outcome: Agent running, ready for local metrics.



Step 3: Add Ubuntu Host in Web UI

In Zabbix UI:

Configuration > Hosts > Create host.
Name: ubuntu-host; Groups: Linux servers.
Interfaces: Agent, IP: 192.168.0.179, Port: 10050 (Default).
Templates: Template OS Linux by Zabbix agent.
Saved successfully.



Verified: Monitoring > Latest data > ubuntu-host (Last 5 min): Items like system.cpu.load (avg ~0.5) and agent.ping=1 updating every 30s.



Outcome: Self-monitoring active, inheriting ~50 items for CPU, memory, disk.



Step 4: Install Zabbix Agent on Windows Host (PowerShell as Admin)

On separate Windows 10/11 machine (IP: 10.0.2.15):



```powershell

$tempPath = "C:\temp"
New-Item -Path $tempPath -ItemType Directory -Force
Invoke-WebRequest -Uri "https://cdn.zabbix.com/zabbix/binaries/stable/7.0/7.0.19/zabbix_agent2-7.0.19-windows-amd64-openssl.msi" -OutFile "$tempPath\zabbix_agent2.msi"
msiexec /i "$tempPath\zabbix_agent2.msi" /qn SERVER="192.168.0.179" SERVERACTIVE="192.168.0.179" HOSTNAME="windows-host" STARTSERVICE=1
sc.exe config "Zabbix Agent 2" start= auto
Get-Service -Name "Zabbix Agent 2" | Start-Service -ErrorAction SilentlyContinue
Get-Service -Name "Zabbix Agent 2"  # Status: Running, StartupType: Automatic
New-NetFirewallRule -DisplayName "Zabbix Agent" -Direction Inbound -Protocol TCP -LocalPort 10050 -Action Allow

```



Outcome: Agent installed and running, configured for active checks.



Step 5: Add Windows Host in Web UI

In Zabbix UI:

Configuration > Hosts > Create host.
Name: windows-host; Groups: New "Windows servers".
Interfaces: Agent, IP: 10.0.2.15, Port: 10050 (Default).
Templates: Template OS Windows by Zabbix agent.
Saved successfully.



Verified: Monitoring > Latest data > windows-host (Last 5 min): Items like system.cpu.util (~3.2%) and agent.ping=1 updating.



Outcome: Cross-platform monitoring unified, ~40 Windows-specific items active.



Step 6: Create Custom Item (Windows Service Status)

In UI: Configuration > Hosts > windows-host > Items > Create item.

Name: Windows Update Service Status
Type: Zabbix agent
Key: service_state[Windows Update,wuauserv]
Type of info: Numeric (unsigned)
Update interval: 1m
Saved.



Verified: Latest data showed value=0 (running).



Outcome: Custom metric for service health, enabling targeted alerts.



Step 7: Set Up Triggers and Alerts

1. Trigger for high CPU (Ubuntu): Configuration > Hosts > ubuntu-host > Triggers > Create trigger.

Name: High CPU Usage
Expression: {ubuntu-host:system.cpu.load[percpu,avg1].last()}>2
Severity: Warning
Saved.



2. Action for alerts: Configuration > Actions > Trigger actions > Create action.

Name: Alert High CPU
Conditions: Trigger name contains "High CPU"
Operations: Send message to Admin (configured email media in Administration > Users > Admin > Media: [SMTP_SERVER], [EMAIL]).
Tested media type (Administration > Media types > Email > Test): Success.



Outcome: Proactive alerting configured; tested with simulation.



Step 8: Build Basic Dashboard

In UI: Monitoring > Dashboards > Create dashboard.

Name: System Health Overview
Added widgets:
Graph: Classic graph with system.cpu.util from ubuntu-host and windows-host.
Problems: To display active alerts.

Saved and viewed.



Outcome: Consolidated view for at-a-glance metrics and trends.



Step 9: Verification and Demonstration

- Simulated high CPU on Ubuntu: `sudo apt install stress -y; stress --cpu 4 --timeout 60s`
- Monitored: Problems widget showed "High CPU Usage" (Warning severity); email alert received.
- Logs: `sudo tail -f /var/log/zabbix/zabbix\_server.log` confirmed trigger firing without errors.
- Firewall: `sudo ufw status` showed ports 10050/10051 allowed.



All hosts reported data continuously; no downtime or errors.



Conclusion

This lab demonstrated end-to-end Zabbix deployment for active monitoring, focusing on proactive alerting (triggers/actions) and visualization (dashboards/items). It unified Ubuntu/Windows metrics for infrastructure control, with successful verification via simulation. This setup is scalable for production environments.

![Zabbix Web UI Dashboard](screenshots/zabbix-web-ui-dashboard.png)

