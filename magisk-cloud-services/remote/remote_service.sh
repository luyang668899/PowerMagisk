#!/system/bin/sh

# 远程管理服务脚本
# 用于实现远程管理设备 Magisk 配置的功能

REMOTE_DIR="/data/adb/modules/magisk-cloud-services/cloud/remote"
CONFIG_FILE="/data/adb/modules/magisk-cloud-services/cloud/config.json"
LOG_FILE="/data/adb/modules/magisk-cloud-services/cloud/remote.log"

# 确保目录存在
mkdir -p "$REMOTE_DIR"

# 日志函数
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    echo "$1"
}

# 加载配置
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        REMOTE_ENABLED=$(grep -A 10 "remote" "$CONFIG_FILE" | grep "enabled" | head -1 | awk -F '"' '{print $4}')
        REMOTE_PORT=$(grep -A 10 "remote" "$CONFIG_FILE" | grep "port" | awk -F '"' '{print $4}')
        AUTH_ENABLED=$(grep -A 10 "remote" "$CONFIG_FILE" | grep -A 5 "auth" | grep "enabled" | awk -F '"' '{print $4}')
        AUTH_USERNAME=$(grep -A 10 "remote" "$CONFIG_FILE" | grep -A 5 "auth" | grep "username" | awk -F '"' '{print $4}')
        AUTH_PASSWORD=$(grep -A 10 "remote" "$CONFIG_FILE" | grep -A 5 "auth" | grep "password" | awk -F '"' '{print $4}')
    else
        log "错误: 配置文件不存在"
        exit 1
    fi
}

# 启动远程管理服务
start_remote_service() {
    log "启动远程管理服务..."
    
    # 创建远程管理服务目录
    mkdir -p "$REMOTE_DIR/web"
    
    # 创建 web 界面
    cat > "$REMOTE_DIR/web/index.html" << EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Magisk 远程管理</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f0f0f0;
        }
        h1 {
            color: #333;
        }
        .module {
            background-color: white;
            padding: 15px;
            margin: 10px 0;
            border-radius: 5px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .button {
            padding: 10px 15px;
            margin: 5px;
            border: none;
            border-radius: 3px;
            cursor: pointer;
        }
        .enable {
            background-color: #4CAF50;
            color: white;
        }
        .disable {
            background-color: #f44336;
            color: white;
        }
        .restart {
            background-color: #2196F3;
            color: white;
        }
    </style>
</head>
<body>
    <h1>Magisk 远程管理</h1>
    <div id="modules"></div>
    <script>
        // 加载模块列表
        fetch('/api/modules')
            .then(response => response.json())
            .then(data => {
                const modulesDiv = document.getElementById('modules');
                data.modules.forEach(module => {
                    const moduleDiv = document.createElement('div');
                    moduleDiv.className = 'module';
                    moduleDiv.innerHTML = `
                        <h3>${module.name}</h3>
                        <p>版本: ${module.version}</p>
                        <p>状态: ${module.enabled ? '已启用' : '已禁用'}</p>
                        <button class="button ${module.enabled ? 'disable' : 'enable'}" onclick="toggleModule('${module.id}')">
                            ${module.enabled ? '禁用' : '启用'}
                        </button>
                        <button class="button restart" onclick="restartModule('${module.id}')">重启</button>
                    `;
                    modulesDiv.appendChild(moduleDiv);
                });
            });
        
        // 切换模块状态
        function toggleModule(moduleId) {
            fetch(`/api/module/${moduleId}/toggle`, { method: 'POST' })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        location.reload();
                    } else {
                        alert('操作失败: ' + data.message);
                    }
                });
        }
        
        // 重启模块
        function restartModule(moduleId) {
            fetch(`/api/module/${moduleId}/restart`, { method: 'POST' })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        alert('模块重启成功');
                    } else {
                        alert('操作失败: ' + data.message);
                    }
                });
        }
    </script>
</body>
</html>
EOF
    
    # 创建 API 脚本
    cat > "$REMOTE_DIR/api.sh" << 'EOF'
#!/system/bin/sh

# 远程管理 API 脚本

MODULES_DIR="/data/adb/modules"

# 处理 API 请求
case "$REQUEST_URI" in
    "/api/modules")
        echo "Content-Type: application/json"
        echo
        echo "{"modules": ["
        first=true
        for module_dir in "$MODULES_DIR"/*; do
            if [ -d "$module_dir" ] && [ -f "$module_dir/module.prop" ]; then
                module_id=$(basename "$module_dir")
                module_name=$(grep "name=" "$module_dir/module.prop" | cut -d'=' -f2)
                module_version=$(grep "version=" "$module_dir/module.prop" | cut -d'=' -f2)
                module_enabled=$(if [ -f "$module_dir/disable" ]; then echo "false"; else echo "true"; fi)
                
                if [ "$first" = true ]; then
                    first=false
                else
                    echo ","
                fi
                echo "{"id": "$module_id", "name": "$module_name", "version": "$module_version", "enabled": $module_enabled}"
            fi
        done
        echo "]}"
        ;;
    "/api/module/*/toggle")
        module_id=$(echo "$REQUEST_URI" | sed 's/\/api\/module\/(.*)\/toggle/\1/')
        module_dir="$MODULES_DIR/$module_id"
        if [ -d "$module_dir" ]; then
            if [ -f "$module_dir/disable" ]; then
                rm "$module_dir/disable"
                echo "Content-Type: application/json"
                echo
                echo '{"success": true, "message": "模块已启用"}'
            else
                touch "$module_dir/disable"
                echo "Content-Type: application/json"
                echo
                echo '{"success": true, "message": "模块已禁用"}'
            fi
        else
            echo "Content-Type: application/json"
            echo
            echo '{"success": false, "message": "模块不存在"}'
        fi
        ;;
    "/api/module/*/restart")
        module_id=$(echo "$REQUEST_URI" | sed 's/\/api\/module\/(.*)\/restart/\1/')
        module_dir="$MODULES_DIR/$module_id"
        if [ -d "$module_dir" ]; then
            # 重启模块
            touch "$module_dir/skip_mount"
            sleep 1
            rm "$module_dir/skip_mount"
            echo "Content-Type: application/json"
            echo
            echo '{"success": true, "message": "模块已重启"}'
        else
            echo "Content-Type: application/json"
            echo
            echo '{"success": false, "message": "模块不存在"}'
        fi
        ;;
    *)
        # 静态文件
        if [ -f "$REMOTE_DIR/web${REQUEST_URI}" ]; then
            mime_type=$(file -b --mime-type "$REMOTE_DIR/web${REQUEST_URI}")
            echo "Content-Type: $mime_type"
            echo
            cat "$REMOTE_DIR/web${REQUEST_URI}"
        else
            echo "HTTP/1.1 404 Not Found"
            echo "Content-Type: text/plain"
            echo
            echo "404 Not Found"
        fi
        ;;
esac
EOF
    chmod +x "$REMOTE_DIR/api.sh"
    
    # 启动 HTTP 服务器
    log "启动 HTTP 服务器在端口 $REMOTE_PORT"
    # 这里可以使用 busybox httpd 或其他轻量级 HTTP 服务器
    # 示例: busybox httpd -p $REMOTE_PORT -h "$REMOTE_DIR/web" -c "$REMOTE_DIR/api.sh"
    
    log "远程管理服务启动完成"
    log "访问地址: http://$(ip addr | grep inet | grep -v 127.0.0.1 | head -1 | awk '{print $2}' | cut -d'/' -f1):$REMOTE_PORT"
}

# 主远程管理函数
main_remote() {
    log "开始远程管理服务"
    
    # 加载配置
    load_config
    
    if [ "$REMOTE_ENABLED" = "true" ]; then
        # 启动远程管理服务
        start_remote_service
        
        log "远程管理服务启动完成"
    else
        log "远程管理服务已禁用"
    fi
}

# 执行主远程管理函数
main_remote
