#!/system/bin/sh
# post-fs-data.sh - Battery optimization script

set -e

echo "Applying battery optimizations..."

# Reduce background app wakeups
echo "Reducing background app wakeups..."
# Disable Google Play Services wakeups
if [ -d "/data/data/com.google.android.gms" ]; then
    # Disable GMS doze whitelist
    settings put global device_idle_constants "default_factor=1.0" 2>/dev/null
    # Force GMS into doze
    dumpsys deviceidle force-idle com.google.android.gms 2>/dev/null
fi

# Disable unnecessary system services
echo "Disabling unnecessary system services..."
# Disable unused system services
for SERVICE in "com.android.cellbroadcastreceiver" "com.android.feedback" "com.android.printspooler" "com.android.traceur" "com.google.android.apps.tachyon" "com.google.android.googlequicksearchbox"
do
    pm disable "$SERVICE" 2>/dev/null
done

# Optimize CPU settings for battery
echo "Optimizing CPU settings..."
# Set ondemand governor for all CPUs
for CPU in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    if [ -f "$CPU" ]; then
        echo "ondemand" > "$CPU"
    fi
done

# Adjust CPU frequency limits
for CPU in /sys/devices/system/cpu/cpu*/cpufreq; do
    if [ -d "$CPU" ]; then
        # Set minimum frequency to lowest possible
        if [ -f "$CPU/scaling_min_freq" ]; then
            MIN_FREQ=$(cat "$CPU/scaling_available_frequencies" | awk '{print $1}')
            echo "$MIN_FREQ" > "$CPU/scaling_min_freq"
        fi
        # Set maximum frequency to 70% of maximum
        if [ -f "$CPU/scaling_max_freq" ] && [ -f "$CPU/scaling_available_frequencies" ]; then
            MAX_FREQ=$(cat "$CPU/scaling_available_frequencies" | awk '{print $NF}')
            NEW_MAX=$((MAX_FREQ * 70 / 100))
            echo "$NEW_MAX" > "$CPU/scaling_max_freq"
        fi
    fi
done

# Optimize screen settings
echo "Optimizing screen settings..."
# Set screen brightness to auto
settings put system screen_brightness_mode 1 2>/dev/null
# Reduce screen timeout
settings put system screen_off_timeout 30000 2>/dev/null # 30 seconds

# Optimize network settings
echo "Optimizing network settings..."
# Disable unnecessary network features
settings put global mobile_data always_on 0 2>/dev/null
settings put global wifi_scan_interval 180 2>/dev/null # 3 minutes
settings put global wifi_sleep_policy 2 2>/dev/null # Never

# Optimize hardware power consumption
echo "Optimizing hardware power consumption..."
# Disable unused hardware
if [ -f "/sys/devices/system/cpu/cpu3/online" ]; then
    echo 0 > /sys/devices/system/cpu/cpu3/online 2>/dev/null
fi
if [ -f "/sys/devices/system/cpu/cpu2/online" ]; then
    echo 0 > /sys/devices/system/cpu/cpu2/online 2>/dev/null
fi

# Optimize storage I/O
echo "Optimizing storage I/O..."
# Reduce I/O activity
sysctl -w vm.dirty_background_ratio=3
sysctl -w vm.dirty_ratio=10
sysctl -w vm.swappiness=10

# Optimize system services
echo "Optimizing system services..."
# Disable unnecessary system services
for SERVICE in "bluetooth" "nfc" "location"
do
    if [ -f "/system/bin/service" ]; then
        service call "$SERVICE" 2>/dev/null || true
    fi
done

# Enable doze mode for all apps
echo "Enabling doze mode for all apps..."
# Force all apps into doze
for PACKAGE in $(pm list packages | cut -d: -f2); do
    dumpsys deviceidle whitelist -package "$PACKAGE" 2>/dev/null || true
done

# Optimize battery saver settings
echo "Optimizing battery saver settings..."
# Enable battery saver at 20%
settings put global low_power_trigger_level 20 2>/dev/null
# Enable adaptive battery
settings put global adaptive_battery_management_enabled 1 2>/dev/null

echo "Battery optimizations applied successfully!"
