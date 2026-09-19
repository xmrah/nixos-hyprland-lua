#!/usr/bin/env python3
import glob
import os

procs = []
page_size = os.sysconf("SC_PAGE_SIZE")
total_ram = page_size * os.sysconf("SC_PHYS_PAGES")

for comm_path in glob.glob("/proc/[0-9]*/comm"):
    pid_dir = os.path.dirname(comm_path)
    try:
        with open(comm_path, "r") as f:
            comm = f.read().strip()
        with open(f"{pid_dir}/statm", "r") as f:
            rss = int(f.read().split()[1]) * page_size
        procs.append((comm, rss))
    except (FileNotFoundError, IndexError, PermissionError):
        continue

procs.sort(key=lambda x: x[1], reverse=True)
for comm, rss in procs[:5]:
    pct = (rss / total_ram) * 100
    print(f"{comm}|{pct:.1f}%")
