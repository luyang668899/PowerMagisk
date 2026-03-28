#!/system/bin/sh
# post-fs-data.sh - Performance optimization script

set -e

echo "Applying performance optimizations..."

# Memory management optimizations
echo "Optimizing memory management..."
# Adjust zRAM settings
if [ -d "/sys/block/zram0" ]; then
    # Set zRAM size to 50% of total RAM
    TOTAL_RAM=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')
    ZRAM_SIZE=$((TOTAL_RAM * 50 / 100))
    echo $ZRAM_SIZE > /sys/block/zram0/disksize
    mkswap /dev/block/zram0
    swapon /dev/block/zram0
fi

# Adjust VM settings
sysctl -w vm.swappiness=60
sysctl -w vm.vfs_cache_pressure=50
sysctl -w vm.dirty_background_ratio=5
sysctl -w vm.dirty_ratio=10

# CPU scheduling optimizations
echo "Optimizing CPU scheduling..."
# Set performance governor for all CPUs
for CPU in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    if [ -f "$CPU" ]; then
        echo "performance" > "$CPU"
    fi
done

# Adjust CPU scheduler settings
sysctl -w kernel.sched_autogroup_enabled=1
sysctl -w kernel.sched_latency_ns=10000000
sysctl -w kernel.sched_wakeup_granularity_ns=1500000
sysctl -w kernel.sched_tunable_scaling=1

# I/O performance optimizations
echo "Optimizing I/O performance..."
# Adjust I/O scheduler for all block devices
for DEV in /sys/block/*; do
    if [ -d "$DEV" ] && [ -f "$DEV/queue/scheduler" ]; then
        # Set deadline scheduler if available
        if grep -q "deadline" "$DEV/queue/scheduler"; then
            echo "deadline" > "$DEV/queue/scheduler"
        # Otherwise use cfq
        elif grep -q "cfq" "$DEV/queue/scheduler"; then
            echo "cfq" > "$DEV/queue/scheduler"
        fi
        
        # Adjust I/O scheduler settings
        if [ -f "$DEV/queue/iosched/read_expire" ]; then
            echo 100 > "$DEV/queue/iosched/read_expire"
        fi
        if [ -f "$DEV/queue/iosched/write_expire" ]; then
            echo 2000 > "$DEV/queue/iosched/write_expire"
        fi
        if [ -f "$DEV/queue/iosched/front_merges" ]; then
            echo 1 > "$DEV/queue/iosched/front_merges"
        fi
    fi
done

# Adjust I/O priorities
sysctl -w vm.dirty_writeback_centisecs=500
sysctl -w fs.inotify.max_user_watches=524288
sysctl -w fs.file-max=2097152

# Network performance optimizations
echo "Optimizing network performance..."
sysctl -w net.core.rmem_max=16777216
sysctl -w net.core.wmem_max=16777216
sysctl -w net.ipv4.tcp_fastopen=3
sysctl -w net.ipv4.tcp_slow_start_after_idle=0
sysctl -w net.ipv4.tcp_tw_reuse=1
sysctl -w net.ipv4.tcp_fin_timeout=30

# Process priority optimizations
echo "Optimizing process priorities..."
# Set higher priority for important system processes
for PID in $(pgrep -f "system_server"); do
    renice -n -5 $PID 2>/dev/null
done

for PID in $(pgrep -f "surfaceflinger"); do
    renice -n -10 $PID 2>/dev/null
done

echo "Performance optimizations applied successfully!"
