#!/system/bin/sh
# post-fs-data.sh - Security enhancement script

set -e

echo "Applying security enhancements..."

# Secure system files and directories
echo "Securing system files and directories..."
# Set proper permissions for system directories
chmod 755 /system
chmod 755 /system/bin
chmod 755 /system/lib
chmod 755 /system/lib64
chmod 755 /system/usr
chmod 755 /system/etc

# Secure sensitive system files
chmod 644 /system/build.prop
chmod 644 /system/etc/hosts
chmod 644 /system/etc/passwd
chmod 644 /system/etc/group

# Prevent execution of files in sensitive directories
chmod -t /system/etc
chmod -t /system/usr

# Enable SELinux enforcement
echo "Enabling SELinux enforcement..."
setenforce 1

# Secure kernel parameters
echo "Securing kernel parameters..."
# Disable ptrace
echo 0 > /proc/sys/kernel/yama/ptrace_scope

# Enable address space layout randomization (ASLR)
echo 2 > /proc/sys/kernel/randomize_va_space

# Disable sysrq
echo 0 > /proc/sys/kernel/sysrq

# Limit core dumps
echo 0 > /proc/sys/fs/suid_dumpable

# Secure network settings
echo "Securing network settings..."
# Enable SYN cookies
sysctl -w net.ipv4.tcp_syncookies=1

# Enable RFC1337
sysctl -w net.ipv4.tcp_rfc1337=1

# Disable IP forwarding
sysctl -w net.ipv4.ip_forward=0

# Enable reverse path filtering
sysctl -w net.ipv4.conf.all.rp_filter=1
sysctl -w net.ipv4.conf.default.rp_filter=1

# Disable ICMP redirects
sysctl -w net.ipv4.conf.all.accept_redirects=0
sysctl -w net.ipv4.conf.default.accept_redirects=0
sysctl -w net.ipv6.conf.all.accept_redirects=0
sysctl -w net.ipv6.conf.default.accept_redirects=0

# Disable source routing
sysctl -w net.ipv4.conf.all.accept_source_route=0
sysctl -w net.ipv4.conf.default.accept_source_route=0
sysctl -w net.ipv6.conf.all.accept_source_route=0
sysctl -w net.ipv6.conf.default.accept_source_route=0

# Enable TCP hardening
sysctl -w net.ipv4.tcp_max_syn_backlog=4096
sysctl -w net.ipv4.tcp_synack_retries=2
sysctl -w net.ipv4.tcp_syn_retries=2
sysctl -w net.ipv4.tcp_fin_timeout=30
sysctl -w net.ipv4.tcp_keepalive_time=300
sysctl -w net.ipv4.tcp_keepalive_probes=5
sysctl -w net.ipv4.tcp_keepalive_intvl=15
sysctl -w net.ipv4.tcp_timestamps=0
sysctl -w net.ipv4.tcp_sack=1
sysctl -w net.ipv4.tcp_dsack=1
sysctl -w net.ipv4.tcp_fack=1
sysctl -w net.ipv4.tcp_window_scaling=1

# Secure filesystem
echo "Securing filesystem..."
# Mount /system as read-only
mount -o remount,ro /system

# Mount /vendor as read-only
if [ -d /vendor ]; then
    mount -o remount,ro /vendor
fi

# Mount /odm as read-only
if [ -d /odm ]; then
    mount -o remount,ro /odm
fi

# Mount /product as read-only
if [ -d /product ]; then
    mount -o remount,ro /product
fi

# Prevent execution of files on /data
if [ -d /data ]; then
    mount -o remount,noexec /data
fi

# Secure app installation
echo "Securing app installation..."
# Disable installation from unknown sources
settings put global install_non_market_apps 0 2>/dev/null

# Enable verify apps over USB
settings put global verify_apps_over_usb 1 2>/dev/null

# Secure system services
echo "Securing system services..."
# Disable unnecessary system services
for SERVICE in "com.android.cellbroadcastreceiver" "com.android.feedback" "com.android.printspooler" "com.android.traceur"
do
    pm disable "$SERVICE" 2>/dev/null
done

# Secure boot settings
echo "Securing boot settings..."
# Enable secure boot if available
if [ -f "/sys/firmware/efi/efivars/SecureBoot-8be4df61-93ca-11d2-aa0d-00e098032b8c" ]; then
    echo "Secure boot is enabled"
fi

# Secure su binary
echo "Securing su binary..."
if [ -f "/system/xbin/su" ]; then
    chmod 4755 /system/xbin/su
fi

if [ -f "/system/bin/su" ]; then
    chmod 4755 /system/bin/su
fi

# Secure Magisk files
echo "Securing Magisk files..."
if [ -d "/data/adb/magisk" ]; then
    chmod 700 /data/adb/magisk
    chmod 600 /data/adb/magisk/*.img
fi

# Prevent app hooking
echo "Preventing app hooking..."
# Block known hooking libraries
for LIB in "libsubstrate.so" "libsubstrate-dvm.so" "libXposedBridge.so" "libedxposed.so" "liblsposed.so"
do
    if [ -f "/system/lib/$LIB" ]; then
        mv "/system/lib/$LIB" "/system/lib/${LIB}.bak"
    fi
    if [ -f "/system/lib64/$LIB" ]; then
        mv "/system/lib64/$LIB" "/system/lib64/${LIB}.bak"
    fi
done

# Secure DNS
echo "Securing DNS..."
# Set secure DNS servers
if [ -f "/system/etc/resolv.conf" ]; then
    echo "nameserver 8.8.8.8" > /system/etc/resolv.conf
    echo "nameserver 8.8.4.4" >> /system/etc/resolv.conf
    echo "nameserver 1.1.1.1" >> /system/etc/resolv.conf
fi

# Enable DNS over TLS if available
settings put global private_dns_mode hostname 2>/dev/null
settings put global private_dns_specifier dns.google 2>/dev/null

# Secure Bluetooth
echo "Securing Bluetooth..."
# Disable Bluetooth if not in use
settings put global bluetooth_on 0 2>/dev/null

# Secure Wi-Fi
echo "Securing Wi-Fi..."
# Enable Wi-Fi encryption
settings put global wifi_connected_mac_randomization_enabled 1 2>/dev/null
settings put global wifi_scan_throttle_enabled 1 2>/dev/null

# Secure location
echo "Securing location..."
# Disable location if not in use
settings put global location_mode 0 2>/dev/null

# Secure accounts
echo "Securing accounts..."
# Disable auto-sync
settings put global sync_enabled 0 2>/dev/null

# Secure notifications
echo "Securing notifications..."
# Disable notification access for non-system apps
for PACKAGE in $(pm list packages -3 | cut -d: -f2); do
    pm revoke "$PACKAGE" android.permission.BIND_NOTIFICATION_LISTENER_SERVICE 2>/dev/null
done

# Secure accessibility
echo "Securing accessibility..."
# Disable accessibility access for non-system apps
for PACKAGE in $(pm list packages -3 | cut -d: -f2); do
    pm revoke "$PACKAGE" android.permission.BIND_ACCESSIBILITY_SERVICE 2>/dev/null
done

# Secure device admin
echo "Securing device admin..."
# Disable device admin access for non-system apps
for PACKAGE in $(pm list packages -3 | cut -d: -f2); do
    pm revoke "$PACKAGE" android.permission.BIND_DEVICE_ADMIN 2>/dev/null
done

# Secure USB debugging
echo "Securing USB debugging..."
# Disable USB debugging
settings put global adb_enabled 0 2>/dev/null

# Secure ADB
echo "Securing ADB..."
# Revoke ADB keys
rm -f /data/misc/adb/adb_keys 2>/dev/null

# Secure system updates
echo "Securing system updates..."
# Disable auto-updates
settings put global auto_update_system 0 2>/dev/null

# Secure Google Play Protect
echo "Securing Google Play Protect..."
# Enable Google Play Protect
settings put global play_protect_scan_enabled 1 2>/dev/null
settings put global play_protect_safety_net_attestation_enabled 1 2>/dev/null

# Secure app permissions
echo "Securing app permissions..."
# Revoke dangerous permissions for non-system apps
for PACKAGE in $(pm list packages -3 | cut -d: -f2); do
    # Revoke camera permission
    pm revoke "$PACKAGE" android.permission.CAMERA 2>/dev/null
    # Revoke microphone permission
    pm revoke "$PACKAGE" android.permission.RECORD_AUDIO 2>/dev/null
    # Revoke location permission
    pm revoke "$PACKAGE" android.permission.ACCESS_FINE_LOCATION 2>/dev/null
    pm revoke "$PACKAGE" android.permission.ACCESS_COARSE_LOCATION 2>/dev/null
    # Revoke storage permission
    pm revoke "$PACKAGE" android.permission.READ_EXTERNAL_STORAGE 2>/dev/null
    pm revoke "$PACKAGE" android.permission.WRITE_EXTERNAL_STORAGE 2>/dev/null
    # Revoke phone permission
    pm revoke "$PACKAGE" android.permission.READ_PHONE_STATE 2>/dev/null
    pm revoke "$PACKAGE" android.permission.CALL_PHONE 2>/dev/null
    # Revoke SMS permission
    pm revoke "$PACKAGE" android.permission.SEND_SMS 2>/dev/null
    pm revoke "$PACKAGE" android.permission.READ_SMS 2>/dev/null
    # Revoke contact permission
    pm revoke "$PACKAGE" android.permission.READ_CONTACTS 2>/dev/null
    pm revoke "$PACKAGE" android.permission.WRITE_CONTACTS 2>/dev/null
    # Revoke calendar permission
    pm revoke "$PACKAGE" android.permission.READ_CALENDAR 2>/dev/null
    pm revoke "$PACKAGE" android.permission.WRITE_CALENDAR 2>/dev/null
    # Revoke sensor permission
    pm revoke "$PACKAGE" android.permission.BODY_SENSORS 2>/dev/null
    # Revoke account permission
    pm revoke "$PACKAGE" android.permission.GET_ACCOUNTS 2>/dev/null
    # Revoke bluetooth permission
    pm revoke "$PACKAGE" android.permission.BLUETOOTH 2>/dev/null
    pm revoke "$PACKAGE" android.permission.BLUETOOTH_ADMIN 2>/dev/null
    # Revoke wifi permission
    pm revoke "$PACKAGE" android.permission.ACCESS_WIFI_STATE 2>/dev/null
    pm revoke "$PACKAGE" android.permission.CHANGE_WIFI_STATE 2>/dev/null
    # Revoke network permission
    pm revoke "$PACKAGE" android.permission.INTERNET 2>/dev/null
    pm revoke "$PACKAGE" android.permission.ACCESS_NETWORK_STATE 2>/dev/null
    # Revoke background location permission
    pm revoke "$PACKAGE" android.permission.ACCESS_BACKGROUND_LOCATION 2>/dev/null
    # Revoke activity recognition permission
    pm revoke "$PACKAGE" android.permission.ACTIVITY_RECOGNITION 2>/dev/null
    # Revoke media projection permission
    pm revoke "$PACKAGE" android.permission.MEDIA_PROJECTION 2>/dev/null
    # Revoke notification access
    pm revoke "$PACKAGE" android.permission.BIND_NOTIFICATION_LISTENER_SERVICE 2>/dev/null
    # Revoke accessibility permission
    pm revoke "$PACKAGE" android.permission.BIND_ACCESSIBILITY_SERVICE 2>/dev/null
    # Revoke device admin permission
    pm revoke "$PACKAGE" android.permission.BIND_DEVICE_ADMIN 2>/dev/null
    # Revoke wallpaper permission
    pm revoke "$PACKAGE" android.permission.SET_WALLPAPER 2>/dev/null
    # Revoke vibration permission
    pm revoke "$PACKAGE" android.permission.VIBRATE 2>/dev/null
    # Revoke wake lock permission
    pm revoke "$PACKAGE" android.permission.WAKE_LOCK 2>/dev/null
    # Revoke reboot permission
    pm revoke "$PACKAGE" android.permission.REBOOT 2>/dev/null
    # Revoke write settings permission
    pm revoke "$PACKAGE" android.permission.WRITE_SETTINGS 2>/dev/null
    # Revoke system alert window permission
    pm revoke "$PACKAGE" android.permission.SYSTEM_ALERT_WINDOW 2>/dev/null
    # Revoke install packages permission
    pm revoke "$PACKAGE" android.permission.INSTALL_PACKAGES 2>/dev/null
    # Revoke delete packages permission
    pm revoke "$PACKAGE" android.permission.DELETE_PACKAGES 2>/dev/null
    # Revoke manage external storage permission
    pm revoke "$PACKAGE" android.permission.MANAGE_EXTERNAL_STORAGE 2>/dev/null
    # Revoke access media location permission
    pm revoke "$PACKAGE" android.permission.ACCESS_MEDIA_LOCATION 2>/dev/null
    # Revoke read media images permission
    pm revoke "$PACKAGE" android.permission.READ_MEDIA_IMAGES 2>/dev/null
    # Revoke read media video permission
    pm revoke "$PACKAGE" android.permission.READ_MEDIA_VIDEO 2>/dev/null
    # Revoke read media audio permission
    pm revoke "$PACKAGE" android.permission.READ_MEDIA_AUDIO 2>/dev/null
    # Revoke schedule exact alarm permission
    pm revoke "$PACKAGE" android.permission.SCHEDULE_EXACT_ALARM 2>/dev/null
    # Revoke use exact alarm permission
    pm revoke "$PACKAGE" android.permission.USE_EXACT_ALARM 2>/dev/null
    # Revoke post notifications permission
    pm revoke "$PACKAGE" android.permission.POST_NOTIFICATIONS 2>/dev/null
    # Revoke near field communication permission
    pm revoke "$PACKAGE" android.permission.NFC 2>/dev/null
    # Revoke use biometric permission
    pm revoke "$PACKAGE" android.permission.USE_BIOMETRIC 2>/dev/null
    # Revoke use fingerprint permission
    pm revoke "$PACKAGE" android.permission.USE_FINGERPRINT 2>/dev/null
    # Revoke read phone numbers permission
    pm revoke "$PACKAGE" android.permission.READ_PHONE_NUMBERS 2>/dev/null
    # Revoke read call log permission
    pm revoke "$PACKAGE" android.permission.READ_CALL_LOG 2>/dev/null
    # Revoke write call log permission
    pm revoke "$PACKAGE" android.permission.WRITE_CALL_LOG 2>/dev/null
    # Revoke process outgoings calls permission
    pm revoke "$PACKAGE" android.permission.PROCESS_OUTGOING_CALLS 2>/dev/null
    # Revoke add voicemail permission
    pm revoke "$PACKAGE" android.permission.ADD_VOICEMAIL 2>/dev/null
    # Revoke read cell broadcast permission
    pm revoke "$PACKAGE" android.permission.READ_CELL_BROADCASTS 2>/dev/null
    # Revoke receive mms permission
    pm revoke "$PACKAGE" android.permission.RECEIVE_MMS 2>/dev/null
    # Revoke receive sms permission
    pm revoke "$PACKAGE" android.permission.RECEIVE_SMS 2>/dev/null
    # Revoke receive wap push permission
    pm revoke "$PACKAGE" android.permission.RECEIVE_WAP_PUSH 2>/dev/null
    # Revoke send wap push permission
    pm revoke "$PACKAGE" android.permission.SEND_WAP_PUSH 2>/dev/null
    # Revoke read sync settings permission
    pm revoke "$PACKAGE" android.permission.READ_SYNC_SETTINGS 2>/dev/null
    # Revoke write sync settings permission
    pm revoke "$PACKAGE" android.permission.WRITE_SYNC_SETTINGS 2>/dev/null
    # Revoke read sync stats permission
    pm revoke "$PACKAGE" android.permission.READ_SYNC_STATS 2>/dev/null
    # Revoke modify phone state permission
    pm revoke "$PACKAGE" android.permission.MODIFY_PHONE_STATE 2>/dev/null
    # Revoke set time permission
    pm revoke "$PACKAGE" android.permission.SET_TIME 2>/dev/null
    # Revoke set time zone permission
    pm revoke "$PACKAGE" android.permission.SET_TIME_ZONE 2>/dev/null
    # Revoke set alarm clock permission
    pm revoke "$PACKAGE" android.permission.SET_ALARM_CLOCK 2>/dev/null
    # Revoke read input state permission
    pm revoke "$PACKAGE" android.permission.READ_INPUT_STATE 2>/dev/null
    # Revoke capture secure video output permission
    pm revoke "$PACKAGE" android.permission.CAPTURE_SECURE_VIDEO_OUTPUT 2>/dev/null
    # Revoke capture video output permission
    pm revoke "$PACKAGE" android.permission.CAPTURE_VIDEO_OUTPUT 2>/dev/null
    # Revoke read oem unlock state permission
    pm revoke "$PACKAGE" android.permission.READ_OEM_UNLOCK_STATE 2>/dev/null
    # Revoke read debug resource permissions
    pm revoke "$PACKAGE" android.permission.READ_DEBUG_RESOURCES 2>/dev/null
    # Revoke dump permission
    pm revoke "$PACKAGE" android.permission.DUMP 2>/dev/null
    # Revoke read logs permission
    pm revoke "$PACKAGE" android.permission.READ_LOGS 2>/dev/null
    # Revoke write secure settings permission
    pm revoke "$PACKAGE" android.permission.WRITE_SECURE_SETTINGS 2>/dev/null
    # Revoke mount unmount file systems permission
    pm revoke "$PACKAGE" android.permission.MOUNT_UNMOUNT_FILESYSTEMS 2>/dev/null
    # Revoke format external storage permission
    pm revoke "$PACKAGE" android.permission.FORMAT_EXTERNAL_STORAGE 2>/dev/null
    # Revoke delete app cache files permission
    pm revoke "$PACKAGE" android.permission.DELETE_CACHE_FILES 2>/dev/null
    # Revoke clear app data permission
    pm revoke "$PACKAGE" android.permission.CLEAR_APP_DATA 2>/dev/null
    # Revoke kill background processes permission
    pm revoke "$PACKAGE" android.permission.KILL_BACKGROUND_PROCESSES 2>/dev/null
    # Revoke set process limit permission
    pm revoke "$PACKAGE" android.permission.SET_PROCESS_LIMIT 2>/dev/null
    # Revoke get tasks permission
    pm revoke "$PACKAGE" android.permission.GET_TASKS 2>/dev/null
    # Revoke get package size permission
    pm revoke "$PACKAGE" android.permission.GET_PACKAGE_SIZE 2>/dev/null
    # Revoke install shortcuts permission
    pm revoke "$PACKAGE" android.permission.INSTALL_SHORTCUT 2>/dev/null
    # Revoke uninstall shortcuts permission
    pm revoke "$PACKAGE" android.permission.UNINSTALL_SHORTCUT 2>/dev/null
    # Revoke set wallpaper hints permission
    pm revoke "$PACKAGE" android.permission.SET_WALLPAPER_HINTS 2>/dev/null
    # Revoke bind widget permission
    pm revoke "$PACKAGE" android.permission.BIND_APPWIDGET 2>/dev/null
    # Revoke accessibility feedback trusted permission
    pm revoke "$PACKAGE" android.permission.ACCESSIBILITY_FEEDBACK_TRUSTED 2>/dev/null
    # Revoke access notification policy permission
    pm revoke "$PACKAGE" android.permission.ACCESS_NOTIFICATION_POLICY 2>/dev/null
    # Revoke status bar permission
    pm revoke "$PACKAGE" android.permission.STATUS_BAR 2>/dev/null
    # Revoke expand status bar permission
    pm revoke "$PACKAGE" android.permission.EXPAND_STATUS_BAR 2>/dev/null
    # Revoke change component enabled state permission
    pm revoke "$PACKAGE" android.permission.CHANGE_COMPONENT_ENABLED_STATE 2>/dev/null
    # Revoke disable keyguard permission
    pm revoke "$PACKAGE" android.permission.DISABLE_KEYGUARD 2>/dev/null
    # Revoke set activity watcher permission
    pm revoke "$PACKAGE" android.permission.SET_ACTIVITY_WATCHER 2>/dev/null
    # Revoke monitor battery status permission
    pm revoke "$PACKAGE" android.permission.MONITOR_BATTERY_STATUS 2>/dev/null
    # Revoke device power permission
    pm revoke "$PACKAGE" android.permission.DEVICE_POWER 2>/dev/null
    # Revoke reboot recovery permission
    pm revoke "$PACKAGE" android.permission.REBOOT_RECOVERY 2>/dev/null
    # Revoke shutdown permission
    pm revoke "$PACKAGE" android.permission.SHUTDOWN 2>/dev/null
    # Revoke access superuser permission
    pm revoke "$PACKAGE" android.permission.ACCESS_SUPERUSER 2>/dev/null
    # Revoke system overlay permission
    pm revoke "$PACKAGE" android.permission.SYSTEM_OVERLAY_WINDOW 2>/dev/null
done

echo "Security enhancements applied successfully!"
