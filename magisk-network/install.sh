#!/system/bin/sh
# install.sh - Magisk network module installation script

set -e

# Initialize variables
MODID="magisk_network"
MODPATH="/data/adb/modules/$MODID"

# Create module directory
mkdir -p "$MODPATH"

# Copy module files
cp -r "$MODPATH/system" "$MODPATH/" 2>/dev/null || true
cp "$MODPATH/module.prop" "$MODPATH/" 2>/dev/null || true
cp "$MODPATH/post-fs-data.sh" "$MODPATH/" 2>/dev/null || true
cp -r "$MODPATH/common" "$MODPATH/" 2>/dev/null || true
cp -r "$MODPATH/scripts" "$MODPATH/" 2>/dev/null || true

# Set permissions
chmod 755 "$MODPATH/post-fs-data.sh"
chmod 644 "$MODPATH/module.prop"

# Create skip mount file (optional)
touch "$MODPATH/skip_mount"

echo "Network optimization module installed successfully!"
echo "Reboot your device to apply the optimizations."
