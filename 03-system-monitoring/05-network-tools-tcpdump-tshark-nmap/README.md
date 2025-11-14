# Lab 05: Network Diagnostics and Analysis with tcpdump, tshark, and nmap

This lab dives into practical network diagnostics using tcpdump for packet capture, tshark for protocol dissection, and nmap for scanning. Set in a controlled environment with an Ubuntu Desktop client and Ubuntu Server, it covers capturing SSH traffic, analyzing protocols like ICMP and SSH, enumerating services, and verifying results—all with an emphasis on ethical practices and security hardening.

## Environment Overview
- **Machines**: Ubuntu Desktop (client) and Ubuntu Server (target).
- **Network**: Local subnet; default interface (e.g., enp0s3).
- **Tools Installed**: tcpdump, tshark, nmap (via apt on both machines).

## Objectives
As I worked through this lab, my goals were:
- Install and configure tcpdump, tshark, and nmap for packet capture, analysis, and scanning.
- Capture and filter traffic (e.g., SSH on port 22, ICMP pings).
- Dissect protocols with tshark (e.g., SSH handshakes, ICMP types).
- Perform nmap scans: host discovery, SYN port scans, service versioning, and script checks.
- Verify results with checksums, stats, and cross-machine captures.
- Document everything for reproducibility, including ethical notes for production use.

## Installation and Configuration
I started by updating packages and installing the tools on both machines (run as root or with sudo). This ensures a clean, consistent setup.

On **Ubuntu Desktop** and **Ubuntu Server**:
```bash
sudo apt update
sudo apt install -y tcpdump tshark nmap jq  # jq for JSON parsing in tshark exports
```

**Verification**:
```bash
tcpdump --version  # e.g., tcpdump version 4.99.4
tshark --version   # e.g., TShark (Wireshark) 4.0.6
nmap --version     # e.g., Nmap version 7.94SVN
```

For tshark, I added my user to the wireshark group to avoid sudo for reads (optional):
```bash
sudo usermod -aG wireshark $USER
# Log out and back in to apply
```

## Example Commands and Procedures

### 1. Packet Capture with tcpdump
I generated test traffic by initiating an SSH connection from client to server (in one terminal), then captured it in another. This simulates diagnosing connection issues.

**Generate Traffic (Terminal 1 on Client)**:
```bash
ssh root@SERVER_IP  # Ctrl+C after capture to abort (replace SERVER_IP)
```

**Capture SSH Traffic (Terminal 2 on Client)**:
```bash
sudo tcpdump -i enp0s3 -c 10 -n host SERVER_IP and port 22 -w ssh_capture.pcap
```
- **Flags**: `-i enp0s3` (interface), `-c 10` (limit packets), `-n` (no DNS), filter for SSH to server, `-w` (write to PCAP).

**Output** (during run):
```
tcpdump: listening on enp0s3, link-type EN10MB (Ethernet), snapshot length 262144 bytes
10 packets captured
89 packets received by filter
0 packets dropped by kernel
```

**Verification**:
```bash
ls -l ssh_capture.pcap  # e.g., -rw-r--r-- 1 tcpdump tcpdump 1168 Nov 14 03:49 ssh_capture.pcap
md5sum ssh_capture.pcap  # e.g., 40edf762692ed798a9e60309853ca117  ssh_capture.pcap
```

For ICMP (cross-verification), I captured pings on the server side while sending from client.

**Capture on Server**:
```bash
sudo tcpdump -i enp0s3 -c 5 -n icmp and host CLIENT_IP -w ping_capture.pcap
```

**Generate Ping on Client**:
```bash
ping -c 5 SERVER_IP
```

### 2. Traffic Analysis with tshark
Once captured, I dissected the PCAPs to inspect protocols—great for spotting handshake failures or anomalies.

**SSH Dissection (on Client)**:
```bash
tshark -r ssh_capture.pcap -Y "ssh" -T fields -e frame.number -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e ssh.message_code
```
- **Flags**: `-r` (read file), `-Y` (display filter), `-T fields` (tabular output), `-e` (extract fields).

**Sample Output** (abridged; shows bidirectional handshake):
```
1	CLIENT_IP	SERVER_IP	54321	22	
2	SERVER_IP	CLIENT_IP	22	54321	
3	CLIENT_IP	SERVER_IP	54321	22	20
4	SERVER_IP	CLIENT_IP	22	54321	20
```
- Code 20 indicates SSH version negotiation (normal).

**ICMP Dissection (on Server)**:
```bash
tshark -r ping_capture.pcap -Y "icmp" -T fields -e frame.number -e ip.src -e ip.dst -e icmp.type -e icmp.code
```

**Sample Output**:
```
1	CLIENT_IP	SERVER_IP	8	0  # Echo Request
2	SERVER_IP	CLIENT_IP	0	0  # Echo Reply
3	CLIENT_IP	SERVER_IP	8	0
...
```
- 0% packet loss, low latency (~0.35 ms avg from ping).

**Export to JSON (for visualization/tools like jq)**:
```bash
tshark -r ssh_capture.pcap -Y "ssh" -T json > ssh_analysis.json
jq . ssh_analysis.json | head -10  # Preview
```

**Traffic Stats**:
```bash
tshark -r ssh_capture.pcap -z io,stat,0
```

**Sample Output** (protocol hierarchy):
```
==================================================================
Protocol Hierarchy Statistics
|proto|   packets|    bytes  |   %bytes |
|TCP  |      20  |    1500   |   100.0  |
|SSH  |      10  |     800   |    53.3  |
|Data |      10  |     700   |    46.7  |
==================================================================
```

### 3. Network Scanning with nmap
From client, I scanned the server for discovery, ports, and services. Note: Used `-Pn` due to ICMP probe blocking by UFW.

**Host Discovery**:
```bash
nmap -sn SERVER_IP
```
**Sample Output** (failed due to firewall; fallback to -Pn):
```
Note: Host seems down. If it is really up, but blocking our ping probes, try -Pn
```

**SYN Port Scan (1-1000)**:
```bash
sudo nmap -Pn -sS -p 1-1000 SERVER_IP
```

**Sample Output**:
```
Nmap scan report for SERVER_IP
Host is up (0.00029s latency).
Not shown: 999 filtered tcp ports (no-response)
PORT STATE SERVICE
22/tcp open ssh
```

**Service Version and Scripts**:
```bash
sudo nmap -Pn -sV -sC SERVER_IP
```

**Sample Output** (abridged; full in lab logs):
```
PORT STATE SERVICE VERSION
22/tcp open ssh OpenSSH 9.6p1 Ubuntu 3ubuntu13.14 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
| 256 e1:cc:7e:36:a2:2d:e4:aa:48:e2:d2:a2:d8:d5:d3:a0 (ECDSA)
|_ 256 43:a0:97:17:d6:59:3a:aa:a0:33:4c:fb:13:7d:82:3a (ED25519)
3000/tcp open ppp?  # Unrecognized; HTTP redirects to /login (web app probe)
...
Nmap done: 1 IP address (1 host up) scanned in 98.21 seconds
```
- Discovered unexpected port 3000 (web service; addressed below).

## Testing Procedures and Verification
1. **Setup**: Install tools, confirm interfaces (`ip link show`).
2. **Traffic Generation**: SSH/ping between machines.
3. **Capture/Analyze**: tcpdump → tshark (fields, JSON, stats).
4. **Scan**: nmap with escalating intensity (-sn → -sS → -sV -sC).
5. **Cross-Verify**: MD5 hashes, ping stats, re-scan post-changes.
6. **Cleanup**: Delete PCAPs (`rm *.pcap`), reset UFW if needed.

All tests ran on November 14, 2025; no errors beyond expected firewall behaviors.

## Sample Outputs Summary
| Tool/Command | Key Finding | Notes |
|--------------|-------------|-------|
| tcpdump SSH | 10 packets, 1168 bytes | MD5: 40edf762692ed798a9e60309853ca117 |
| tshark SSH | Message code 20 (negotiation) | Protocol 2.0 handshake intact |
| ping -c 5 | 0% loss, 0.354 ms avg RTT | Bidirectional ICMP verified |
| nmap -sS | 22/tcp open; 999 filtered | Firewall active |
| nmap -sV | SSH 9.6p1; 3000/tcp HTTP? | ED25519 key; web redirect detected |

## Troubleshooting Common Errors
- **nmap "Host down"**: Firewall blocks ICMP—use `-Pn`. Verify with `ping`.
- **tshark "Invalid field"**: Check Wireshark docs (e.g., `ssh.protocol_version` not extractable; use `-V` for verbose).
- **tcpdump "No packets"**: Wrong interface/filter—test with `tcpdump -i enp0s3 -c 1`.
- **Sudo prompts**: Cache timeout; or use key-based SSH.
- **UFW blocks scans**: `sudo ufw status verbose`; allow specific: `sudo ufw allow from CLIENT_IP proto icmp`.

## Ethical and Security Recommendations
In this lab, I only scanned my own controlled environment—always obtain explicit permission for production scans to comply with laws (e.g., CFAA in the US). Use polite timing (`-T2`) to avoid DoS-like impacts.

Post-scan, I hardened the server:
```bash
sudo ufw deny 3000  # Block exposed web port
sudo ufw reload
```
**Updated UFW Status** (excerpt):
```
Status: active
To Action From
22/tcp ALLOW IN Anywhere
3000 DENY IN Anywhere  # Now blocked
```

**Production Tips**:
- Anonymize logs/PCAPs (e.g., scrub IPs with `editcap`).
- Integrate with SIEM (e.g., ELK Stack for tshark JSON).
- Automate: Cron nmap for alerts; rotate captures.
- Update regularly: `sudo apt upgrade openssh-server nmap`.
- Ethical scanning: Document intent, minimize noise, report vulns responsibly.
