#include <zygisk.hpp>
#include <string>
#include <vector>
#include <map>
#include <android/log.h>
#include <fstream>
#include <chrono>
#include <ctime>

using namespace std;
using namespace zygisk;

#define LOG_TAG "ZygiskBehaviorMonitor"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

// 行为类型定义
enum class BehaviorType {
    NETWORK_ACCESS,
    FILE_ACCESS,
    PERMISSION_REQUEST,
    SENSITIVE_API_CALL,
    DYNAMIC_CODE_LOAD,
    PROCESS_CREATION
};

// 行为记录结构体
typedef struct {
    string packageName;
    BehaviorType type;
    string details;
    long timestamp;
} BehaviorRecord;

// 可疑行为规则结构体
typedef struct {
    BehaviorType type;
    string pattern;
    int severity; // 1-5, 5 being most severe
} SuspiciousRule;

// 全局变量
vector<BehaviorRecord> behaviorRecords;
vector<SuspiciousRule> suspiciousRules;
map<string, int> appSuspiciousScore;

// 日志文件路径
const string LOG_FILE = "/data/adb/modules/zygisk-behavior-monitor/logs/behavior.log";

// 初始化日志目录
void initLogDirectory() {
    system("mkdir -p /data/adb/modules/zygisk-behavior-monitor/logs");
    system("chmod 755 /data/adb/modules/zygisk-behavior-monitor/logs");
}

// 获取当前时间戳
long getCurrentTimestamp() {
    return chrono::duration_cast<chrono::milliseconds>(chrono::system_clock::now().time_since_epoch()).count();
}

// 获取时间字符串
string getTimeString(long timestamp) {
    time_t time = timestamp / 1000;
    char buffer[20];
    strftime(buffer, sizeof(buffer), "%Y-%m-%d %H:%M:%S", localtime(&time));
    return string(buffer);
}

// 加载可疑行为规则
void loadSuspiciousRules() {
    // 网络访问规则
    suspiciousRules.push_back({BehaviorType::NETWORK_ACCESS, "http://.*\.malicious\.com", 5});
    suspiciousRules.push_back({BehaviorType::NETWORK_ACCESS, "https://.*\.suspicious\.com", 4});
    
    // 文件访问规则
    suspiciousRules.push_back({BehaviorType::FILE_ACCESS, "/data/data/.*\/files\/.*\.dex", 4});
    suspiciousRules.push_back({BehaviorType::FILE_ACCESS, "/system\/.*", 3});
    
    // 权限请求规则
    suspiciousRules.push_back({BehaviorType::PERMISSION_REQUEST, "android\.permission\.READ_CONTACTS", 3});
    suspiciousRules.push_back({BehaviorType::PERMISSION_REQUEST, "android\.permission\.CAMERA", 2});
    
    // 敏感 API 调用规则
    suspiciousRules.push_back({BehaviorType::SENSITIVE_API_CALL, "exec\(.*\)", 5});
    suspiciousRules.push_back({BehaviorType::SENSITIVE_API_CALL, "Runtime\.getRuntime\(\)\.exec", 5});
}

// 记录行为
void recordBehavior(const string& packageName, BehaviorType type, const string& details) {
    BehaviorRecord record;
    record.packageName = packageName;
    record.type = type;
    record.details = details;
    record.timestamp = getCurrentTimestamp();
    
    behaviorRecords.push_back(record);
    
    // 检查是否为可疑行为
    checkSuspiciousBehavior(record);
    
    // 写入日志文件
    writeToLog(record);
}

// 检查可疑行为
void checkSuspiciousBehavior(const BehaviorRecord& record) {
    for (const auto& rule : suspiciousRules) {
        if (rule.type == record.type) {
            // 这里可以使用正则表达式匹配
            // 简化实现，使用字符串包含检查
            if (record.details.find(rule.pattern) != string::npos) {
                int score = appSuspiciousScore[record.packageName];
                score += rule.severity;
                appSuspiciousScore[record.packageName] = score;
                
                if (score > 10) {
                    LOGI("[SUSPICIOUS] App %s has high suspicious score: %d", record.packageName.c_str(), score);
                    // 这里可以添加通知机制
                }
            }
        }
    }
}

// 写入日志文件
void writeToLog(const BehaviorRecord& record) {
    ofstream logFile(LOG_FILE, ios::app);
    if (logFile.is_open()) {
        string typeStr;
        switch (record.type) {
            case BehaviorType::NETWORK_ACCESS:
                typeStr = "NETWORK_ACCESS";
                break;
            case BehaviorType::FILE_ACCESS:
                typeStr = "FILE_ACCESS";
                break;
            case BehaviorType::PERMISSION_REQUEST:
                typeStr = "PERMISSION_REQUEST";
                break;
            case BehaviorType::SENSITIVE_API_CALL:
                typeStr = "SENSITIVE_API_CALL";
                break;
            case BehaviorType::DYNAMIC_CODE_LOAD:
                typeStr = "DYNAMIC_CODE_LOAD";
                break;
            case BehaviorType::PROCESS_CREATION:
                typeStr = "PROCESS_CREATION";
                break;
        }
        
        logFile << getTimeString(record.timestamp) << " | " 
                << record.packageName << " | " 
                << typeStr << " | " 
                << record.details << endl;
        
        logFile.close();
    }
}

// 网络访问监控钩子
class NetworkMonitorHook {
private:
    static int (*originalConnect)(int, const struct sockaddr*, socklen_t);
    
    static int connectHook(int sockfd, const struct sockaddr* addr, socklen_t addrlen) {
        // 解析地址信息
        char host[NI_MAXHOST];
        char service[NI_MAXSERV];
        getnameinfo(addr, addrlen, host, NI_MAXHOST, service, NI_MAXSERV, NI_NUMERICSERV);
        
        // 获取当前应用包名（需要从 Zygisk 上下文中获取）
        string packageName = "unknown";
        
        recordBehavior(packageName, BehaviorType::NETWORK_ACCESS, string("Connect to ") + host + ":" + service);
        
        return originalConnect(sockfd, addr, addrlen);
    }
    
public:
    void hookNetworkAccess() {
        // 这里需要使用 Zygisk 的内存操作 API 来 hook connect 函数
        LOGD("Attempting to hook network access functions");
    }
};

// 文件访问监控钩子
class FileMonitorHook {
private:
    static int (*originalOpen)(const char*, int, ...);
    
    static int openHook(const char* pathname, int flags, ...) {
        // 获取当前应用包名
        string packageName = "unknown";
        
        recordBehavior(packageName, BehaviorType::FILE_ACCESS, string("Open file: ") + pathname);
        
        // 调用原始函数
        mode_t mode = 0;
        if (flags & O_CREAT) {
            va_list args;
            va_start(args, flags);
            mode = va_arg(args, mode_t);
            va_end(args);
            return originalOpen(pathname, flags, mode);
        } else {
            return originalOpen(pathname, flags);
        }
    }
    
public:
    void hookFileAccess() {
        // 这里需要使用 Zygisk 的内存操作 API 来 hook open 函数
        LOGD("Attempting to hook file access functions");
    }
};

// 权限请求监控钩子
class PermissionMonitorHook {
private:
    static int (*originalCheckSelfPermission)(JNIEnv*, jobject, jstring);
    
    static int checkSelfPermissionHook(JNIEnv* env, jobject thiz, jstring permission) {
        if (permission == nullptr) {
            return originalCheckSelfPermission(env, thiz, permission);
        }
        
        // 获取当前应用包名
        jclass contextClass = env->GetObjectClass(thiz);
        jmethodID getPackageNameMethod = env->GetMethodID(contextClass, "getPackageName", "()Ljava/lang/String;");
        jstring packageNameObj = (jstring)env->CallObjectMethod(thiz, getPackageNameMethod);
        const char* pkgStr = env->GetStringUTFChars(packageNameObj, nullptr);
        const char* permStr = env->GetStringUTFChars(permission, nullptr);
        
        string packageName = pkgStr;
        string perm = permStr;
        
        recordBehavior(packageName, BehaviorType::PERMISSION_REQUEST, string("Request permission: ") + perm);
        
        env->ReleaseStringUTFChars(packageNameObj, pkgStr);
        env->ReleaseStringUTFChars(permission, permStr);
        
        return originalCheckSelfPermission(env, thiz, permission);
    }
    
public:
    void hookPermissionRequests(JNIEnv* env) {
        // 这里需要使用 Zygisk 的内存操作 API 来 hook checkSelfPermission 方法
        LOGD("Attempting to hook permission request functions");
    }
};

// 静态成员初始化
int (*NetworkMonitorHook::originalConnect)(int, const struct sockaddr*, socklen_t) = nullptr;
int (*FileMonitorHook::originalOpen)(const char*, int, ...) = nullptr;
int (*PermissionMonitorHook::originalCheckSelfPermission)(JNIEnv*, jobject, jstring) = nullptr;

// Zygisk 模块类
class BehaviorMonitorModule : public ModuleBase {
private:
    NetworkMonitorHook networkMonitor;
    FileMonitorHook fileMonitor;
    PermissionMonitorHook permissionMonitor;

public:
    void onLoad() override {
        LOGD("Zygisk Behavior Monitor module loaded");
        initLogDirectory();
        loadSuspiciousRules();
    }

    void preAppSpecialize(AppSpecializeArgs *args) override {
        if (args != nullptr) {
            string packageName = args->nice_name;
            LOGD("Preparing to specialize app: %s", packageName.c_str());
        }
    }

    void postAppSpecialize(const AppSpecializeArgs *args) override {
        if (args != nullptr) {
            string packageName = args->nice_name;
            LOGD("Specialized app: %s", packageName.c_str());

            // 初始化 JNI 环境
            JNIEnv* env = nullptr;
            if (JNI_GetCreatedJavaVMs(&args->vm, 1, nullptr) == 0) {
                if (args->vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6) == 0) {
                    // 钩子权限请求
                    permissionMonitor.hookPermissionRequests(env);
                }
            }

            // 钩子网络访问
            networkMonitor.hookNetworkAccess();
            
            // 钩子文件访问
            fileMonitor.hookFileAccess();
        }
    }

    void preZygoteSpecialize(ZygoteSpecializeArgs *args) override {
        LOGD("Preparing to specialize zygote");
    }

    void postZygoteSpecialize(const ZygoteSpecializeArgs *args) override {
        LOGD("Specialized zygote");
    }
};

// 注册 Zygisk 模块
REGISTER_ZYGISK_MODULE(BehaviorMonitorModule);