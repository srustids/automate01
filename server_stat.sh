#!/bin/bash

echo "--------------------------------------------------"
echo "System Resource Usage Report"
echo "--------------------------------------------------"
echo ""

# --- Total CPU Usage ---
echo "--- Total CPU Usage ---"
# Get the CPU idle percentage from 'top' command (batch mode, 1 iteration)
# Subtract idle from 100 to get total CPU usage.
# Uses awk to parse the 'Cpu(s)' line.
CPU_USAGE_MPSTAT=$(mpstat 1 1 | awk '/Average:/ && $NF ~ /[0-9.]+/ {print 100 - $NF}')
echo "CPU Usage (mpstat): $CPU_USAGE_MPSTAT%"
echo ""

# --- Total Memory Usage (Free vs Used including percentage) ---
echo "--- Total Memory Usage ---"
# Use 'free -m' to get memory stats in Megabytes.
# Use awk to parse and format the output.
free -m | awk 'NR==1{printf "Memory Type:\t%s\t%s\t%s\t%s\n",$1,$2,$3,$4} NR==2{printf "Memory:\t\t%s MB\t%s MB\t%s MB\t(%.2f%% Used)\n",$2,$3,$4,($3/$2)*100} NR==3{printf "Swap:\t\t%s MB\t%s MB\t%s MB\t(%.2f%% Used)\n",$2,$3,$4,($3/($2==0?1:$2))*100}'
# An alternative for more detailed "available" memory perspective:
echo ""
echo "Memory (alternative view):"
MEM_INFO=$(free -m)
TOTAL_MEM=$(echo "$MEM_INFO" | awk 'NR==2{print $2}')
USED_MEM=$(echo "$MEM_INFO" | awk 'NR==2{print $3}')
FREE_MEM=$(echo "$MEM_INFO" | awk 'NR==2{print $4}')
SHARED_MEM=$(echo "$MEM_INFO" | awk 'NR==2{print $5}')
BUFF_CACHE_MEM=$(echo "$MEM_INFO" | awk 'NR==2{print $6}')
AVAILABLE_MEM=$(echo "$MEM_INFO" | awk 'NR==2{print $7}') # Available is often a better indicator of free memory

USED_PERCENTAGE=$(awk -v used="$USED_MEM" -v total="$TOTAL_MEM" 'BEGIN {printf "%.2f", (used/total)*100}')
AVAILABLE_PERCENTAGE=$(awk -v available="$AVAILABLE_MEM" -v total="$TOTAL_MEM" 'BEGIN {printf "%.2f", (available/total)*100}')

echo "Total Memory: ${TOTAL_MEM}MB"
echo "Used Memory: ${USED_MEM}MB (${USED_PERCENTAGE}%)"
echo "Free Memory (raw): ${FREE_MEM}MB"
echo "Available Memory (for applications): ${AVAILABLE_MEM}MB (${AVAILABLE_PERCENTAGE}% of Total)"
echo "Buffers/Cache: ${BUFF_CACHE_MEM}MB"
echo ""


# --- Total Disk Usage (Free vs Used including percentage) ---
echo "--- Total Disk Usage ---"
# Use 'df -hP' to get disk usage for all filesystems in human-readable format.
# The '-P' option ensures POSIX standard output, preventing line wrapping issues.
# The header is printed, then awk formats each line.
df -hP | awk 'NR==1{printf "%-30s\t%-10s\t%-10s\t%-10s\t%-10s\t%-20s\n", $1,$2,$3,$4,$5,$6; next} {printf "%-30s\t%-10s\t%-10s\t%-10s\t%-10s\t%-20s\n", $1,$2,$3,$4,$5,$6}'
echo ""


echo "--------------------------------------------------"
echo "End of Report"
echo "--------------------------------------------------"