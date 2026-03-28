#!/system/bin/sh

# Tasker 集成模块脚本
# 用于与 Tasker 等自动化工具集成

TASKER_DIR="/data/adb/modules/magisk-tasker-integration/tasker"
TASKER_PLUGIN_DIR="/data/data/net.dinglisch.android.taskerm/files/extensions"

# 创建必要的目录
mkdir -p "$TASKER_DIR"
mkdir -p "$TASKER_PLUGIN_DIR"

# 复制 Tasker 插件文件
cp -r "$MODPATH/tasker/*" "$TASKER_PLUGIN_DIR/"

# 设置权限
set_perm_recursive "$TASKER_PLUGIN_DIR" 1000 1000 0755 0644

# 注册 Tasker 插件
echo "Magisk Tasker Integration plugin registered" >> /data/adb/modules/magisk-tasker-integration/tasker.log
