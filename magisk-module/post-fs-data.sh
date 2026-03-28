#!/system/bin/sh
# post-fs-data.sh - Apply custom font

# Create backup of original fonts if not already done
if [ ! -d "/data/magisk_backup/fonts" ]; then
    mkdir -p "/data/magisk_backup/fonts"
    cp -f /system/fonts/* "/data/magisk_backup/fonts/" 2>/dev/null
fi

echo "Applying custom fonts..."
