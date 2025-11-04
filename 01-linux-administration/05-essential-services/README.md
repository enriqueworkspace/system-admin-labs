Essential Services Configuration: SSH, Cron Jobs, Firewall, and Systemd Services



This lab demonstrates the configuration and management of essential services on Ubuntu Server, including secure remote access, scheduled tasks, firewall rules, and custom systemd services. All steps were performed in a VirtualBox Ubuntu Server VM.



1\. SSH Configuration



Objective: Enable secure remote access to the server.



Steps:



Check if SSH server is installed:

```

dpkg -l | grep openssh-server

```



Output confirms openssh-server is installed.



Verify SSH service status:

```

sudo systemctl status ssh

```



Status: active (running) and enabled at boot.



Enable SSH to start on boot (if not already):

```

sudo systemctl enable ssh

```



Test SSH connection locally on VM:

```

ssh rooty@localhost

```



Test SSH connection from host machine:

```

ssh rooty@192.168.0.150

```



VM IP: 192.168.0.150



Username: rooty



Observations:



SSH service was active and allowed remote login successfully.



Connection from host confirmed proper network setup and service availability.



2\. Cron Jobs



Objective: Automate tasks using cron.



Existing Cron Job:

```

0 2 \* \* \* /home/rooty/back\_logs.sh

```



Executes the back\_logs.sh script daily at 2:00 a.m.



Test Cron Job:

```

\* \* \* \* \* echo "Test cron $(date)" >> /home/rooty/cron\_test.log

```



Writes timestamp to cron\_test.log every minute for testing.



Verification:

```

tail -f /home/rooty/cron\_test.log

```



Observed new entries every minute, confirming execution.



Commands to manage cron:



Edit user crontab: crontab -e



Verify cron service: sudo systemctl status cron



Observations:



Both scheduled tasks executed successfully.



Cron service was active and enabled at boot.



3\. Firewall Configuration (UFW)



Objective: Restrict network access and allow only necessary services.



Default Policies:

```

sudo ufw default deny incoming

sudo ufw default allow outgoing

```



Allowed Services:

```

sudo ufw allow 22/tcp   # SSH

```



Enable Logging:

```

sudo ufw logging on

```



Verification:

```

sudo ufw status numbered

```



Confirmed only allowed ports are open.



Testing Blocked Ports:

```

nc -zv 192.168.0.150 80

```



Connection refused because Apache2 was stopped and port 80 was blocked.



Observations:



Firewall correctly blocked unauthorized ports while allowing SSH.



Logging enabled for monitoring incoming connections.



4\. Systemd Service



Objective: Create and manage a custom service that depends on UFW.



Service File: /etc/systemd/system/test\_service.service

```

\[Unit]

Description=Test Service

After=ufw.service



\[Service]

Type=simple

ExecStart=/bin/bash -c 'echo "Service started $(date)" >> /home/rooty/test\_service.log'

Restart=on-failure



\[Install]

WantedBy=multi-user.target

```



Commands:

```

sudo systemctl daemon-reload

sudo systemctl enable test\_service

sudo systemctl start test\_service

sudo cat /home/rooty/test\_service.log

```



Observations:



Service writes timestamp to log at startup.



Dependent on UFW, ensuring firewall is active before service starts.



Enabled at boot and restarts on failure.



Summary



SSH configured and tested for remote access.



Cron jobs automated backup script and test logging.



UFW firewall enforced default-deny policy and allowed only required ports.



Systemd service created to demonstrate service management and dependency on firewall.



All configurations were verified and documented for reproducibility.

