#!/system/bin/sh

# 高级备份工具脚本
# 支持增量备份、加密备份和计划备份

BACKUP_DIR="/data/adb/backups"
CONFIG_FILE="/data/adb/modules/magisk-tools/system-maintenance/config/backup.conf"
LOG_FILE="/data/adb/backups/backup.log"

# 确保备份目录存在
mkdir -p "$BACKUP_DIR"

# 确保配置文件存在
if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" << EOF
# 备份配置文件

# 备份目录
backup_dir="$BACKUP_DIR"

# 加密密码（如果为空则不加密）
encryption_password=""

# 备份计划（cron 格式）
# 示例：每天凌晨 2 点备份
# backup_schedule="0 2 * * *"
backup_schedule=""

# 增量备份启用
incremental_backup=true

# 备份保留天数
backup_retention=7

# 要备份的目录
backup_dirs=("/data" "/system" "/vendor")

# 排除的目录
exclude_dirs=("/data/media" "/data/cache" "/data/tmp")
EOF
fi

# 加载配置
. "$CONFIG_FILE"

# 日志函数
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    echo "$1"
}

# 备份函数
do_backup() {
    local backup_name="backup_$(date '+%Y%m%d_%H%M%S')"
    local backup_path="$backup_dir/$backup_name"
    local exclude_args=""
    
    # 构建排除参数
    for dir in "${exclude_dirs[@]}"; do
        exclude_args+=" --exclude=$dir"
    done
    
    log "开始备份..."
    log "备份名称: $backup_name"
    
    if [ "$incremental_backup" = true ]; then
        # 查找最近的完整备份
        local last_full_backup=$(find "$backup_dir" -name "backup_*.tar.gz" | sort -r | head -1)
        
        if [ -f "$last_full_backup" ]; then
            log "使用增量备份模式，基于: $(basename "$last_full_backup")"
            tar -czf "$backup_path.tar.gz" $exclude_args --listed-incremental="$backup_dir/incremental.snar" "${backup_dirs[@]}"
        else
            log "未找到完整备份，执行完整备份"
            tar -czf "$backup_path.tar.gz" $exclude_args "${backup_dirs[@]}"
            # 创建增量备份标记文件
            touch "$backup_dir/incremental.snar"
        fi
    else
        log "执行完整备份"
        tar -czf "$backup_path.tar.gz" $exclude_args "${backup_dirs[@]}"
    fi
    
    # 加密备份
    if [ -n "$encryption_password" ]; then
        log "加密备份文件"
        openssl enc -aes-256-cbc -salt -in "$backup_path.tar.gz" -out "$backup_path.tar.gz.enc" -k "$encryption_password"
        if [ $? -eq 0 ]; then
            rm "$backup_path.tar.gz"
            log "备份已加密: $backup_path.tar.gz.enc"
        else
            log "加密失败，保留未加密备份"
        fi
    else
        log "备份完成: $backup_path.tar.gz"
    fi
    
    # 清理旧备份
    cleanup_old_backups
    
    log "备份完成！"
}

# 恢复函数
do_restore() {
    local backup_file=$1
    
    if [ ! -f "$backup_file" ]; then
        log "错误: 备份文件不存在: $backup_file"
        return 1
    fi
    
    log "开始恢复备份: $(basename "$backup_file")"
    
    # 解密备份
    if [[ "$backup_file" == *.enc ]]; then
        if [ -z "$encryption_password" ]; then
            log "错误: 备份文件已加密，但未设置加密密码"
            return 1
        fi
        
        log "解密备份文件"
        openssl enc -d -aes-256-cbc -in "$backup_file" -out "$backup_file.tmp" -k "$encryption_password"
        if [ $? -ne 0 ]; then
            log "解密失败"
            return 1
        fi
        backup_file="$backup_file.tmp"
    fi
    
    # 恢复备份
    log "恢复文件系统"
    tar -xzf "$backup_file" -C /
    
    # 清理临时文件
    if [[ "$backup_file" == *.tmp ]]; then
        rm "$backup_file"
    fi
    
    log "恢复完成！"
}

# 清理旧备份函数
cleanup_old_backups() {
    log "清理 ${backup_retention} 天前的旧备份"
    find "$backup_dir" -name "backup_*.tar.gz*" -mtime +$backup_retention -delete
    log "清理完成"
}

# 列出备份函数
list_backups() {
    log "可用备份："
    find "$backup_dir" -name "backup_*.tar.gz*" -type f | sort -r | while read backup; do
        local size=$(du -h "$backup" | cut -f1)
        local date=$(stat -c %y "$backup" | cut -d' ' -f1,2)
        log "- $(basename "$backup") ($size) - $date"
    done
}

# 主函数
main() {
    case "$1" in
        "backup")
            do_backup
            ;;
        "restore")
            if [ -n "$2" ]; then
                do_restore "$2"
            else
                log "错误: 请指定备份文件"
                log "用法: $0 restore <backup_file>"
            fi
            ;;
        "list")
            list_backups
            ;;
        "cleanup")
            cleanup_old_backups
            ;;
        *)
            log "用法: $0 [backup|restore|list|cleanup]"
            log "  backup   - 执行备份"
            log "  restore  - 恢复备份"
            log "  list     - 列出可用备份"
            log "  cleanup  - 清理旧备份"
            ;;
    esac
}

# 执行主函数
main "$@"
