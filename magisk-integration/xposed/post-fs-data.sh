#!/system/bin/sh

# Xposed 模块兼容模块脚本
# 用于与 Xposed 模块兼容

XPOSED_DIR="/data/adb/modules/magisk-xposed-compatibility/xposed"
XPOSED_MODULES_DIR="/data/adb/modules"

# 创建必要的目录
mkdir -p "$XPOSED_DIR"

# 检查是否安装了 Xposed 框架
if [ -d "/data/adb/modules/lsposed" ] || [ -d "/data/adb/modules/edxp" ]; then
    echo "Xposed framework detected, setting up compatibility layer" >> /data/adb/modules/magisk-xposed-compatibility/xposed.log
else
    echo "No Xposed framework detected, compatibility layer disabled" >> /data/adb/modules/magisk-xposed-compatibility/xposed.log
    exit 0
fi

# 为 Xposed 模块创建兼容层
for module_dir in "$XPOSED_MODULES_DIR"/*; do
    if [ -d "$module_dir" ] && [ -f "$module_dir/module.prop" ]; then
        # 检查是否为 Xposed 模块
        if grep -q "xposed" "$module_dir/module.prop" || grep -q "Xposed" "$module_dir/module.prop"; then
            echo "Found Xposed module: $(basename "$module_dir")" >> /data/adb/modules/magisk-xposed-compatibility/xposed.log
            
            # 创建兼容配置
            mkdir -p "$XPOSED_DIR/$(basename "$module_dir")"
            cp "$module_dir/module.prop" "$XPOSED_DIR/$(basename "$module_dir")/"
        fi
    fi
done

# 设置权限
set_perm_recursive "$XPOSED_DIR" 0 0 0755 0644

echo "Xposed compatibility layer setup completed" >> /data/adb/modules/magisk-xposed-compatibility/xposed.log
