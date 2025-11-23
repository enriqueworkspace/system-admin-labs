# Ubuntu Server Setup: Basic Installation and Configuration

This guide details the configuration of a new Ubuntu Server instance, focusing on static IP assignment, hostname and DNS setup, and SSH enablement. It includes resolution of a common networking issue. Follow the steps sequentially for a stable server environment.

## 1. Static IP Configuration

Edit the Netplan configuration file to assign a static IP:

```
sudo nano /etc/netplan/00-installer-config.yaml
```

Apply the following configuration (verify the interface name with `ip link` if needed):

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: no
      addresses: [192.168.0.150/24]
      gateway4: 192.168.0.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

Set permissions:

```
sudo chmod 600 /etc/netplan/00-installer-config.yaml
```

Apply changes:

```
sudo netplan apply
```

Verify the IP assignment:

```
ip a show enp0s3
```

**Issue Resolution:** If a secondary dynamic IP appears (e.g., 192.168.0.120 from Cloud-Init), rename the conflicting file:

```
sudo mv /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.bak
sudo netplan apply
```

Re-verify:

```
ip a show enp0s3
```

Test connectivity:

```
ping 192.168.0.1
ping -c 3 google.com
```

## 2. Hostname Configuration

Check the current hostname:

```
hostnamectl
```

Set the new hostname:

```
sudo hostnamectl set-hostname ubuntu-labtest
```

Edit `/etc/hosts` for local resolution:

```
sudo nano /etc/hosts
```

Ensure these entries are present:

```
127.0.0.1   localhost
127.0.1.1   ubuntu-labtest
```

Verify:

```
hostname
hostnamectl
```

## 3. DNS Configuration

DNS is configured in the Netplan file under `nameservers`. Verify resolution:

```
ping google.com
systemd-resolve --status
```

## 4. SSH Configuration

Update packages:

```
sudo apt update
```

Install OpenSSH server:

```
sudo apt install openssh-server -y
```

Start the service:

```
sudo systemctl start ssh
```

Check status:

```
sudo systemctl status ssh
```

Enable on boot:

```
sudo systemctl enable ssh
```

Confirm port 22 is listening:

```
sudo ss -tuln | grep 22
```

Test from a remote machine:

```
ssh rooty@192.168.0.150
```

Accept the host key and authenticate with the password. The prompt should appear as `rooty@ubuntu-labtest:~$`.

## Summary

- Static IP configured and verified, with Cloud-Init conflict resolved.
- Hostname updated and `/etc/hosts` adjusted.
- DNS resolution functional.
- SSH installed, enabled, and remotely accessible.

This establishes core server networking and access.
