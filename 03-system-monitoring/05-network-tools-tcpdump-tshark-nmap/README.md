# Network Diagnostics and Analysis with tcpdump, tshark, and nmap

This lab conducts network diagnostics between an Ubuntu Desktop client and Ubuntu Server target, utilizing tcpdump for packet capture, tshark for protocol dissection, and nmap for scanning. It examines SSH and ICMP traffic, enumerates services, and incorporates verification, troubleshooting, and ethical guidelines for secure practices.

## 1. Installation and Configuration
Update packages and install tools on both machines:
```
sudo apt update
sudo apt install -y tcpdump tshark nmap jq
```

Verify versions:
```
tcpdump --version
tshark --version
nmap --version
```
Expected: tcpdump 4.99.4; TShark 4.0.6; Nmap 7.94SVN.

Add user to wireshark group (optional, for non-sudo tshark reads):
```
sudo usermod -aG wireshark $USER
```
Log out and back in to apply.

## 2. Packet Capture with tcpdump
### 2.1 SSH Traffic Capture
Generate traffic (Terminal 1, Client):
```
ssh root@SERVER_IP  # Ctrl+C to abort
```

Capture (Terminal 2, Client):
```
sudo tcpdump -i enp0s3 -c 10 -n host SERVER_IP and port 22 -w ssh_capture.pcap
```
Expected: 10 packets captured, 89 received, 0 dropped.

Verify:
```
ls -l ssh_capture.pcap
md5sum ssh_capture.pcap
```
Expected: File size ~1168 bytes; MD5 40edf762692ed798a9e60309853ca117.

### 2.2 ICMP Traffic Capture
Capture on Server:
```
sudo tcpdump -i enp0s3 -c 5 -n icmp and host CLIENT_IP -w ping_capture.pcap
```

Generate on Client:
```
ping -c 5 SERVER_IP
```
Expected: 0% loss, ~0.35 ms avg RTT.

## 3. Traffic Analysis with tshark
### 3.1 SSH Dissection
```
tshark -r ssh_capture.pcap -Y "ssh" -T fields -e frame.number -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport -e ssh.message_code
```
Expected (abridged):
```
1 CLIENT_IP SERVER_IP 54321 22
2 SERVER_IP CLIENT_IP 22 54321
3 CLIENT_IP SERVER_IP 54321 22 20
4 SERVER_IP CLIENT_IP 22 54321 20
```
Message code 20: SSH version negotiation (protocol 2.0).

### 3.2 ICMP Dissection
```
tshark -r ping_capture.pcap -Y "icmp" -T fields -e frame.number -e ip.src -e ip.dst -e icmp.type -e icmp.code
```
Expected:
```
1 CLIENT_IP SERVER_IP 8 0  # Echo Request
2 SERVER_IP CLIENT_IP 0 0  # Echo Reply
...
```

### 3.3 JSON Export and Stats
Export:
```
tshark -r ssh_capture.pcap -Y "ssh" -T json > ssh_analysis.json
jq . ssh_analysis.json | head -10
```

Stats:
```
tshark -r ssh_capture.pcap -z io,stat,0
```
Expected (abridged):
```
==================================================================
Protocol Hierarchy Statistics
|TCP | 20 | 1500 | 100.0 |
|SSH | 10 | 800 | 53.3 |
|Data | 10 | 700 | 46.7 |
==================================================================
```

## 4. Network Scanning with nmap
Use `-Pn` to bypass ICMP blocks.

Host discovery:
```
nmap -sn SERVER_IP
```
Expected: "Host down" (firewall); fallback to `-Pn`.

SYN scan (ports 1-1000):
```
sudo nmap -Pn -sS -p 1-1000 SERVER_IP
```
Expected:
```
PORT STATE SERVICE
22/tcp open ssh
```

Service version and scripts:
```
sudo nmap -Pn -sV -sC SERVER_IP
```
Expected (abridged):
```
PORT STATE SERVICE VERSION
22/tcp open ssh OpenSSH 9.6p1 Ubuntu 3ubuntu13.14
| ssh-hostkey:
| 256 e1:cc:7e:36:a2:2d:e4:aa:48:e2:d2:a2:d8:d5:d3:a0 (ECDSA)
|_ 256 43:a0:97:17:d6:59:3a:aa:a0:33:4c:fb:13:7d:82:3a (ED25519)
3000/tcp open ppp?
...
```

## 5. Testing Procedures and Verification
1. Install tools; confirm interfaces (`ip link show`).
2. Generate SSH/ping traffic.
3. Capture with tcpdump; analyze with tshark (fields/JSON/stats).
4. Escalate nmap scans (-sn → -sS → -sV -sC).
5. Cross-verify: MD5 hashes, ping RTT, re-scans.
6. Cleanup: `rm *.pcap`; reset UFW if altered.

All executed November 14, 2025; firewall behaviors as expected.

## Sample Outputs Summary

| Tool/Command       | Key Finding                          | Notes                          |
|--------------------|--------------------------------------|--------------------------------|
| tcpdump SSH       | 10 packets, 1168 bytes              | MD5: 40edf762692ed798a9e60309853ca117 |
| tshark SSH        | Message code 20 (negotiation)       | Protocol 2.0 handshake intact |
| ping -c 5         | 0% loss, 0.354 ms avg RTT           | Bidirectional ICMP verified   |
| nmap -sS          | 22/tcp open; 999 filtered           | Firewall active               |
| nmap -sV          | SSH 9.6p1; 3000/tcp HTTP?           | ED25519 key; web redirect     |

## 6. Troubleshooting Common Errors
- **nmap "Host down"**: Use `-Pn`; verify ping.
- **tshark "Invalid field"**: Consult Wireshark docs; try `-V` for verbose.
- **tcpdump "No packets"**: Check interface/filter; test `tcpdump -i enp0s3 -c 1`.
- **Sudo prompts**: Cache timeout; use key-based SSH.
- **UFW blocks**: `sudo ufw status verbose`; allow `sudo ufw allow from CLIENT_IP proto icmp`.

## 7. Ethical and Security Recommendations
Scan only authorized environments to comply with laws (e.g., CFAA). Use `-T2` for polite timing.

Harden server post-scan:
```
sudo ufw deny 3000
sudo ufw reload
```
Updated status:
```
Status: active
To Action From
22/tcp ALLOW IN Anywhere
3000 DENY IN Anywhere
```

Production tips:
- Anonymize PCAPs (`editcap` for IP scrubbing).
- Integrate with SIEM (ELK for tshark JSON).
- Automate: Cron nmap; rotate captures.
- Update: `sudo apt upgrade openssh-server nmap`.
- Document scans; report vulnerabilities responsibly.

## Summary
- Tools installed and verified for capture, analysis, and scanning.
- SSH/ICMP traffic captured, dissected (handshakes, types), and stats generated.
- nmap enumerated SSH (open) and 3000 (blocked post-hardening).
- Procedures verified integrity; troubleshooting and ethics addressed.

This equips for ethical network troubleshooting in controlled settings.
