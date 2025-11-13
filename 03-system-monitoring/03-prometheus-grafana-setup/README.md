# Prometheus and Grafana System Monitoring Lab

## Overview

This lab demonstrates the installation and configuration of Prometheus for metric scraping, Alertmanager for proactive notifications, Node Exporter for host metrics, and Grafana for visualization. It focuses on active infrastructure monitoring with DevOps tools, emphasizing CPU, memory, and network metrics on Ubuntu Server.

### Objectives
- Install Prometheus Server on Ubuntu Server.
- Install Node Exporter on Ubuntu host.
- Configure Prometheus for metric scraping and targets.
- Set up Alertmanager for alerts.
- Install and configure Grafana with Prometheus data source.
- Create dashboards for CPU, memory, and network metrics.
- Demonstrate proactive monitoring with visual tools.

## Installation Steps (Ubuntu Server)

Execute as root or with `sudo` on Ubuntu Server.

### Update System
Ensures compatibility:
```bash
sudo apt update && sudo apt upgrade -y
```

### Install Prometheus Server

1. Create user and directories:
   ```bash
   sudo useradd --no-create-home --shell /bin/false prometheus
   sudo mkdir /etc/prometheus /var/lib/prometheus
   sudo chown prometheus:prometheus /var/lib/prometheus
   ```

2. Download and extract (v2.53.0 - latest stable):
   ```bash
   cd /tmp
   wget https://github.com/prometheus/prometheus/releases/download/v2.53.0/prometheus-2.53.0.linux-amd64.tar.gz
   tar xvf prometheus-2.53.0.linux-amd64.tar.gz
   sudo mv prometheus-2.53.0.linux-amd64/prometheus /usr/local/bin/
   sudo mv prometheus-2.53.0.linux-amd64/promtool /usr/local/bin/
   sudo chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool
   ```

3. Basic config (`/etc/prometheus/prometheus.yml` edited with nano):
   ```bash
   sudo nano /etc/prometheus/prometheus.yml
   ```
   Content:
   ```yaml
   global:
     scrape_interval: 15s
     evaluation_interval: 15s

   alerting:
     alertmanagers:
       - static_configs:
           - targets:
               - alertmanager:9093

   rule_files:
     # - "first_rules.yml"

   scrape_configs:
     - job_name: 'prometheus'
       static_configs:
         - targets: ['localhost:9090']
           labels:
             app: 'prometheus'

     - job_name: 'node_ubuntu'
       static_configs:
         - targets: ['localhost:9100']
           labels:
             instance: 'ubuntu-server'
             env: 'lab'
   ```
   Save and exit (Ctrl+O, Enter, Ctrl+X).

   ```bash
   sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml
   ```

4. Systemd service:
   ```bash
   sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
   [Unit]
   Description=Prometheus
   Wants=network-online.target
   After=network-online.target

   [Service]
   User=prometheus
   Group=prometheus
   Type=simple
   ExecStart=/usr/local/bin/prometheus \
     --config.file /etc/prometheus/prometheus.yml \
     --storage.tsdb.path /var/lib/prometheus/
   Restart=always

   [Install]
   WantedBy=multi-user.target
   EOF
   ```

5. Start and enable:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl start prometheus
   sudo systemctl enable prometheus
   sudo systemctl status prometheus  # Active: active (running)
   ```

6. Verify:
   ```bash
   curl http://localhost:9090/metrics | head -10
   ```
   Access UI: http://<IP>:9090.

### Install Alertmanager

1. Download and extract (v0.27.0 - latest):
   ```bash
   cd /tmp
   wget https://github.com/prometheus/alertmanager/releases/download/v0.27.0/alertmanager-0.27.0.linux-amd64.tar.gz
   tar xvf alertmanager-0.27.0.linux-amd64.tar.gz
   sudo mv alertmanager-0.27.0.linux-amd64/alertmanager /usr/local/bin/
   sudo mv alertmanager-0.27.0.linux-amd64/amtool /usr/local/bin/
   sudo chown prometheus:prometheus /usr/local/bin/alertmanager /usr/local/bin/amtool
   ```

2. Directories and config (`/etc/alertmanager/alertmanager.yml` edited with nano):
   ```bash
   sudo mkdir /etc/alertmanager /var/lib/alertmanager
   sudo chown prometheus:prometheus /etc/alertmanager /var/lib/alertmanager
   sudo nano /etc/alertmanager/alertmanager.yml
   ```
   Content:
   ```yaml
   global:
     smtp_smarthost: 'localhost:25'

   route:
     group_by: ['alertname']
     group_wait: 30s
     group_interval: 5m
     repeat_interval: 1h
     receiver: 'team-email'

   receivers:
     - name: 'team-email'
       email_configs:
         - to: 'admin@example.com'
           from: 'prometheus@example.com'
           smarthost: 'localhost:25'
   ```
   Save and exit.

   ```bash
   sudo chown prometheus:prometheus /etc/alertmanager/alertmanager.yml
   ```

3. Systemd service:
   ```bash
   sudo tee /etc/systemd/system/alertmanager.service > /dev/null <<EOF
   [Unit]
   Description=Alertmanager
   Wants=network-online.target
   After=network-online.target

   [Service]
   User=prometheus
   Group=prometheus
   Type=simple
   ExecStart=/usr/local/bin/alertmanager \
     --config.file /etc/alertmanager/alertmanager.yml \
     --storage.path /var/lib/alertmanager/
   Restart=always

   [Install]
   WantedBy=multi-user.target
   EOF
   ```

4. Start and enable:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl start alertmanager
   sudo systemctl enable alertmanager
   sudo systemctl status alertmanager  # Active: active (running)
   ```

5. Verify:
   ```bash
   curl http://localhost:9093/metrics | head -10
   ```
   Access UI: http://<IP>:9093.

### Install Node Exporter (Ubuntu)

1. Download and extract (v1.8.2 - latest):
   ```bash
   cd /tmp
   wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
   tar xvf node_exporter-1.8.2.linux-amd64.tar.gz
   sudo mv node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin/
   sudo chown prometheus:prometheus /usr/local/bin/node_exporter
   sudo chmod +x /usr/local/bin/node_exporter
   ```

2. Systemd service:
   ```bash
   sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
   [Unit]
   Description=Node Exporter
   Wants=network-online.target
   After=network-online.target

   [Service]
   User=prometheus
   Group=prometheus
   Type=simple
   ExecStart=/usr/local/bin/node_exporter
   Restart=always

   [Install]
   WantedBy=multi-user.target
   EOF
   ```

3. Start and enable:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl start node_exporter
   sudo systemctl enable node_exporter
   sudo systemctl status node_exporter  # Active: active (running)
   ```

4. Verify:
   ```bash
   curl http://localhost:9100/metrics | head -10
   ```

### Install and Configure Grafana

1. Install:
   ```bash
   sudo apt update
   sudo apt install -y apt-transport-https software-properties-common wget
   wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
   echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
   sudo apt update
   sudo apt install grafana -y
   ```

2. Start and enable:
   ```bash
   sudo systemctl start grafana-server
   sudo systemctl enable grafana-server
   sudo systemctl status grafana-server  # Active: active (running)
   sudo ufw allow 3000/tcp
   sudo ufw reload
   ```

3. Access: http://<IP>:3000 (admin/admin).
4. Add data source:
   - Configuration → Data Sources → Add data source → Prometheus.
   - URL: `http://localhost:9090`.
   - Save & Test → "Data source is working".

### Create Dashboards

1. + Create → Dashboard → Add new panel.

| Panel | Query | Visualization | Legend | Title |
|-------|-------|---------------|--------|-------|
| CPU Usage (%) | `node_cpu_seconds_total` | Time series | `{{instance}}` | CPU Usage (%) |
| Memory Usage (%) | `node_memory_Active_anon_bytes` | Time series | `{{instance}}` | Memory Usage (%) |
| Network Traffic (KB/s) | `node_network_carrier` | Time series | `{{instance}}` | Network Traffic (KB/s) |

2. Save dashboard as "System Monitoring Lab".

## Verification

| Check | Command/UI | Expected |
|-------|------------|----------|
| Prometheus | http://<IP>:9090/targets | Targets UP |
| Alertmanager | http://<IP>:9093 | Status page loads |
| Node Exporter | curl http://localhost:9100/metrics | Host metrics |
| Grafana | http://<IP>:3000 | Dashboard with graphs |

This lab establishes proactive monitoring with scraping, alerting, and visualization. For production, add authentication and secure ports.
