#!/system/bin/sh

# Magisk 模块自动化测试工具脚本
# 用于自动化测试 Magisk 模块的功能

TEST_LOG="/data/adb/backups/module_test.log"
TEST_RESULT="/data/adb/backups/module_test_result.json"

# 确保日志目录存在
mkdir -p "$(dirname "$TEST_LOG")"

# 日志函数
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$TEST_LOG"
    echo "$1"
}

# 初始化测试结果
init_test_result() {
    cat > "$TEST_RESULT" << EOF
{
    "test_date": "$(date '+%Y-%m-%d %H:%M:%S')",
    "modules": []
}
EOF
}

# 添加模块测试结果
add_module_result() {
    local module_id=$1
    local status=$2
    local message=$3
    local duration=$4
    
    # 读取当前结果
    local current_result=$(cat "$TEST_RESULT")
    
    # 移除最后的 ]}
    local updated_result=$(echo "$current_result" | sed 's/\]}\s*$//')
    
    # 添加新的模块结果
    if [ "$(echo "$updated_result" | grep -c "modules":\s*\[)" -gt 0 ]; then
        # 第一个模块
        updated_result="$updated_result{
        \"module_id\": \"$module_id\",
        \"status\": \"$status\",
        \"message\": \"$message\",
        \"duration\": \"$duration\"
    }]}"
    else
        # 后续模块
        updated_result="$updated_result,
    {
        \"module_id\": \"$module_id\",
        \"status\": \"$status\",
        \"message\": \"$message\",
        \"duration\": \"$duration\"
    }]}"
    fi
    
    # 写入更新后的结果
    echo "$updated_result" > "$TEST_RESULT"
}

# 测试模块安装
test_module_install() {
    local module_zip=$1
    local module_id=$(basename "$module_zip" .zip)
    
    log "测试模块安装: $module_id"
    
    local start_time=$(date +%s)
    
    # 安装模块
    log "安装模块..."
    magisk --install-module "$module_zip"
    local install_status=$?
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [ "$install_status" -eq 0 ]; then
        log "模块安装成功"
        add_module_result "$module_id" "PASS" "模块安装成功" "$duration 秒"
        return 0
    else
        log "模块安装失败"
        add_module_result "$module_id" "FAIL" "模块安装失败" "$duration 秒"
        return 1
    fi
}

# 测试模块功能
test_module_functionality() {
    local module_id=$1
    
    log "测试模块功能: $module_id"
    
    local start_time=$(date +%s)
    
    # 检查模块是否存在
    local module_dir="/data/adb/modules/$module_id"
    if [ ! -d "$module_dir" ]; then
        log "错误: 模块目录不存在"
        add_module_result "$module_id" "FAIL" "模块目录不存在" "0 秒"
        return 1
    fi
    
    # 检查模块文件
    log "检查模块文件..."
    local required_files=(
        "module.prop"
        "post-fs-data.sh"
        "service.sh"
        "uninstall.sh"
    )
    
    local missing_files=()
    for file in "${required_files[@]}"; do
        if [ ! -f "$module_dir/$file" ]; then
            missing_files+=($file)
        fi
    done
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        log "错误: 缺少必要文件: ${missing_files[*]}"
        add_module_result "$module_id" "FAIL" "缺少必要文件: ${missing_files[*]}" "0 秒"
        return 1
    fi
    
    # 检查模块权限
    log "检查模块权限..."
    local permission_issues=()
    for file in "${required_files[@]}"; do
        if [ ! -x "$module_dir/$file" ]; then
            permission_issues+=($file)
        fi
    done
    
    if [ ${#permission_issues[@]} -gt 0 ]; then
        log "警告: 文件缺少执行权限: ${permission_issues[*]}"
        # 修复权限
        for file in "${permission_issues[@]}"; do
            chmod +x "$module_dir/$file"
        done
    fi
    
    # 测试模块脚本执行
    log "测试模块脚本..."
    if [ -f "$module_dir/post-fs-data.sh" ]; then
        log "执行 post-fs-data.sh 脚本..."
        bash "$module_dir/post-fs-data.sh"
        local post_fs_data_status=$?
        if [ "$post_fs_data_status" -ne 0 ]; then
            log "错误: post-fs-data.sh 脚本执行失败"
            add_module_result "$module_id" "FAIL" "post-fs-data.sh 脚本执行失败" "0 秒"
            return 1
        fi
    fi
    
    if [ -f "$module_dir/service.sh" ]; then
        log "执行 service.sh 脚本..."
        bash "$module_dir/service.sh"
        local service_sh_status=$?
        if [ "$service_sh_status" -ne 0 ]; then
            log "错误: service.sh 脚本执行失败"
            add_module_result "$module_id" "FAIL" "service.sh 脚本执行失败" "0 秒"
            return 1
        fi
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log "模块功能测试通过"
    add_module_result "$module_id" "PASS" "模块功能测试通过" "$duration 秒"
    return 0
}

# 测试模块卸载
test_module_uninstall() {
    local module_id=$1
    
    log "测试模块卸载: $module_id"
    
    local start_time=$(date +%s)
    
    # 卸载模块
    log "卸载模块..."
    magisk --remove-module "$module_id"
    local uninstall_status=$?
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # 检查模块是否已卸载
    local module_dir="/data/adb/modules/$module_id"
    if [ ! -d "$module_dir" ] && [ "$uninstall_status" -eq 0 ]; then
        log "模块卸载成功"
        add_module_result "$module_id" "PASS" "模块卸载成功" "$duration 秒"
        return 0
    else
        log "模块卸载失败"
        add_module_result "$module_id" "FAIL" "模块卸载失败" "$duration 秒"
        return 1
    fi
}

# 运行完整测试套件
run_test_suite() {
    local module_zip=$1
    local module_id=$(basename "$module_zip" .zip)
    
    log "开始测试套件: $module_id"
    
    # 初始化测试结果
    init_test_result
    
    # 测试安装
    test_module_install "$module_zip"
    if [ $? -ne 0 ]; then
        log "安装测试失败，跳过后续测试"
        return 1
    fi
    
    # 测试功能
    test_module_functionality "$module_id"
    if [ $? -ne 0 ]; then
        log "功能测试失败，跳过卸载测试"
        return 1
    fi
    
    # 测试卸载
    test_module_uninstall "$module_id"
    if [ $? -ne 0 ]; then
        log "卸载测试失败"
        return 1
    fi
    
    log "测试套件完成: $module_id"
    log "测试结果: PASS"
    return 0
}

# 批量测试模块
batch_test_modules() {
    local modules_dir=$1
    
    log "开始批量测试模块"
    
    # 初始化测试结果
    init_test_result
    
    # 查找所有模块 zip 文件
    local module_zips=($(find "$modules_dir" -name "*.zip"))
    
    if [ ${#module_zips[@]} -eq 0 ]; then
        log "错误: 未找到模块文件"
        return 1
    fi
    
    log "找到 ${#module_zips[@]} 个模块文件"
    
    # 测试每个模块
    for module_zip in "${module_zips[@]}"; do
        log "测试模块: $module_zip"
        run_test_suite "$module_zip"
    done
    
    log "批量测试完成"
    log "测试结果已保存到: $TEST_RESULT"
}

# 显示测试结果
display_test_results() {
    if [ -f "$TEST_RESULT" ]; then
        log "测试结果:"
        cat "$TEST_RESULT"
    else
        log "错误: 测试结果文件不存在"
    fi
}

# 主函数
main() {
    case "$1" in
        "install")
            if [ -n "$2" ]; then
                init_test_result
                test_module_install "$2"
                display_test_results
            else
                log "错误: 请指定模块 zip 文件"
                show_help
            fi
            ;;
        "functionality")
            if [ -n "$2" ]; then
                init_test_result
                test_module_functionality "$2"
                display_test_results
            else
                log "错误: 请指定模块 ID"
                show_help
            fi
            ;;
        "uninstall")
            if [ -n "$2" ]; then
                init_test_result
                test_module_uninstall "$2"
                display_test_results
            else
                log "错误: 请指定模块 ID"
                show_help
            fi
            ;;
        "suite")
            if [ -n "$2" ]; then
                run_test_suite "$2"
                display_test_results
            else
                log "错误: 请指定模块 zip 文件"
                show_help
            fi
            ;;
        "batch")
            if [ -n "$2" ]; then
                batch_test_modules "$2"
                display_test_results
            else
                log "错误: 请指定模块目录"
                show_help
            fi
            ;;
        "results")
            display_test_results
            ;;
        *)
            show_help
            ;;
    esac
}

# 显示帮助信息
show_help() {
    echo "Magisk 模块自动化测试工具"
    echo "用法: $0 [命令] [参数]"
    echo ""
    echo "命令:"
    echo "  install <模块 zip>    - 测试模块安装"
    echo "  functionality <模块 ID> - 测试模块功能"
    echo "  uninstall <模块 ID>   - 测试模块卸载"
    echo "  suite <模块 zip>      - 运行完整测试套件"
    echo "  batch <目录>          - 批量测试目录中的模块"
    echo "  results              - 显示测试结果"
    echo ""
    echo "示例:"
    echo "  $0 suite /sdcard/modules/mymodule.zip"
    echo "  $0 batch /sdcard/modules"
}

# 执行主函数
main "$@"
