# Magisk 项目结构

## 1. 项目根目录结构

```
Magisk/
├── app/                # Magisk 应用代码
├── docs/               # 文档目录
├── magisk-battery/     # 电池优化模块
├── magisk-cloud-services/  # 云服务模块
├── magisk-firewall/    # 防火墙模块
├── magisk-integration/ # 跨平台集成模块
├── magisk-module/      # 基础模块
├── magisk-network/     # 网络优化模块
├── magisk-performance/ # 性能优化模块
├── magisk-privacy/     # 隐私保护模块
├── magisk-security/    # 安全加固模块
├── magisk-theme/       # 主题系统
├── magisk-tools/       # 工具和脚本
├── magisk-ui-plugin/   # UI 插件
├── native/             # 原生代码
├── scripts/            # 构建和安装脚本
└── tools/              # 开发工具
```

## 2. 核心目录详解

### 2.1 app/ - Magisk 应用代码

```
app/
├── apk/                # 主应用代码
│   ├── src/main/java/com/topjohnwu/magisk/  # 应用核心代码
│   └── src/main/res/   # 应用资源文件
├── core/               # 核心功能库
│   └── src/main/java/com/topjohnwu/magisk/core/  # 核心功能实现
├── shared/             # 共享代码
├── stub/               # Stub 应用代码
└── build.gradle.kts    # 构建配置
```

### 2.2 native/ - 原生代码

```
native/
├── src/
│   ├── base/           # 基础库
│   ├── boot/           # 启动相关代码
│   ├── core/           # 核心功能
│   │   ├── deny/       # 权限拒绝
│   │   ├── resetprop/  # 属性修改
│   │   ├── su/         # 超级用户
│   │   └── zygisk/     # Zygisk 核心
│   ├── init/           # 初始化代码
│   └── sepolicy/       # SELinux 策略
└── Android.mk          # 原生构建配置
```

### 2.3 scripts/ - 构建和安装脚本

```
scripts/
├── addon.d.sh          # 系统更新后保留 Magisk
├── boot_patch.sh       # 启动镜像补丁
├── flash_script.sh     # 刷入脚本
├── module_installer.sh # 模块安装器
└── uninstaller.sh      # 卸载脚本
```

## 3. 自定义模块目录结构

### 3.1 系统优化模块

#### magisk-performance/
```
magisk-performance/
├── module.prop         # 模块配置
├── post-fs-data.sh     # 系统启动后执行的脚本
└── install.sh          # 安装脚本
```

#### magisk-battery/
```
magisk-battery/
├── module.prop         # 模块配置
├── post-fs-data.sh     # 系统启动后执行的脚本
└── install.sh          # 安装脚本
```

#### magisk-network/
```
magisk-network/
├── module.prop         # 模块配置
├── post-fs-data.sh     # 系统启动后执行的脚本
└── install.sh          # 安装脚本
```

### 3.2 安全性增强模块

#### magisk-privacy/
```
magisk-privacy/
├── module.prop         # 模块配置
├── post-fs-data.sh     # 系统启动后执行的脚本
└── install.sh          # 安装脚本
```

#### magisk-security/
```
magisk-security/
├── module.prop         # 模块配置
├── post-fs-data.sh     # 系统启动后执行的脚本
└── install.sh          # 安装脚本
```

#### magisk-firewall/
```
magisk-firewall/
├── module.prop         # 模块配置
├── post-fs-data.sh     # 系统启动后执行的脚本
└── install.sh          # 安装脚本
```

### 3.3 跨平台集成模块

#### magisk-integration/
```
magisk-integration/
├── tasker/             # Tasker 集成
│   ├── module.prop     # 模块配置
│   ├── post-fs-data.sh # 系统启动后执行的脚本
│   └── tasker/         # Tasker 插件代码
├── xposed/             # Xposed 兼容
│   ├── module.prop     # 模块配置
│   └── post-fs-data.sh # 系统启动后执行的脚本
└── system-apps/        # 系统应用集成
    ├── module.prop     # 模块配置
    └── post-fs-data.sh # 系统启动后执行的脚本
```

#### magisk-cloud-services/
```
magisk-cloud-services/
├── module.prop         # 模块配置
├── post-fs-data.sh     # 系统启动后执行的脚本
├── sync/               # 同步服务
│   └── sync_service.sh # 同步服务脚本
├── remote/             # 远程管理
│   └── remote_service.sh # 远程管理服务脚本
└── update/             # 更新服务
    └── update_service.sh # 更新服务脚本
```

### 3.4 工具和脚本

#### magisk-tools/
```
magisk-tools/
├── scripts/            # 基础脚本
│   ├── system_cleaner.sh # 系统清理脚本
│   └── system_backup.sh  # 系统备份脚本
├── system-maintenance/ # 系统维护工具
│   └── scripts/        # 维护脚本
│       ├── advanced_backup.sh    # 高级备份工具
│       ├── system_repair.sh      # 系统修复工具
│       └── performance_analyzer.sh # 性能分析工具
└── development-tools/  # 开发工具
    ├── framework/      # 模块开发框架
    │   └── create_module.sh # 模块创建脚本
    ├── debug/          # 调试工具
    │   └── module_debugger.sh # 模块调试脚本
    └── test/           # 测试工具
        └── module_tester.sh # 模块测试脚本
```

### 3.5 UI 插件和主题

#### magisk-ui-plugin/
```
magisk-ui-plugin/
├── app/                # 插件应用
│   ├── src/main/java/  # 插件代码
│   └── src/main/res/   # 插件资源
└── build.gradle        # 构建配置
```

#### magisk-theme/
```
magisk-theme/
├── module.prop         # 模块配置
└── system/etc/magisk/theme.xml # 主题配置
```

## 4. 文档目录

```
docs/
├── build.md            # 构建指南
├── usage.md            # 使用说明书
├── project-structure.md # 项目结构文档
├── README.md           # 项目说明
└── images/             # 文档图片
```

## 5. 构建系统

### 5.1 构建脚本

- `build.py` - 主构建脚本
- `config.prop.sample` - 构建配置示例

### 5.2 构建流程

1. 执行 `./build.py ndk` 下载并安装 NDK
2. 执行 `./build.py all` 构建完整的 Magisk APK
3. 构建完成后，APK 文件位于 `app/build/outputs/apk/` 目录

## 6. 模块打包

### 6.1 标准模块结构

```
module/
├── module.prop         # 模块配置
├── post-fs-data.sh     # 系统启动后执行的脚本
├── service.sh          # 服务脚本（可选）
├── system/             # 系统文件（可选）
└── install.sh          # 安装脚本
```

### 6.2 模块打包方法

1. 按照标准模块结构组织文件
2. 使用 zip 命令打包成 zip 文件
3. 通过 Magisk Manager 安装

## 7. 关键文件说明

### 7.1 module.prop

模块配置文件，包含模块的基本信息：

```properties
id=module-id              # 模块唯一标识符
name=Module Name          # 模块名称
version=1.0.0             # 模块版本
versionCode=1             # 版本代码
author=Author Name        # 作者
 description=Module description # 模块描述
```

### 7.2 post-fs-data.sh

系统启动后执行的脚本，用于初始化模块功能：

```bash
#!/system/bin/sh
# 模块初始化脚本

# 执行模块功能
# ...
```

### 7.3 install.sh

模块安装脚本，用于安装模块时执行：

```bash
#!/system/bin/sh
# 模块安装脚本

# 安装逻辑
# ...
```

## 8. 开发流程

1. **环境设置**：安装必要的开发工具和依赖
2. **代码开发**：根据功能需求开发模块
3. **测试**：在测试设备上测试模块功能
4. **打包**：将模块打包成 zip 文件
5. **分发**：通过 Magisk Manager 或其他渠道分发模块

## 9. 版本控制

- 使用 Git 进行版本控制
- 遵循标准的 Git 工作流程
- 定期提交代码，保持代码仓库的整洁

## 10. 总结

Magisk 项目采用模块化的设计，核心代码与自定义模块分离，便于维护和扩展。项目结构清晰，各模块职责明确，为开发者提供了良好的开发环境和工具支持。

通过本文档，开发者可以快速了解项目结构，找到所需的代码和资源，从而更高效地进行开发和维护工作。