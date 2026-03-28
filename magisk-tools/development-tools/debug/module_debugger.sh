#!/system/bin/sh

# Magisk 模块调试工具脚本
# 用于调试 Magisk 模块的运行状态和问题

DEBUG_LOG="/data/adb/backups/module_debug.log"

# 确保日志目录存在
mkdir -p "$(dirname "$DEBUG_LOG")"

# 日志函数
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$DEBUG_LOG"
    echo "$1"
}

# 显示模块信息
show_module_info() {
    local module_id=$1
    local module_dir="/data/adb/modules/$module_id"
    
    log "模块信息: $module_id"
    
    if [ -d "$module_dir" ]; then
        log "模块目录: $module_dir"
        
        # 显示 module.prop 信息
        if [ -f "$module_dir/module.prop" ]; then
            log "模块属性:"
            cat "$module_dir/module.prop" | while read line; do
                log "  $line"
            done
        else
            log "错误: 模块属性文件不存在"
        fi
        
        # 显示模块状态
        if [ -f "$module_dir/disable" ]; then
            log "模块状态: 已禁用"
        else
            log "模块状态: 已启用"
        fi
        
        # 显示模块文件
        log "模块文件:"
        find "$module_dir" -type f | sort | while read file; do
            local rel_path=$(echo "$file" | sed "s|$module_dir/||")
            log "  $rel_path"
        done
    else
        log "错误: 模块目录不存在"
    fi
}

# 检查模块冲突
check_module_conflicts() {
    log "检查模块冲突..."
    
    local modules_dir="/data/adb/modules"
    local conflicts_found=false
    
    # 检查是否有重复的模块 ID
    local module_ids=()
    find "$modules_dir" -name "module.prop" -type f | while read prop_file; do
        local module_id=$(grep "^id=" "$prop_file" | cut -d'=' -f2)
        if [[ "${module_ids[@]}" =~ "$module_id" ]]; then
            log "冲突: 发现重复的模块 ID: $module_id"
            conflicts_found=true
        else
            module_ids+=($module_id)
        fi
    done
    
    # 检查系统文件覆盖冲突
    log "检查系统文件覆盖冲突..."
    local system_files=()
    find "$modules_dir" -path "*/system/*" -type f | while read file; do
        local rel_path=$(echo "$file" | sed "s|$modules_dir/[^/]*||")
        if [[ "${system_files[@]}" =~ "$rel_path" ]]; then
            log "冲突: 多个模块覆盖同一系统文件: $rel_path"
            conflicts_found=true
        else
            system_files+=($rel_path)
        fi
    done
    
    if [ "$conflicts_found" = false ]; then
        log "未发现模块冲突"
    fi
}

# 调试模块脚本
debug_module_script() {
    local module_id=$1
    local script_name=$2
    local module_dir="/data/adb/modules/$module_id"
    local script_path="$module_dir/$script_name"
    
    log "调试模块脚本: $script_name"
    
    if [ -f "$script_path" ]; then
        log "脚本路径: $script_path"
        log "脚本内容:"
        cat "$script_path"
        
        log "执行脚本（带调试信息）:"
        bash -x "$script_path"
    else
        log "错误: 脚本文件不存在: $script_path"
    fi
}

# 检查模块权限
check_module_permissions() {
    local module_id=$1
    local module_dir="/data/adb/modules/$module_id"
    
    log "检查模块权限: $module_id"
    
    if [ -d "$module_dir" ]; then
        log "模块目录权限:"
        ls -la "$module_dir"
        
        log "系统目录权限:"
        if [ -d "$module_dir/system" ]; then
            find "$module_dir/system" -type f | while read file; do
                local perm=$(stat -c "%a" "$file")
                local owner=$(stat -c "%U:%G" "$file")
                log "  $file: $perm ($owner)"
            done
        else
            log "  无系统目录"
        fi
    else
        log "错误: 模块目录不存在"
    fi
}

# 查看模块日志
view_module_logs() {
    local module_id=$1
    
    log "查看模块日志: $module_id"
    
    # 查看 Magisk 日志中的模块相关信息
    log "Magisk 日志中的模块信息:"
    logcat -d | grep "$module_id"
    
    # 查看模块自身的日志文件
    local module_dir="/data/adb/modules/$module_id"
    if [ -d "$module_dir" ]; then
        find "$module_dir" -name "*.log" -type f | while read log_file; do
            log "模块日志文件: $log_file"
            cat "$log_file"
        done
    fi
}

# 测试模块功能
test_module_functionality() {
    local module_id=$1
    
    log "测试模块功能: $module_id"
    
    # 重新加载模块
    log "重新加载模块..."
    touch "/data/adb/modules/$module_id/skip_mount"
    sleep 1
    rm "/data/adb/modules/$module_id/skip_mount"
    
    # 检查模块是否正确加载
    log "检查模块加载状态..."
    if [ -f "/data/adb/modules/$module_id/update" ]; then
        log "模块标记为需要更新"
    else
        log "模块加载正常"
    fi
    
    # 测试模块脚本
    log "测试模块脚本..."
    local module_dir="/data/adb/modules/$module_id"
    if [ -f "$module_dir/post-fs-data.sh" ]; then
        log "执行 post-fs-data.sh 脚本..."
        bash "$module_dir/post-fs-data.sh"
    fi
    
    if [ -f "$module_dir/service.sh" ]; then
        log "执行 service.sh 脚本..."
        bash "$module_dir/service.sh"
    fi
}

# 主函数
main() {
    case "$1" in
        "info")
            if [ -n "$2" ]; then
                show_module_info "$2"
            else
                log "错误: 请指定模块 ID"
                show_help
            fi
            ;;
        "conflicts")
            check_module_conflicts
            ;;
        "debug")
            if [ -n "$2" ] && [ -n "$3" ]; then
                debug_module_script "$2" "$3"
            else
                log "错误: 请指定模块 ID 和脚本名称"
                show_help
            fi
            ;;
        "permissions")
            if [ -n "$2" ]; then
                check_module_permissions "$2"
            else
                log "错误: 请指定模块 ID"
                show_help
            fi
            ;;
        "logs")
            if [ -n "$2" ]; then
                view_module_logs "$2"
            else
                log "错误: 请指定模块 ID"
                show_help
            fi
            ;;
        "test")
            if [ -n "$2" ]; then
                test_module_functionality "$2"
            else
                log "错误: 请指定模块 ID"
                show_help
            fi
            ;;
        *)
            show_help
            ;;
    esac
}

# 显示帮助信息
show_help() {
    echo "Magisk 模块调试工具"
    echo "用法: $0 [命令] [参数]"
    echo ""
    echo "命令:"
    echo "  info <模块 ID>       - 显示模块信息"
    echo "  conflicts          - 检查模块冲突"
    echo "  debug <模块 ID> <脚本> - 调试模块脚本"
    echo "  permissions <模块 ID> - 检查模块权限"
    echo "  logs <模块 ID>      - 查看模块日志"
    echo "  test <模块 ID>      - 测试模块功能"
    echo ""
    echo "示例:"
    echo "  $0 info mymodule"
    echo "  $0 debug mymodule post-fs-data.sh"
    echo "  $0 test mymodule"
}

# 执行主函数
main "$@"
