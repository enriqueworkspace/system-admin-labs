# System Administration Hands-On Labs

This repository compiles practical, step-by-step labs demonstrating essential skills in Linux and Windows system administration. Covering installation, configuration, automation, security, and monitoring, these labs simulate real-world scenarios using tools like Bash, PowerShell, rsyslog, Splunk, Zabbix, Prometheus, and more. Each lab includes detailed commands, explanations, troubleshooting, and verification steps for reproducibility. Designed for self-paced learning, they emphasize secure practices, idempotency, and cross-platform integration.

## Key Skills Demonstrated
- **Linux Fundamentals**: Server setup, user/group management, networking, services (SSH, Apache, Samba), scripting (Bash), and logging.
- **Windows Administration**: Active Directory (AD) domain setup, GPO enforcement, NTFS/share permissions, and PowerShell automation.
- **Automation & Orchestration**: CSV-driven user creation, cron/Task Scheduler backups, and idempotent scripts.
- **Monitoring & Analytics**: Native commands, Splunk dashboards, Zabbix agents, Prometheus/Grafana visualizations, and log management.
- **Security & Diagnostics**: TLS encryption, firewall hardening, nmap scans, tcpdump/tshark analysis, and ethical auditing.

All labs were tested on Ubuntu Server 24.04.3 LTS, Ubuntu Desktop 24.04.3 LTS, Windows 11 and Windows Server 2022 (Windows) in VirtualBox environments, with outputs dated November 2025.

## Labs by Category

### Linux Server & Networking
1. **Ubuntu Server Basic Setup**  
   Configure static IP, hostname, DNS, and SSH access; resolve Cloud-Init conflicts for stable networking.

2. **Automated User Management**  
   Bash script for CSV-based user/group creation, password enforcement, home directory permissions, and offboarding.

3. **Apache Web Server with HTTPS**  
   Install Apache, set up UFW firewall, virtual hosts, and self-signed SSL certificates for secure HTTP/HTTPS sites.

4. **Bash Log Backup Automation**  
   Script for compressing `/var/log`, rotating last 7 backups, and cron scheduling at 2:00 AM.

5. **Essential Services Configuration**  
   Manage SSH, cron jobs, UFW firewall (default-deny), and custom systemd services with dependencies.

6. **Samba Shared Folders**  
   Set up guest-accessible shares with NTFS-like permissions, firewall rules, and troubleshooting for Windows integration.

7. **Network Diagnostics with tcpdump, tshark, and nmap**  
   Capture/analyze SSH/ICMP traffic, dissect protocols, and perform ethical port/service scans with hardening.

### Windows Active Directory & Security
8. **Active Directory Domain Installation**  
   PowerShell-based AD DS role setup, domain promotion ("corp.local"), OU/group/user creation, and RDP enablement.

9. **PowerShell Automated AD User Creation**  
   Idempotent script processing CSV for users/groups in isolated "Automation" OU, with password enforcement.

10. **GPO Administration**  
    Create/link GPOs for drive mapping, Control Panel restrictions, wallpapers, and security settings across OUs.

11. **NTFS Permissions and Shared Folders**  
    AD group-based Modify access for departmental folders, SMB shares, and verification of isolation.

### Automation & Inventory
12. **PowerShell System Inventory**  
    Scripts to export hardware (CPU/memory) and software details to CSV for multi-host asset tracking.

13. **PowerShell Automated Backups**  
    Timestamped folder copying with error handling, logging, and Task Scheduler for daily resilience.

### Hybrid & Cloud Identity
14. **Azure AD Integration**  
    PowerShell modules for on-premises connection, user/group operations, and idempotent logging.

### Monitoring & Logging
15. **Basic System Monitoring with Native Commands**  
    Use top/htop, vmstat, ps, df/du, free, uptime, netstat/lsof, and journalctl for diagnostics.

16. **Splunk Enterprise Setup**  
    Install Splunk on Windows, ingest system logs, build dashboards for CPU/events, and configure alerts.

17. **Zabbix Server and Agents**  
    Deploy Zabbix 7.0 on Ubuntu with MySQL; agents for Ubuntu/Windows; custom items, triggers, and dashboards.

18. **Prometheus and Grafana Monitoring**  
    Metric scraping with Node Exporter, Alertmanager notifications, and Grafana panels for CPU/memory/network.

19. **Centralized Log Management with rsyslog**  
    TLS-secured forwarding (port 6514), filters, rotation (7-day compressed), integrity checks, and auditing scripts.

## Contribution & License
Fork and experiment—pull requests welcome for enhancements. MIT License. Questions? Open an issue.

---

*Last Updated: November 14, 2025*  
🚀 Explore, automate, secure—build resilient systems one lab at a time!
