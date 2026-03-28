#!/system/bin/sh

# Magisk 模块创建框架脚本
# 用于快速创建 Magisk 模块的模板

FRAMEWORK_DIR="/data/adb/modules/magisk-tools/development-tools/framework"
TEMPLATE_DIR="$FRAMEWORK_DIR/templates"

# 确保目录存在
mkdir -p "$TEMPLATE_DIR"

# 显示帮助信息
show_help() {
    echo "Magisk 模块创建工具"
    echo "用法: $0 [选项] <模块名称>"
    echo ""
    echo "选项:"
    echo "  -h, --help     显示帮助信息"
    echo "  -t, --template <模板名称>  使用指定模板"
    echo "  -o, --output <目录>  指定输出目录"
    echo ""
    echo "模板:"
    echo "  basic     - 基础模块模板"
    echo "  system    - 系统修改模块模板"
    echo "  zygisk    - Zygisk 模块模板"
    echo "  config    - 配置型模块模板"
    echo ""
    echo "示例:"
    echo "  $0 -t basic MyModule"
    echo "  $0 -t zygisk MyZygiskModule -o /sdcard/modules"
}

# 创建基础模块模板
create_basic_template() {
    local module_name=$1
    local output_dir=$2
    local module_id=$(echo "$module_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
    
    echo "创建基础模块模板: $module_name"
    
    # 创建模块目录结构
    mkdir -p "$output_dir/$module_id/{system,common}"
    
    # 创建 module.prop 文件
    cat > "$output_dir/$module_id/module.prop" << EOF
id=$module_id
name=$module_name
version=1.0.0
versionCode=1
author=Your Name
description=A basic Magisk module
EOF
    
    # 创建 post-fs-data.sh 文件
    cat > "$output_dir/$module_id/post-fs-data.sh" << EOF
#!/system/bin/sh
# This script will be executed in post-fs-data mode

# Set permissions
set_perm_recursive \$MODPATH/system 0 0 0755 0644
EOF
    chmod +x "$output_dir/$module_id/post-fs-data.sh"
    
    # 创建 service.sh 文件
    cat > "$output_dir/$module_id/service.sh" << EOF
#!/system/bin/sh
# This script will be executed in late_start service mode
EOF
    chmod +x "$output_dir/$module_id/service.sh"
    
    # 创建 uninstall.sh 文件
    cat > "$output_dir/$module_id/uninstall.sh" << EOF
#!/system/bin/sh
# This script will be executed when the module is uninstalled

# Remove module files
rm -rf \$MODPATH
EOF
    chmod +x "$output_dir/$module_id/uninstall.sh"
    
    echo "基础模块模板创建完成: $output_dir/$module_id"
}

# 创建系统修改模块模板
create_system_template() {
    local module_name=$1
    local output_dir=$2
    local module_id=$(echo "$module_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
    
    echo "创建系统修改模块模板: $module_name"
    
    # 创建模块目录结构
    mkdir -p "$output_dir/$module_id/{system/{bin,xbin,lib,lib64},common}"
    
    # 创建 module.prop 文件
    cat > "$output_dir/$module_id/module.prop" << EOF
id=$module_id
name=$module_name
version=1.0.0
versionCode=1
author=Your Name
description=A system modification Magisk module
EOF
    
    # 创建 post-fs-data.sh 文件
    cat > "$output_dir/$module_id/post-fs-data.sh" << EOF
#!/system/bin/sh
# This script will be executed in post-fs-data mode

# Set permissions
set_perm_recursive \$MODPATH/system 0 0 0755 0644
set_perm \$MODPATH/system/bin/mytool 0 0 0755
set_perm \$MODPATH/system/xbin/mytool 0 0 0755
EOF
    chmod +x "$output_dir/$module_id/post-fs-data.sh"
    
    # 创建 service.sh 文件
    cat > "$output_dir/$module_id/service.sh" << EOF
#!/system/bin/sh
# This script will be executed in late_start service mode
EOF
    chmod +x "$output_dir/$module_id/service.sh"
    
    # 创建 uninstall.sh 文件
    cat > "$output_dir/$module_id/uninstall.sh" << EOF
#!/system/bin/sh
# This script will be executed when the module is uninstalled

# Remove module files
rm -rf \$MODPATH
EOF
    chmod +x "$output_dir/$module_id/uninstall.sh"
    
    # 创建示例工具
    cat > "$output_dir/$module_id/system/bin/mytool" << EOF
#!/system/bin/sh
echo "Hello from $module_name!"
EOF
    chmod +x "$output_dir/$module_id/system/bin/mytool"
    
    echo "系统修改模块模板创建完成: $output_dir/$module_id"
}

# 创建 Zygisk 模块模板
create_zygisk_template() {
    local module_name=$1
    local output_dir=$2
    local module_id=$(echo "$module_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
    
    echo "创建 Zygisk 模块模板: $module_name"
    
    # 创建模块目录结构
    mkdir -p "$output_dir/$module_id/{zygisk,common}"
    
    # 创建 module.prop 文件
    cat > "$output_dir/$module_id/module.prop" << EOF
id=$module_id
name=$module_name
version=1.0.0
versionCode=1
author=Your Name
description=A Zygisk module
EOF
    
    # 创建 post-fs-data.sh 文件
    cat > "$output_dir/$module_id/post-fs-data.sh" << EOF
#!/system/bin/sh
# This script will be executed in post-fs-data mode

# Set permissions
set_perm_recursive \$MODPATH/zygisk 0 0 0755 0644
EOF
    chmod +x "$output_dir/$module_id/post-fs-data.sh"
    
    # 创建 service.sh 文件
    cat > "$output_dir/$module_id/service.sh" << EOF
#!/system/bin/sh
# This script will be executed in late_start service mode
EOF
    chmod +x "$output_dir/$module_id/service.sh"
    
    # 创建 uninstall.sh 文件
    cat > "$output_dir/$module_id/uninstall.sh" << EOF
#!/system/bin/sh
# This script will be executed when the module is uninstalled

# Remove module files
rm -rf \$MODPATH
EOF
    chmod +x "$output_dir/$module_id/uninstall.sh"
    
    # 创建 Zygisk 模块示例代码
    cat > "$output_dir/$module_id/zygisk/README.md" << EOF
# Zygisk 模块开发指南

## 编译步骤
1. 安装 Android NDK
2. 设置 NDK 路径
3. 运行编译脚本

## 模块结构
- zygisk/arm64-v8a/libmyzygiskmodule.so - 64位模块
- zygisk/armeabi-v7a/libmyzygiskmodule.so - 32位模块
EOF
    
    echo "Zygisk 模块模板创建完成: $output_dir/$module_id"
}

# 创建配置型模块模板
create_config_template() {
    local module_name=$1
    local output_dir=$2
    local module_id=$(echo "$module_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
    
    echo "创建配置型模块模板: $module_name"
    
    # 创建模块目录结构
    mkdir -p "$output_dir/$module_id/{config,common}"
    
    # 创建 module.prop 文件
    cat > "$output_dir/$module_id/module.prop" << EOF
id=$module_id
name=$module_name
version=1.0.0
versionCode=1
author=Your Name
description=A configuration-based Magisk module
EOF
    
    # 创建 post-fs-data.sh 文件
    cat > "$output_dir/$module_id/post-fs-data.sh" << EOF
#!/system/bin/sh
# This script will be executed in post-fs-data mode

# Load configuration
. \$MODPATH/config/config.sh

# Apply configuration
echo "Applying configuration for $module_name"
EOF
    chmod +x "$output_dir/$module_id/post-fs-data.sh"
    
    # 创建 service.sh 文件
    cat > "$output_dir/$module_id/service.sh" << EOF
#!/system/bin/sh
# This script will be executed in late_start service mode
EOF
    chmod +x "$output_dir/$module_id/service.sh"
    
    # 创建 uninstall.sh 文件
    cat > "$output_dir/$module_id/uninstall.sh" << EOF
#!/system/bin/sh
# This script will be executed when the module is uninstalled

# Remove module files
rm -rf \$MODPATH
EOF
    chmod +x "$output_dir/$module_id/uninstall.sh"
    
    # 创建配置文件
    cat > "$output_dir/$module_id/config/config.sh" << EOF
#!/system/bin/sh
# Configuration file for $module_name

# Enable/disable features
FEATURE1_ENABLED=true
FEATURE2_ENABLED=false

# Feature settings
FEATURE1_SETTING="value"
FEATURE2_SETTING="value"
EOF
    
    echo "配置型模块模板创建完成: $output_dir/$module_id"
}

# 主函数
main() {
    local template="basic"
    local output_dir="."
    local module_name=""
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                return 0
                ;;
            -t|--template)
                template="$2"
                shift 2
                ;;
            -o|--output)
                output_dir="$2"
                shift 2
                ;;
            *)
                module_name="$1"
                shift
                ;;
        esac
    done
    
    if [ -z "$module_name" ]; then
        echo "错误: 请指定模块名称"
        show_help
        return 1
    fi
    
    # 确保输出目录存在
    mkdir -p "$output_dir"
    
    # 根据模板类型创建模块
    case "$template" in
        basic)
            create_basic_template "$module_name" "$output_dir"
            ;;
        system)
            create_system_template "$module_name" "$output_dir"
            ;;
        zygisk)
            create_zygisk_template "$module_name" "$output_dir"
            ;;
        config)
            create_config_template "$module_name" "$output_dir"
            ;;
        *)
            echo "错误: 未知模板类型: $template"
            show_help
            return 1
            ;;
    esac
    
    echo ""
    echo "模块创建成功！"
    echo "下一步:"
    echo "1. 编辑模块文件以实现具体功能"
    echo "2. 将模块目录压缩为 zip 文件"
    echo "3. 通过 Magisk 管理器安装模块"
}

# 执行主函数
main "$@"
