\# Lab 06 - Basic Monitoring with Native Commands



\## Objective

Learn and document the use of native Linux commands for monitoring and troubleshooting the system.  

Understand system diagnostics, resource usage, and identify potential performance issues.



\## Lab Path

`01-linux-administration/06-basic-monitoring`



\## Commands and Practices



---



\### 1. `top`

\*\*Command:\*\*  

```bash

top



Purpose:

Display active processes and system resource usage in real-time.



Observations:



Load average shows CPU load over the last 1, 5, and 15 minutes.



Tasks summary shows total processes, running, sleeping, stopped, and zombie processes.



%CPU and %MEM columns indicate which processes use the most CPU and memory.



Idle CPU percentage and memory usage indicate system availability.



Example output:



```

top - 22:24:07 up 19:58,  3 users,  load average: 0.00, 0.00, 0.00

Tasks: 127 total,   1 running, 126 sleeping,   0 stopped,   0 zombie

%Cpu(s):  0.0 us,  0.0 sy,  0.0 ni, 99.8 id,  0.2 wa,  0.0 hi,  0.0 si,  0.0 st

MiB Mem :   5827.3 total,   3853.4 free,    535.9 used,   1724.6 buff/cache

MiB Swap:      0.0 total,      0.0 free,      0.0 used.   5291.4 avail Mem

```

2\. htop



Command:

```

htop

```

Purpose:

Interactive process viewer; displays CPU per core, memory, swap, and process list visually.



Observations:



Bars show CPU usage per core and memory usage.



Processes are color-coded for easier analysis.



Useful for quickly identifying high-resource processes and overall system load.



3\. vmstat



Command:

```

vmstat 2 5

```

Purpose:

Show system statistics including CPU, memory, swap, I/O, and processes over time.



Observations:



r column shows processes waiting for CPU.



wa column indicates time waiting for I/O (disk or network).



id shows idle CPU percentage.



High wa with low id may indicate disk bottlenecks.



4\. ps



Command:

```

ps -ef

```

Purpose:

Display detailed list of all running processes.



Flags:



-e → show all processes



-f → full-format listing including UID, PID, PPID, time, and command



Observations:



Identify active processes and their PIDs.



Useful to check which processes belong to which user or service.



Can combine with grep to filter for specific processes.



5\. df



Command:

```

df -h

```

Purpose:

Check disk usage per filesystem in a human-readable format.



Observations:



Shows total, used, and available space.



Useful to detect full partitions or storage issues.



6\. du



Command:

```

du -sh /var/log

```

Purpose:

Measure size of a directory or file in a summarized, human-readable format.



Observations:



Helps find directories consuming large amounts of space.



Can be used to monitor log directories or temporary files.



7\. free



Command:

```

free -h

```

Purpose:

Display memory usage including total, used, free, and swap in human-readable format.



Observations:



Confirms RAM usage and availability.



Check swap usage to determine if the system is memory constrained.



8\. uptime



Command:

```

uptime

```

Purpose:

Check system uptime and load average.



Observations:



Shows how long the system has been running.



Load average gives a quick overview of CPU demand.



9\. netstat



Command:

```

netstat -tulnp

```

Purpose:

List listening ports, network connections, and associated processes.



Flags:



-t → TCP connections



-u → UDP connections



-l → listening ports



-n → numeric addresses and ports



-p → show PID/program name



Observations:



Identify which services are active and their ports.



Detect unauthorized services or open ports.



10\. lsof



Command:

```

lsof -i :22

```

Purpose:

List open files and network connections. Useful for debugging services.



Observations:



Shows which process is using a specific port (e.g., SSH on port 22).



Can filter by user, directory, or process name.



11\. journalctl



Command:

```

journalctl -xe | less

```

Purpose:

View detailed system logs with explanations, paginated for readability.



Observations:



Track system errors, warnings, and service events.



Can filter by service (journalctl -u ssh) or date.



Helps troubleshoot system and service failures.



Summary



This lab introduced the native Linux commands for system monitoring.

Key takeaways:



top/htop for real-time process and CPU monitoring.



vmstat for CPU, memory, and I/O analysis.



ps for process inspection.



df/du/free for storage and memory checks.



netstat/lsof for network and port monitoring.



journalctl for system logs.



