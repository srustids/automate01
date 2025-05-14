import psutil
import platform
import os
import time
import subprocess
from datetime import timedelta

def get_os_version():
    return platform.platform()

def get_uptime():
    boot_time = psutil.boot_time()
    uptime = time.time() - boot_time
    return str(timedelta(seconds=int(uptime)))

def get_load_average():
    if hasattr(os, "getloadavg"):
        return os.getloadavg()
    return (0.0, 0.0, 0.0)

def get_logged_in_users():
    users = psutil.users()
    return list(set(user.name for user in users))

def get_cpu_usage():
    return psutil.cpu_percent(interval=1)

def get_memory_usage():
    mem = psutil.virtual_memory()
    return {
        'total_MB': round(mem.total / (1024 ** 2), 2),
        'used_MB': round(mem.used / (1024 ** 2), 2),
        'free_MB': round(mem.available / (1024 ** 2), 2),
        'percent': mem.percent
    }

def get_disk_usage():
    disk = psutil.disk_usage('/')
    return {
        'total_GB': round(disk.total / (1024 ** 3), 2),
        'used_GB': round(disk.used / (1024 ** 3), 2),
        'free_GB': round(disk.free / (1024 ** 3), 2),
        'percent': disk.percent
    }

def get_top_processes(by="cpu", count=5):
    key = "cpu_percent" if by == "cpu" else "memory_percent"
    processes = []
    for proc in psutil.process_iter(attrs=["pid", "name", "cpu_percent", "memory_percent"]):
        try:
            processes.append(proc.info)
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            continue
    sorted_procs = sorted(processes, key=lambda p: p[key], reverse=True)
    return sorted_procs[:count]

if __name__ == "__main__":
    print("=== System Overview ===")
    print(f"OS Version: {get_os_version()}")
    print(f"System Uptime: {get_uptime()}")
    print(f"Load Average (1, 5, 15 min): {get_load_average()}")
    print(f"Logged-in Users: {get_logged_in_users()}")


    print("=== Resource Usage ===")
    print(f"Total CPU Usage: {get_cpu_usage()}%\n")

    mem = get_memory_usage()
    print(f"Memory:")
    print(f"  Total: {mem['total_MB']} MB")
    print(f"  Used:  {mem['used_MB']} MB")
    print(f"  Free:  {mem['free_MB']} MB")
    print(f"  Usage: {mem['percent']}%\n")

    disk = get_disk_usage()
    print(f"Disk (/):")
    print(f"  Total: {disk['total_GB']} GB")
    print(f"  Used:  {disk['used_GB']} GB")
    print(f"  Free:  {disk['free_GB']} GB")
    print(f"  Usage: {disk['percent']}%\n")

    print("Top 5 Processes by CPU Usage:")
    for p in get_top_processes(by="cpu"):
        print(f"  PID {p['pid']} - {p['name']} - CPU: {p['cpu_percent']}%")

    print("\nTop 5 Processes by Memory Usage:")
    for p in get_top_processes(by="memory"):
        print(f"  PID {p['pid']} - {p['name']} - Memory: {p['memory_percent']:.2f}%")
        