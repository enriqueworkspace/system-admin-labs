# Prometheus and Grafana System Monitoring Lab

This lab installs and configures Prometheus for metric collection, Alertmanager for notifications, Node Exporter for host metrics, and Grafana for dashboards on Ubuntu Server, enabling visualization of CPU, memory, and network data with proactive alerting.

## 1. Update System
Refresh packages for compatibility:
```
sudo apt update && sudo apt upgrade -y
```

## 2. Install Prometheus Server
### 2.1 Create User and Directories
```
sudo useradd --no-create-home --shell /bin/false prometheus
sudo mkdir /etc/prometheus /var/lib/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus
```

### 2.2 Download and Extract (v3.7.3)
```
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v3.7.3/prometheus-3.7.3.linux-amd64.tar.gz
tar xvf prometheus-3.7.3.linux-amd64.tar.gz
sudo mv prometheus-3.7.3.linux-amd64/prometheus /usr/local/bin/
sudo mv prometheus-3.7.3.linux-amd64/promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool
```

### 2.3 Configure
Edit `/etc/prometheus/prometheus.yml`:
```
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
```
sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml
```

### 2.4 Systemd Service
```
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

### 2.5 Start and Verify
```
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
sudo systemctl status prometheus
curl http://localhost:9090/metrics | head -10
```
Access UI: http://<IP>:9090.

## 3. Install Alertmanager
### 3.1 Download and Extract (v0.29.0)
```
cd /tmp
wget https://github.com/prometheus/alertmanager/releases/download/v0.29.0/alertmanager-0.29.0.linux-amd64.tar.gz
tar xvf alertmanager-0.29.0.linux-amd64.tar.gz
sudo mv alertmanager-0.29.0.linux-amd64/alertmanager /usr/local/bin/
sudo mv alertmanager-0.29.0.linux-amd64/amtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/alertmanager /usr/local/bin/amtool
```

### 3.2 Directories and Config
```
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
```
sudo chown prometheus:prometheus /etc/alertmanager/alertmanager.yml
```

### 3.3 Systemd Service
```
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

### 3.4 Start and Verify
```
sudo systemctl daemon-reload
sudo systemctl start alertmanager
sudo systemctl enable alertmanager
sudo systemctl status alertmanager
curl http://localhost:9093/metrics | head -10
```
Access UI: http://<IP>:9093.

## 4. Install Node Exporter
### 4.1 Download and Extract (v1.10.2)
```
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.10.2/node_exporter-1.10.2.linux-amd64.tar.gz
tar xvf node_exporter-1.10.2.linux-amd64.tar.gz
sudo mv node_exporter-1.10.2.linux-amd64/node_exporter /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/node_exporter
sudo chmod +x /usr/local/bin/node_exporter
```

### 4.2 Systemd Service
```
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

### 4.3 Start and Verify
```
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
sudo systemctl status node_exporter
curl http://localhost:9100/metrics | head -10
```

## 5. Install and Configure Grafana
```
sudo apt update
sudo apt install -y apt-transport-https software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt update
sudo apt install grafana -y
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
sudo systemctl status grafana-server
sudo ufw allow 3000/tcp
sudo ufw reload
```
Access: http://<IP>:3000 (admin/admin). Add Prometheus data source (URL: http://localhost:9090); test connection.

## 6. Create Dashboards
Create → Dashboard → Add panel:

| Panel              | Query                          | Visualization | Legend      | Title              |
|--------------------|--------------------------------|---------------|-------------|--------------------|
| CPU Usage (%)     | `node_cpu_seconds_total`      | Time series  | `{{instance}}` | CPU Usage (%)     |
| Memory Usage (%)  | `node_memory_Active_anon_bytes` | Time series | `{{instance}}` | Memory Usage (%)  |
| Network Traffic (KB/s) | `node_network_carrier`     | Time series  | `{{instance}}` | Network Traffic (KB/s) |

Save as "System Monitoring Lab".

## 7. Verification

| Check         | Command/UI                  | Expected                  |
|---------------|-----------------------------|---------------------------|
| Prometheus   | http://<IP>:9090/targets   | Targets UP               |
| Alertmanager | http://<IP>:9093           | Status page loads        |
| Node Exporter| curl http://localhost:9100/metrics | Host metrics            |
| Grafana      | http://<IP>:3000           | Dashboard with graphs    |

## Summary
- Prometheus server and Alertmanager deployed with systemd integration.
- Node Exporter enabled for host metrics scraping.
- Grafana installed with Prometheus data source; dashboards created for key metrics.
- Verification confirms operational status and UI accessibility.

This setup provides scalable monitoring with alerting; secure ports for production.
