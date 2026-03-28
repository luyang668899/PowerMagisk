#!/system/bin/sh

# 性能分析工具脚本
# 系统性能分析和瓶颈检测

LOG_FILE="/data/adb/backups/performance.log"
CONFIG_FILE="/data/adb/modules/magisk-tools/system-maintenance/config/performance.conf"

# 确保日志目录存在
mkdir -p "$(dirname "$LOG_FILE")"

# 确保配置文件存在
if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" << EOF
# 性能分析配置文件

# 分析时长（秒）
analysis_duration=60

# 采样间隔（秒）
sample_interval=1

# 启用详细分析
detailed_analysis=true

# 分析项目
enable_cpu_analysis=true
enable_memory_analysis=true
enable_disk_analysis=true
enable_network_analysis=true
enable_process_analysis=true
EOF
fi

# 加载配置
. "$CONFIG_FILE"

# 日志函数
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    echo "$1"
}

# CPU 分析函数
analyze_cpu() {
    log "开始 CPU 性能分析..."
    
    if [ "$enable_cpu_analysis" = true ]; then
        log "CPU 使用率统计:"
        top -n $((analysis_duration / sample_interval)) -d $sample_interval | grep -E "(CPU|User|System|Idle)" >> "$LOG_FILE"
        
        log "CPU 核心使用情况:"
        cat /proc/stat | grep cpu >> "$LOG_FILE"
        
        log "CPU 频率信息:"
        cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq | while read freq; do
            echo "CPU 频率: $((freq / 1000)) MHz" >> "$LOG_FILE"
        done
        
        log "CPU 分析完成"
    else
        log "跳过 CPU 分析（已禁用）"
    fi
}

# 内存分析函数
analyze_memory() {
    log "开始内存性能分析..."
    
    if [ "$enable_memory_analysis" = true ]; then
        log "内存使用情况:"
        free -h >> "$LOG_FILE"
        
        log "内存详细信息:"
        cat /proc/meminfo >> "$LOG_FILE"
        
        log "交换空间使用情况:"
        if [ -f "/proc/swaps" ]; then
            cat /proc/swaps >> "$LOG_FILE"
        else
            log "交换空间未启用"
        fi
        
        log "内存分析完成"
    else
        log "跳过内存分析（已禁用）"
    fi
}

# 磁盘分析函数
analyze_disk() {
    log "开始磁盘性能分析..."
    
    if [ "$enable_disk_analysis" = true ]; then
        log "磁盘使用情况:"
        df -h >> "$LOG_FILE"
        
        log "磁盘 I/O 统计:"
        iostat -d -x $sample_interval $((analysis_duration / sample_interval)) >> "$LOG_FILE"
        
        log "磁盘挂载信息:"
        mount | grep -E "(ext4|f2fs|sdcardfs)" >> "$LOG_FILE"
        
        log "磁盘分析完成"
    else
        log "跳过磁盘分析（已禁用）"
    fi
}

# 网络分析函数
analyze_network() {
    log "开始网络性能分析..."
    
    if [ "$enable_network_analysis" = true ]; then
        log "网络接口信息:"
        ifconfig >> "$LOG_FILE"
        
        log "网络连接统计:"
        netstat -tuln >> "$LOG_FILE"
        
        log "网络路由表:"
        route -n >> "$LOG_FILE"
        
        log "DNS 配置:"
        cat /system/etc/resolv.conf >> "$LOG_FILE"
        
        log "网络分析完成"
    else
        log "跳过网络分析（已禁用）"
    fi
}

# 进程分析函数
analyze_process() {
    log "开始进程性能分析..."
    
    if [ "$enable_process_analysis" = true ]; then
        log "占用 CPU 最多的进程:"
        top -n 1 -o %CPU | head -20 >> "$LOG_FILE"
        
        log "占用内存最多的进程:"
        top -n 1 -o %MEM | head -20 >> "$LOG_FILE"
        
        log "运行中的进程数:"
        ps | wc -l >> "$LOG_FILE"
        
        log "进程状态统计:"
        ps aux | awk '{print $8}' | sort | uniq -c >> "$LOG_FILE"
        
        log "进程分析完成"
    else
        log "跳过进程分析（已禁用）"
    fi
}

# 性能瓶颈检测函数
detect_bottlenecks() {
    log "开始性能瓶颈检测..."
    
    # 检测 CPU 瓶颈
    local cpu_idle=$(top -n 1 | grep "CPU" | awk '{print $8}' | sed 's/%//')
    if [ "$cpu_idle" -lt 10 ]; then
        log "警告: CPU 使用率过高，可能存在瓶颈"
    fi
    
    # 检测内存瓶颈
    local mem_used=$(free | grep "Mem:" | awk '{print $3}')
    local mem_total=$(free | grep "Mem:" | awk '{print $2}')
    local mem_usage=$((mem_used * 100 / mem_total))
    if [ "$mem_usage" -gt 90 ]; then
        log "警告: 内存使用率过高，可能存在瓶颈"
    fi
    
    # 检测磁盘瓶颈
    local disk_usage=$(df -h /data | grep /data | awk '{print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt 90 ]; then
        log "警告: 磁盘使用率过高，可能存在瓶颈"
    fi
    
    # 检测进程瓶颈
    local process_count=$(ps | wc -l)
    if [ "$process_count" -gt 300 ]; then
        log "警告: 进程数量过多，可能存在瓶颈"
    fi
    
    log "性能瓶颈检测完成"
}

# 生成性能报告函数
generate_report() {
    local report_file="/data/adb/backups/performance_report_$(date '+%Y%m%d_%H%M%S').log"
    
    log "生成性能分析报告: $report_file"
    
    # 复制日志到报告文件
    cp "$LOG_FILE" "$report_file"
    
    # 添加报告摘要
    echo "\n===== 性能分析报告摘要 =====" >> "$report_file"
    echo "分析时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$report_file"
    echo "分析时长: $analysis_duration 秒" >> "$report_file"
    
    # 检测瓶颈
    detect_bottlenecks >> "$report_file"
    
    echo "\n===== 建议优化措施 =====" >> "$report_file"
    
    # CPU 优化建议
    if [ "$enable_cpu_analysis" = true ]; then
        echo "- 检查并关闭不必要的后台进程"
        echo "- 考虑使用性能模式或调整 CPU 调度策略"
    fi
    
    # 内存优化建议
    if [ "$enable_memory_analysis" = true ]; then
        echo "- 清理应用缓存和系统垃圾"
        echo "- 考虑增加交换空间"
    fi
    
    # 磁盘优化建议
    if [ "$enable_disk_analysis" = true ]; then
        echo "- 清理不必要的文件"
        echo "- 考虑使用更快的存储介质"
    fi
    
    # 网络优化建议
    if [ "$enable_network_analysis" = true ]; then
        echo "- 检查网络连接和 DNS 设置"
        echo "- 考虑使用更快的网络连接"
    fi
    
    log "性能分析报告生成完成: $report_file"
}

# 主分析函数
main_analysis() {
    log "开始系统性能分析..."
    log "分析时长: $analysis_duration 秒"
    log "采样间隔: $sample_interval 秒"
    
    # 执行各项分析
    analyze_cpu
    analyze_memory
    analyze_disk
    analyze_network
    analyze_process
    
    # 检测瓶颈
    detect_bottlenecks
    
    # 生成报告
    generate_report
    
    log "系统性能分析完成！"
    log "详细报告已保存到: /data/adb/backups/"
}

# 实时监控函数
realtime_monitor() {
    log "开始实时性能监控..."
    log "按 Ctrl+C 停止监控"
    
    local end_time=$(( $(date +%s) + analysis_duration ))
    
    while [ $(date +%s) -lt $end_time ]; do
        clear
        echo "===== 实时性能监控 ====="
        echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "剩余时间: $((end_time - $(date +%s))) 秒"
        echo ""
        
        # 显示 CPU 使用情况
        if [ "$enable_cpu_analysis" = true ]; then
            echo "CPU 使用情况:"
            top -n 1 | grep "CPU"
            echo ""
        fi
        
        # 显示内存使用情况
        if [ "$enable_memory_analysis" = true ]; then
            echo "内存使用情况:"
            free -h
            echo ""
        fi
        
        # 显示磁盘使用情况
        if [ "$enable_disk_analysis" = true ]; then
            echo "磁盘使用情况:"
            df -h | grep -E "(Filesystem|/data|/system)"
            echo ""
        fi
        
        # 显示占用资源最多的进程
        if [ "$enable_process_analysis" = true ]; then
            echo "占用 CPU 最多的进程:"
            top -n 1 -o %CPU | head -10
            echo ""
            
            echo "占用内存最多的进程:"
            top -n 1 -o %MEM | head -10
            echo ""
        fi
        
        sleep $sample_interval
    done
    
    log "实时性能监控完成"
}

# 主函数
main() {
    case "$1" in
        "analyze")
            main_analysis
            ;;
        "monitor")
            realtime_monitor
            ;;
        "bottlenecks")
            detect_bottlenecks
            ;;
        *)
            log "用法: $0 [analyze|monitor|bottlenecks]"
            log "  analyze    - 执行完整性能分析"
            log "  monitor    - 实时性能监控"
            log "  bottlenecks - 检测性能瓶颈"
            ;;
    esac
}

# 执行主函数
main "$@"
