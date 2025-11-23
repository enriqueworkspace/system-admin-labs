# Basic Monitoring with Native Linux Commands

This lab documents native Linux commands for system monitoring and troubleshooting, including diagnostics for processes, resources, storage, memory, network, and logs to identify performance issues.

## 1. top
Execute:
```
top
```

Purpose: Displays real-time active processes and system resource usage.

Observations:
- Load average reflects CPU load over 1, 5, and 15 minutes.
- Tasks summary includes total, running, sleeping, stopped, and zombie processes.
- %CPU and %MEM columns highlight high-usage processes.
- Idle CPU percentage and memory usage indicate availability.

Example output:
```
top - 22:24:07 up 19:58, 3 users, load average: 0.00, 0.00, 0.00
Tasks: 127 total, 1 running, 126 sleeping, 0 stopped, 0 zombie
%Cpu(s): 0.0 us, 0.0 sy, 0.0 ni, 99.8 id, 0.2 wa, 0.0 hi, 0.0 si, 0.0 st
MiB Mem : 5827.3 total, 3853.4 free, 535.9 used, 1724.6 buff/cache
MiB Swap: 0.0 total, 0.0 free, 0.0 used. 5291.4 avail Mem
```

## 2. htop
Execute:
```
htop
```

Purpose: Provides an interactive process viewer with visual representations of CPU per core, memory, swap, and processes.

Observations:
- Bars illustrate CPU usage per core and memory allocation.
- Color-coded processes facilitate analysis.
- Enables quick identification of high-resource consumers and system load.

## 3. vmstat
Execute:
```
vmstat 2 5
```

Purpose: Reports system statistics for CPU, memory, swap, I/O, and processes at intervals (2 seconds, 5 reports).

Observations:
- `r` column: Processes awaiting CPU.
- `wa` column: Time spent waiting for I/O.
- `id`: Idle CPU percentage.
- Elevated `wa` with low `id` signals potential disk bottlenecks.

## 4. ps
Execute:
```
ps -ef
```

Purpose: Lists all running processes in full detail.

Flags:
- `-e`: All processes.
- `-f`: Full format (UID, PID, PPID, time, command).

Observations:
- Reveals active processes and PIDs.
- Supports user/service association.
- Pair with `grep` for filtering (e.g., `ps -ef | grep apache`).

## 5. df
Execute:
```
df -h
```

Purpose: Reports disk usage per filesystem in human-readable format.

Observations:
- Displays total, used, and available space.
- Identifies full partitions or storage constraints.

## 6. du
Execute:
```
du -sh /var/log
```

Purpose: Estimates directory or file size in summarized, human-readable format.

Observations:
- Pinpoints space-intensive directories.
- Monitors logs or temporary files.

## 7. free
Execute:
```
free -h
```

Purpose: Shows memory usage (total, used, free, swap) in human-readable format.

Observations:
- Assesses RAM availability.
- Swap usage indicates memory pressure.

## 8. uptime
Execute:
```
uptime
```

Purpose: Reports system uptime and load average.

Observations:
- Indicates runtime duration.
- Load average summarizes CPU demand.

## 9. netstat
Execute:
```
netstat -tulnp
```

Purpose: Lists listening ports, connections, and associated processes.

Flags:
- `-t`: TCP.
- `-u`: UDP.
- `-l`: Listening.
- `-n`: Numeric.
- `-p`: PID/program.

Observations:
- Identifies active services and ports.
- Detects unauthorized openings.

## 10. lsof
Execute:
```
lsof -i :22
```

Purpose: Lists open files and network connections for debugging.

Observations:
- Reveals processes bound to ports (e.g., SSH on 22).
- Filters by user, directory, or name.

## 11. journalctl
Execute:
```
journalctl -xe | less
```

Purpose: Views system logs with explanations, paginated.

Observations:
- Captures errors, warnings, and events.
- Filters by service (`-u ssh`) or date.
- Aids in failure analysis.

## Summary
- `top`/`htop`: Real-time process and CPU monitoring.
- `vmstat`: CPU, memory, and I/O statistics.
- `ps`: Process details.
- `df`/`du`/`free`: Storage and memory assessment.
- `netstat`/`lsof`: Network and port inspection.
- `journalctl`: Log review.

These commands form the foundation for proactive system diagnostics.
