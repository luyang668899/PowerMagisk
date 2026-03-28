#!/system/bin/sh
# post-fs-data.sh - Privacy protection script

set -e

echo "Applying privacy protections..."

# Block apps from collecting sensitive information
echo "Blocking apps from collecting sensitive information..."
# Block advertising ID
settings put global advertising_id_opt_out 1 2>/dev/null
settings put global limit_ad_tracking 1 2>/dev/null

# Block location tracking for apps
settings put global location_mode 0 2>/dev/null # No location

# Block usage statistics
settings put global send_action_app 0 2>/dev/null
settings put global send_usage_stats 0 2>/dev/null

# Block diagnostic data
settings put global diagnostic_data_enabled 0 2>/dev/null

# Block app clipboard access
settings put global clipboard_access_disabled 1 2>/dev/null

# Limit permission abuse
echo "Limiting permission abuse..."
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

# Block tracking domains
echo "Blocking tracking domains..."
# Add hosts file entries to block tracking domains
if [ -f "/system/etc/hosts" ]; then
    echo "# Block tracking domains" >> /system/etc/hosts
    echo "127.0.0.1 analytics.google.com" >> /system/etc/hosts
    echo "127.0.0.1 ads.google.com" >> /system/etc/hosts
    echo "127.0.0.1 doubleclick.net" >> /system/etc/hosts
    echo "127.0.0.1 googleadservices.com" >> /system/etc/hosts
    echo "127.0.0.1 adsense.google.com" >> /system/etc/hosts
    echo "127.0.0.1 adwords.google.com" >> /system/etc/hosts
    echo "127.0.0.1 google-analytics.com" >> /system/etc/hosts
    echo "127.0.0.1 googletagmanager.com" >> /system/etc/hosts
    echo "127.0.0.1 googlesyndication.com" >> /system/etc/hosts
    echo "127.0.0.1 googleads.g.doubleclick.net" >> /system/etc/hosts
    echo "127.0.0.1 pagead2.googlesyndication.com" >> /system/etc/hosts
    echo "127.0.0.1 stats.g.doubleclick.net" >> /system/etc/hosts
    echo "127.0.0.1 www.google-analytics.com" >> /system/etc/hosts
    echo "127.0.0.1 ssl.google-analytics.com" >> /system/etc/hosts
    echo "127.0.0.1 analytics.twitter.com" >> /system/etc/hosts
    echo "127.0.0.1 ads.twitter.com" >> /system/etc/hosts
    echo "127.0.0.1 t.co" >> /system/etc/hosts
    echo "127.0.0.1 api.twitter.com" >> /system/etc/hosts
    echo "127.0.0.1 platform.twitter.com" >> /system/etc/hosts
    echo "127.0.0.1 syndication.twitter.com" >> /system/etc/hosts
    echo "127.0.0.1 connect.facebook.net" >> /system/etc/hosts
    echo "127.0.0.1 facebook.com" >> /system/etc/hosts
    echo "127.0.0.1 www.facebook.com" >> /system/etc/hosts
    echo "127.0.0.1 fbcdn.net" >> /system/etc/hosts
    echo "127.0.0.1 www.fbcdn.net" >> /system/etc/hosts
    echo "127.0.0.1 static.xx.fbcdn.net" >> /system/etc/hosts
    echo "127.0.0.1 scontent.xx.fbcdn.net" >> /system/etc/hosts
    echo "127.0.0.1 graph.facebook.com" >> /system/etc/hosts
    echo "127.0.0.1 api.facebook.com" >> /system/etc/hosts
    echo "127.0.0.1 login.facebook.com" >> /system/etc/hosts
    echo "127.0.0.1 www.login.facebook.com" >> /system/etc/hosts
    echo "127.0.0.1 m.facebook.com" >> /system/etc/hosts
    echo "127.0.0.1 www.m.facebook.com" >> /system/etc/hosts
    echo "127.0.0.1 l.facebook.com" >> /system/etc/hosts
    echo "127.0.0.1 edge-mqtt.facebook.com" >> /system/etc/hosts
    echo "127.0.0.1 star.c10r.facebook.com" >> /system/etc/hosts
    echo "127.0.0.1 www.instagram.com" >> /system/etc/hosts
    echo "127.0.0.1 instagram.com" >> /system/etc/hosts
    echo "127.0.0.1 api.instagram.com" >> /system/etc/hosts
    echo "127.0.0.1 i.instagram.com" >> /system/etc/hosts
    echo "127.0.0.1 scontent.cdninstagram.com" >> /system/etc/hosts
    echo "127.0.0.1 static.cdninstagram.com" >> /system/etc/hosts
    echo "127.0.0.1 graph.instagram.com" >> /system/etc/hosts
    echo "127.0.0.1 www.snapchat.com" >> /system/etc/hosts
    echo "127.0.0.1 snapchat.com" >> /system/etc/hosts
    echo "127.0.0.1 api.snapchat.com" >> /system/etc/hosts
    echo "127.0.0.1 stories.snapchat.com" >> /system/etc/hosts
    echo "127.0.0.1 ads.snapchat.com" >> /system/etc/hosts
    echo "127.0.0.1 analytics.snapchat.com" >> /system/etc/hosts
    echo "127.0.0.1 www.linkedin.com" >> /system/etc/hosts
    echo "127.0.0.1 linkedin.com" >> /system/etc/hosts
    echo "127.0.0.1 api.linkedin.com" >> /system/etc/hosts
    echo "127.0.0.1 analytics.linkedin.com" >> /system/etc/hosts
    echo "127.0.0.1 ads.linkedin.com" >> /system/etc/hosts
    echo "127.0.0.1 www.pinterest.com" >> /system/etc/hosts
    echo "127.0.0.1 pinterest.com" >> /system/etc/hosts
    echo "127.0.0.1 api.pinterest.com" >> /system/etc/hosts
    echo "127.0.0.1 analytics.pinterest.com" >> /system/etc/hosts
    echo "127.0.0.1 ads.pinterest.com" >> /system/etc/hosts
    echo "127.0.0.1 www.reddit.com" >> /system/etc/hosts
    echo "127.0.0.1 reddit.com" >> /system/etc/hosts
    echo "127.0.0.1 api.reddit.com" >> /system/etc/hosts
    echo "127.0.0.1 analytics.reddit.com" >> /system/etc/hosts
    echo "127.0.0.1 ads.reddit.com" >> /system/etc/hosts
    echo "127.0.0.1 www.tiktok.com" >> /system/etc/hosts
    echo "127.0.0.1 tiktok.com" >> /system/etc/hosts
    echo "127.0.0.1 api.tiktok.com" >> /system/etc/hosts
    echo "127.0.0.1 analytics.tiktok.com" >> /system/etc/hosts
    echo "127.0.0.1 ads.tiktok.com" >> /system/etc/hosts
    echo "127.0.0.1 www.twitch.tv" >> /system/etc/hosts
    echo "127.0.0.1 twitch.tv" >> /system/etc/hosts
    echo "127.0.0.1 api.twitch.tv" >> /system/etc/hosts
    echo "127.0.0.1 analytics.twitch.tv" >> /system/etc/hosts
    echo "127.0.0.1 ads.twitch.tv" >> /system/etc/hosts
    echo "127.0.0.1 www.youtube.com" >> /system/etc/hosts
    echo "127.0.0.1 youtube.com" >> /system/etc/hosts
    echo "127.0.0.1 api.youtube.com" >> /system/etc/hosts
    echo "127.0.0.1 analytics.youtube.com" >> /system/etc/hosts
    echo "127.0.0.1 ads.youtube.com" >> /system/etc/hosts
fi

echo "Privacy protections applied successfully!"
