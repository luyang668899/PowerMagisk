#!/system/bin/sh

# 云服务模块脚本
# 用于实现模块同步、远程管理和模块更新服务

CLOUD_DIR="/data/adb/modules/magisk-cloud-services/cloud"
SYNC_DIR="$CLOUD_DIR/sync"
REMOTE_DIR="$CLOUD_DIR/remote"
UPDATE_DIR="$CLOUD_DIR/update"

# 创建必要的目录
mkdir -p "$SYNC_DIR"
mkdir -p "$REMOTE_DIR"
mkdir -p "$UPDATE_DIR"

# 初始化云服务配置
if [ ! -f "$CLOUD_DIR/config.json" ]; then
    cat > "$CLOUD_DIR/config.json" << EOF
{
    "sync": {
        "enabled": false,
        "interval": 3600,
        "cloud_storage": "gdrive",
        "sync_modules": true,
        "sync_configs": true,
        "sync_themes": true
    },
    "remote": {
        "enabled": false,
        "port": 8080,
        "auth": {
            "enabled": true,
            "username": "magisk",
            "password": ""
        }
    },
    "update": {
        "enabled": true,
        "interval": 86400,
        "auto_update": false,
        "notification": true
    }
}
EOF
fi

# 启动云服务
echo "Starting Magisk Cloud Services" >> /data/adb/modules/magisk-cloud-services/cloud.log

# 启动同步服务
if grep -A 5 "sync" "$CLOUD_DIR/config.json" | grep -q "\"enabled\": true"; then
    echo "Starting module sync service" >> /data/adb/modules/magisk-cloud-services/cloud.log
    /data/adb/modules/magisk-cloud-services/sync/sync_service.sh start
fi

# 启动远程管理服务
if grep -A 5 "remote" "$CLOUD_DIR/config.json" | grep -q "\"enabled\": true"; then
    echo "Starting remote management service" >> /data/adb/modules/magisk-cloud-services/cloud.log
    /data/adb/modules/magisk-cloud-services/remote/remote_service.sh start
fi

# 启动更新服务
if grep -A 5 "update" "$CLOUD_DIR/config.json" | grep -q "\"enabled\": true"; then
    echo "Starting module update service" >> /data/adb/modules/magisk-cloud-services/cloud.log
    /data/adb/modules/magisk-cloud-services/update/update_service.sh start
fi

# 设置权限
set_perm_recursive "$CLOUD_DIR" 0 0 0755 0644

echo "Magisk Cloud Services started" >> /data/adb/modules/magisk-cloud-services/cloud.log
