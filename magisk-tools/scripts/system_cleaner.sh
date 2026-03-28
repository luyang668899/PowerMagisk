#!/system/bin/sh
# system_cleaner.sh - Clean system cache and temporary files

set -e

echo "Starting system cleanup..."

# Clean app cache
echo "Cleaning app cache..."
find /data/data -name "cache" -type d | xargs rm -rf 2>/dev/null

# Clean system cache
echo "Cleaning system cache..."
rm -rf /cache/* 2>/dev/null

# Clean Dalvik cache
echo "Cleaning Dalvik cache..."
rm -rf /data/dalvik-cache/* 2>/dev/null
rm -rf /data/resource-cache/* 2>/dev/null

# Clean temporary files
echo "Cleaning temporary files..."
rm -rf /data/local/tmp/* 2>/dev/null

# Clean log files
echo "Cleaning log files..."
find /data -name "*.log" -type f | xargs rm -f 2>/dev/null

# Clean crash logs
echo "Cleaning crash logs..."
rm -rf /data/system/dropbox/* 2>/dev/null

echo "System cleanup completed successfully!"
echo "Reboot recommended for changes to take effect."
