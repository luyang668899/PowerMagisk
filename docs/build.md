# 开发文档

## 环境设置

### 支持的平台
- Linux x64
- macOS x64 (Intel)
- macOS arm64 (Apple Silicon)
- Windows x64

### 必要工具安装

1. **Windows 特殊要求**
   - 启用 [开发者模式](https://learn.microsoft.com/en-us/windows/apps/get-started/enable-your-device-for-development)，因为需要符号链接支持

2. **Python 3.8+**
   - Linux/macOS: 使用包管理器安装 `python3`
   - Windows: 从 [官方网站](https://www.python.org/downloads/windows/) 下载并安装最新版本
     - 安装时确保选择 **"Add Python to PATH"**
   - (Windows 可选): 运行 `pip install colorama` 安装 `colorama` 包

3. **Git**
   - Linux/macOS: 使用包管理器安装 `git`
   - Windows: 从 [官方网站](https://git-scm.com/download/win) 下载并安装最新版本
     - 安装时确保选择 **"Enable symbolic links"**

4. **Android Studio**
   - 下载并安装最新版本
   - 完成初始设置向导

5. **环境变量配置**
   - 设置 `ANDROID_HOME` 环境变量指向 Android SDK 目录（可在 Android Studio 设置中找到）
   - 设置 `ANDROID_STUDIO` 环境变量指向 Android Studio 安装目录（推荐，构建脚本会自动使用内置 JDK）
   - 或手动安装 JDK 17

6. **获取源码**
   ```bash
   git clone --recurse-submodules https://github.com/luyang668899/PowerMagisk.git
   cd PowerMagisk
   ```

7. **安装 NDK**
   ```bash
   ./build.py ndk
   ```

## 构建方法

### 构建完整项目
```bash
./build.py all
```

### 构建特定组件
```bash
# 查看所有可用选项
./build.py

# 查看具体命令帮助
./build.py [命令] -h

# 示例：查看 binary 命令帮助
./build.py binary -h
```

### 构建配置
- 复制 `config.prop.sample` 为 `config.prop`
- 根据需要修改配置选项

## IDE 支持

### Android Studio
- 支持 Kotlin、Java、C++ 和 C 代码
- 可直接将仓库作为项目打开

### Rust 开发
1. **安装 rustup**
   - 从 [官方网站](https://www.rust-lang.org/tools/install) 下载并安装

2. **配置 Rust 工具链**
   ```bash
   # 链接 ONDK 工具链
   rustup toolchain link magisk "$ANDROID_HOME/ndk/magisk/toolchains/rust"
   # 设置为默认工具链
   rustup default magisk
   ```

3. **VSCode 配置**
   - 安装 [rust-analyzer](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer) 插件

4. **JetBrains IDE 配置**
   - 安装官方 nightly 工具链
     ```bash
     rustup toolchain install nightly
     rustup +nightly component add rust-src clippy
     ```
   - 创建 wrapper 目录
     ```bash
     ./build.py rustup ~/.cargo/wrapper
     ```
   - 在 IDE 设置中：Settings > Rust > Toolchain location，设置为刚才创建的 wrapper 目录

### 注意事项
- 在处理原生代码前，先运行 `./build.py binary` 构建所有原生代码，因为一些生成的代码只在构建过程中创建

## 签名和分发

### 签名机制
- 发布版本中，签名 Magisk APK 的密钥证书会被 Magisk 根守护进程用作参考，以拒绝并强制卸载任何不匹配的 Magisk 应用，保护用户免受恶意和未验证的 Magisk APK 的侵害

### 开发模式
- 要在 Magisk 本身上进行开发，请切换到 **官方调试构建并重新安装 Magisk** 以关闭签名检查

### 自定义签名
- 要分发使用自己的密钥签名的 Magisk 构建，请在 `config.prop` 中设置签名配置
- 查看 [Google 文档](https://developer.android.com/studio/publish/app-signing.html#generate-key) 了解生成自己密钥的更多详细信息

## 自定义模块开发

### 模块分类

#### 系统优化模块
- **magisk-performance**: 优化系统内存管理、CPU 调度和 I/O 性能
- **magisk-battery**: 减少后台应用唤醒、优化系统服务和硬件功耗
- **magisk-network**: 优化网络堆栈、DNS 解析和连接管理

#### 安全增强模块
- **magisk-privacy**: 阻止应用收集敏感信息，限制权限滥用
- **magisk-security**: 增强系统安全性，防止恶意应用和攻击
- **magisk-firewall**: 实现系统级防火墙，控制应用网络访问

#### 跨平台集成模块
- **magisk-integration**: 与 Tasker、Xposed 模块和系统应用集成
- **magisk-cloud-services**: 提供云同步、远程管理和模块更新服务

#### 开发工具模块
- **magisk-tools**: 包含系统维护工具和开发实用程序

### 模块开发指南

#### 1. 模块结构
每个模块遵循标准的 Magisk 模块结构：
```
module/
├── module.prop         # 模块配置
├── post-fs-data.sh     # 系统启动后执行的脚本
├── service.sh          # 服务脚本（可选）
├── system/             # 系统文件（可选）
└── install.sh          # 安装脚本
```

#### 2. 开发流程
1. **创建模块目录结构**
2. **编辑 module.prop**，填写模块信息
3. **编写初始化脚本**：
   - `post-fs-data.sh`: 系统启动后执行
   - `service.sh`: 后台服务（可选）
4. **测试模块功能**
5. **打包模块**：将模块目录打包为 zip 文件

#### 3. 测试
- 在受控环境中测试模块，确保功能正常
- 测试不同 Android 版本的兼容性

#### 4. 分发
- 通过 Magisk Manager 分发模块
- 或通过其他渠道分享

## 开发最佳实践

1. **代码风格**
   - 遵循项目现有的代码风格
   - 使用有意义的变量和函数名
   - 添加适当的注释

2. **版本控制**
   - 定期提交代码
   - 编写清晰的提交信息
   - 遵循 Git 工作流程

3. **调试技巧**
   - 使用 `./build.py debug` 构建调试版本
   - 查看日志文件：`cat /data/adb/modules/[模块名]/module.log`
   - 使用 Android Studio 的调试工具

4. **性能优化**
   - 优化脚本执行时间
   - 避免在 `post-fs-data.sh` 中执行耗时操作
   - 使用后台服务处理复杂任务

5. **安全性**
   - 避免使用硬编码的敏感信息
   - 检查权限和路径
   - 验证输入和输出

## 常见问题

### 构建失败
- 检查依赖是否安装正确
- 检查环境变量设置
- 查看构建日志获取详细错误信息

### 模块不生效
- 确认模块已正确安装并启用
- 检查模块权限
- 查看模块日志

### IDE 配置问题
- 确保已安装所有必要的插件
- 检查工具链配置
- 重启 IDE 或清除缓存

## 联系支持

如果遇到问题或有建议：
- 查看项目文档获取详细信息
- 提交问题到项目仓库
- 参与社区讨论

