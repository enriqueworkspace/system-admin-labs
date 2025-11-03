Ubuntu Server Setup – Basic Installation and Configuration
Objective

This practice demonstrates how to set up and configure a Ubuntu Server from scratch, including static IP, hostname, DNS, and SSH access. It also covers problem-solving steps encountered during the setup.

1️⃣ Static IP Configuration

Purpose: Assign a fixed IP address to ensure stable network connectivity.

Steps:

Edit the Netplan configuration file:

sudo nano /etc/netplan/00-installer-config.yaml


Configuration used:

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


Set correct permissions:

sudo chmod 600 /etc/netplan/00-installer-config.yaml


Apply the configuration:

sudo netplan apply


Verify the IP:

ip a show enp0s3


Problem encountered: A secondary dynamic IP (192.168.0.120) appeared due to Cloud-init.

Solution: Rename the Cloud-init Netplan file and reapply:

sudo mv /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.bak
sudo netplan apply


Verify that only the static IP remains:

ip a show enp0s3


Test connectivity:

ping 192.168.0.1
ping -c 3 google.com

2️⃣ Hostname Configuration

Purpose: Set a proper server hostname for identification in the network and for services like SSH.

Check current hostname:

hostnamectl


Change the hostname:

sudo hostnamectl set-hostname ubuntu-labtest


Update /etc/hosts to avoid issues with local services:

sudo nano /etc/hosts


Add the following:

127.0.0.1   localhost
127.0.1.1   ubuntu-labtest


Verify:

hostname
hostnamectl

3️⃣ DNS Configuration

Purpose: Ensure proper name resolution for external domains.

Already configured in Netplan during static IP setup:

nameservers:
  addresses: [8.8.8.8, 8.8.4.4]


Verify DNS resolution:

ping google.com
systemd-resolve --status

4️⃣ SSH Configuration

Purpose: Enable remote administration of the server.

Install OpenSSH server:

sudo apt update
sudo apt install openssh-server -y


Start and verify SSH:

sudo systemctl start ssh
sudo systemctl status ssh


Enable SSH to start on boot:

sudo systemctl enable ssh


Verify listening port:

sudo ss -tuln | grep 22


Output shows SSH listening on all IPv4 and IPv6 interfaces.

Test connection from another machine:

ssh rooty@192.168.0.150


Accept the host key (yes) and enter the password.

Successful connection shows prompt: rooty@ubuntu-labtest:~$.

5️⃣ Summary

Static IP configured and verified ✅

Hostname set and /etc/hosts updated ✅

DNS working correctly ✅

SSH installed, enabled, and tested remotely ✅

Problem with secondary dynamic IP resolved ✅

This completes the basic installation and configuration of Ubuntu Server.