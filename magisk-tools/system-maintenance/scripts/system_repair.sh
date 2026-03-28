#!/system/bin/sh

# 系统修复工具脚本
# 自动检测和修复系统问题

LOG_FILE="/data/adb/backups/repair.log"
CONFIG_FILE="/data/adb/modules/magisk-tools/system-maintenance/config/repair.conf"

# 确保日志目录存在
mkdir -p "$(dirname "$LOG_FILE")"

# 确保配置文件存在
if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" << EOF
# 系统修复配置文件

# 启用自动修复
auto_repair=true

# 修复项目
enable_fsck=true
enable_permissions_fix=true
enable_dalvik_cache_clean=true
enable_app_cache_clean=true
enable_system_clean=true
enable_battery_stats_reset=false
enable_network_reset=false
EOF
fi

# 加载配置
. "$CONFIG_FILE"

# 日志函数
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    echo "$1"
}

# 检查文件系统函数
check_filesystem() {
    log "检查文件系统..."
    
    # 检查主要分区
    local partitions=("/system" "/data" "/vendor")
    
    for partition in "${partitions[@]}"; do
        log "检查分区: $partition"
        if [ "$enable_fsck" = true ]; then
            fsck -a "$partition" 2>&1 | grep -v "clean"
            if [ $? -eq 0 ]; then
                log "分区 $partition 需要修复，正在修复..."
                fsck -y "$partition"
                if [ $? -eq 0 ]; then
                    log "分区 $partition 修复成功"
                else
                    log "分区 $partition 修复失败"
                fi
            else
                log "分区 $partition 状态正常"
            fi
        else
            log "跳过文件系统检查（已禁用）"
        fi
    done
}

# 修复权限函数
fix_permissions() {
    log "修复系统权限..."
    
    if [ "$enable_permissions_fix" = true ]; then
        # 修复系统目录权限
        chmod -R 755 /system
        chmod -R 755 /vendor
        
        # 修复重要文件权限
        chmod 644 /system/build.prop
        chmod 644 /system/etc/hosts
        chmod 755 /system/bin/*
        chmod 755 /system/xbin/*
        
        log "系统权限修复完成"
    else
        log "跳过权限修复（已禁用）"
    fi
}

# 清理 Dalvik 缓存函数
clean_dalvik_cache() {
    log "清理 Dalvik 缓存..."
    
    if [ "$enable_dalvik_cache_clean" = true ]; then
        rm -rf /data/dalvik-cache/*
        rm -rf /cache/dalvik-cache/*
        log "Dalvik 缓存清理完成"
    else
        log "跳过 Dalvik 缓存清理（已禁用）"
    fi
}

# 清理应用缓存函数
clean_app_cache() {
    log "清理应用缓存..."
    
    if [ "$enable_app_cache_clean" = true ]; then
        find /data/data -name "cache" -type d | xargs rm -rf
        log "应用缓存清理完成"
    else
        log "跳过应用缓存清理（已禁用）"
    fi
}

# 清理系统垃圾函数
clean_system() {
    log "清理系统垃圾..."
    
    if [ "$enable_system_clean" = true ]; then
        # 清理临时文件
        rm -rf /data/tmp/*
        rm -rf /data/local/tmp/*
        
        # 清理日志文件
        rm -rf /data/log/*
        
        # 清理下载目录
        rm -rf /data/media/0/Download/*
        
        log "系统垃圾清理完成"
    else
        log "跳过系统清理（已禁用）"
    fi
}

# 重置电池统计函数
reset_battery_stats() {
    log "重置电池统计..."
    
    if [ "$enable_battery_stats_reset" = true ]; then
        rm -f /data/system/batterystats.bin
        log "电池统计重置完成"
    else
        log "跳过电池统计重置（已禁用）"
    fi
}

# 重置网络设置函数
reset_network() {
    log "重置网络设置..."
    
    if [ "$enable_network_reset" = true ]; then
        # 重置网络设置
        settings put global airplane_mode_on 1
        sleep 2
        settings put global airplane_mode_on 0
        
        # 清除 DNS 缓存
        ndc resolver flushdefaultif
        
        log "网络设置重置完成"
    else
        log "跳过网络设置重置（已禁用）"
    fi
}

# 检测系统问题函数
detect_problems() {
    log "检测系统问题..."
    
    # 检查存储空间
    local data_usage=$(df -h /data | grep /data | awk '{print $5}' | sed 's/%//')
    if [ "$data_usage" -gt 90 ]; then
        log "警告: /data 分区使用率过高 ($data_usage%)"
    fi
    
    # 检查系统文件完整性
    if [ -f "/system/build.prop" ]; then
        log "系统文件 build.prop 存在"
    else
        log "错误: 系统文件 build.prop 缺失"
    fi
    
    # 检查 Magisk 状态
    if [ -f "/data/adb/magisk/magisk" ]; then
        log "Magisk 安装正常"
    else
        log "警告: Magisk 可能未正确安装"
    fi
    
    # 检查启动脚本
    if [ -f "/data/adb/post-fs-data.d" ]; then
        log "启动脚本目录存在"
    else
        log "警告: 启动脚本目录缺失"
    fi
    
    log "系统问题检测完成"
}

# 主修复函数
main_repair() {
    log "开始系统修复..."
    
    # 检测系统问题
    detect_problems
    
    # 执行修复操作
    check_filesystem
    fix_permissions
    clean_dalvik_cache
    clean_app_cache
    clean_system
    reset_battery_stats
    reset_network
    
    log "系统修复完成！"
    log "建议重启设备以应用所有修复"
}

# 显示系统状态函数
display_status() {
    log "系统状态报告..."
    
    # 显示存储空间
    log "存储空间使用情况:"
    df -h | grep -E "(Filesystem|/system|/data|/vendor)"
    
    # 显示内存使用
    log "内存使用情况:"
    free -h
    
    # 显示 CPU 使用
    log "CPU 使用情况:"
    top -n 1 | grep -E "(CPU|User|System)"
    
    # 显示启动时间
    log "系统启动时间:"
    uptime
    
    log "系统状态报告完成"
}

# 主函数
main() {
    case "$1" in
        "repair")
            main_repair
            ;;
        "status")
            display_status
            ;;
        "detect")
            detect_problems
            ;;
        *)
            log "用法: $0 [repair|status|detect]"
            log "  repair   - 执行系统修复"
            log "  status   - 显示系统状态"
            log "  detect   - 检测系统问题"
            ;;
    esac
}

# 执行主函数
main "$@"
