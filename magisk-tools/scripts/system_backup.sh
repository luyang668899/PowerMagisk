#!/system/bin/sh
# system_backup.sh - Backup system files and data

set -e

BACKUP_DIR="/sdcard/MagiskBackup"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_PATH="$BACKUP_DIR/$TIMESTAMP"

echo "Starting system backup..."

# Create backup directory
mkdir -p "$BACKUP_PATH"

# Backup system files
echo "Backing up system files..."
tar -czf "$BACKUP_PATH/system_backup.tar.gz" /system/etc /system/build.prop 2>/dev/null

# Backup Magisk modules
echo "Backing up Magisk modules..."
if [ -d "/data/adb/modules" ]; then
    tar -czf "$BACKUP_PATH/modules_backup.tar.gz" /data/adb/modules 2>/dev/null
fi

# Backup system settings
echo "Backing up system settings..."
if [ -d "/data/system/users/0" ]; then
    tar -czf "$BACKUP_PATH/settings_backup.tar.gz" /data/system/users/0/settings_* 2>/dev/null
fi

# Backup app data (optional)
echo "Backing up app data..."
if [ -d "/data/data" ]; then
    # Only backup selected app data to save space
    mkdir -p "$BACKUP_PATH/app_data"
    for app in com.android.settings com.google.android.gms; do
        if [ -d "/data/data/$app" ]; then
            tar -czf "$BACKUP_PATH/app_data/${app}.tar.gz" "/data/data/$app" 2>/dev/null
        fi
    done
fi

echo "System backup completed successfully!"
echo "Backup location: $BACKUP_PATH"
echo "Total backup size: $(du -sh "$BACKUP_PATH" | cut -f1)"
