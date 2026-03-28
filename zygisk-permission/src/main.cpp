#include <zygisk.hpp>
#include <string>
#include <vector>
#include <map>
#include <android/log.h>

using namespace std;
using namespace zygisk;

#define LOG_TAG "ZygiskPermissionManager"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// 权限配置结构体
typedef struct {
    string packageName;
    vector<string> allowedPermissions;
    vector<string> deniedPermissions;
} PermissionConfig;

// 全局权限配置
vector<PermissionConfig> permissionConfigs;

// 加载权限配置
void loadPermissionConfigs() {
    // 这里可以从文件或数据库加载配置
    // 示例配置
    PermissionConfig config1;
    config1.packageName = "com.example.app";
    config1.allowedPermissions = {"android.permission.INTERNET", "android.permission.ACCESS_NETWORK_STATE"};
    config1.deniedPermissions = {"android.permission.CAMERA", "android.permission.RECORD_AUDIO"};
    permissionConfigs.push_back(config1);

    PermissionConfig config2;
    config2.packageName = "com.example.anotherapp";
    config2.allowedPermissions = {"android.permission.INTERNET"};
    config2.deniedPermissions = {"android.permission.ACCESS_FINE_LOCATION", "android.permission.READ_CONTACTS"};
    permissionConfigs.push_back(config2);
}

// 检查权限是否被允许
bool isPermissionAllowed(const string& packageName, const string& permission) {
    for (const auto& config : permissionConfigs) {
        if (config.packageName == packageName) {
            // 检查是否在允许列表中
            for (const auto& allowedPerm : config.allowedPermissions) {
                if (allowedPerm == permission) {
                    return true;
                }
            }
            // 检查是否在拒绝列表中
            for (const auto& deniedPerm : config.deniedPermissions) {
                if (deniedPerm == permission) {
                    return false;
                }
            }
        }
    }
    // 默认允许
    return true;
}

// 权限检查钩子类
class PermissionHook {
private:
    static bool (*originalCheckPermission)(JNIEnv*, jobject, jstring, jstring);
    static int (*originalCheckSelfPermission)(JNIEnv*, jobject, jstring);

    static bool checkPermissionHook(JNIEnv* env, jobject thiz, jstring permission, jstring packageName) {
        if (permission == nullptr || packageName == nullptr) {
            return originalCheckPermission(env, thiz, permission, packageName);
        }

        const char* permStr = env->GetStringUTFChars(permission, nullptr);
        const char* pkgStr = env->GetStringUTFChars(packageName, nullptr);

        bool allowed = isPermissionAllowed(pkgStr, permStr);
        LOGD("Check permission %s for %s: %s", permStr, pkgStr, allowed ? "allowed" : "denied");

        env->ReleaseStringUTFChars(permission, permStr);
        env->ReleaseStringUTFChars(packageName, pkgStr);

        return allowed;
    }

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

        bool allowed = isPermissionAllowed(pkgStr, permStr);
        LOGD("Check self permission %s for %s: %s", permStr, pkgStr, allowed ? "allowed" : "denied");

        env->ReleaseStringUTFChars(packageNameObj, pkgStr);
        env->ReleaseStringUTFChars(permission, permStr);

        return allowed ? 0 : -1; // 0 = PERMISSION_GRANTED, -1 = PERMISSION_DENIED
    }

    void hookMethod(JNIEnv* env, jclass clazz, const char* methodName, const char* signature, void* hookFunc, void** originalFunc) {
        // 这里需要使用 Zygisk 的内存操作 API 来实现钩子
        // 实际实现需要根据 Zygisk 的 API 进行调整
        LOGD("Attempting to hook method: %s", methodName);
    }

public:
    void hookPermissionChecks(JNIEnv* env) {
        // Hook PackageManager 的 checkPermission 方法
        jclass pmClass = env->FindClass("android/content/pm/PackageManager");
        if (pmClass != nullptr) {
            hookMethod(env, pmClass, "checkPermission", "(Ljava/lang/String;Ljava/lang/String;)I", (void*)checkPermissionHook, (void**)&originalCheckPermission);
            LOGD("Hooked PackageManager.checkPermission");
        }

        // Hook Context 的 checkSelfPermission 方法
        jclass contextClass = env->FindClass("android/content/Context");
        if (contextClass != nullptr) {
            hookMethod(env, contextClass, "checkSelfPermission", "(Ljava/lang/String;)I", (void*)checkSelfPermissionHook, (void**)&originalCheckSelfPermission);
            LOGD("Hooked Context.checkSelfPermission");
        }
    }
};

// 静态成员初始化
bool (*PermissionHook::originalCheckPermission)(JNIEnv*, jobject, jstring, jstring) = nullptr;
int (*PermissionHook::originalCheckSelfPermission)(JNIEnv*, jobject, jstring) = nullptr;

// Zygisk 模块类
class PermissionManagerModule : public ModuleBase {
private:
    PermissionHook permissionHook;

public:
    void onLoad() override {
        LOGD("Zygisk Permission Manager module loaded");
        // 加载权限配置
        loadPermissionConfigs();
    }

    void preAppSpecialize(AppSpecializeArgs *args) override {
        if (args != nullptr) {
            // 获取应用包名
            string packageName = args->nice_name;
            LOGD("Preparing to specialize app: %s", packageName.c_str());
        }
    }

    void postAppSpecialize(const AppSpecializeArgs *args) override {
        if (args != nullptr) {
            // 获取应用包名
            string packageName = args->nice_name;
            LOGD("Specialized app: %s", packageName.c_str());

            // 初始化 JNI 环境
            JNIEnv* env = nullptr;
            if (JNI_GetCreatedJavaVMs(&args->vm, 1, nullptr) == 0) {
                if (args->vm->GetEnv(reinterpret_cast<void**>(&env), JNI_VERSION_1_6) == 0) {
                    // 钩子权限检查
                    permissionHook.hookPermissionChecks(env);
                }
            }
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
REGISTER_ZYGISK_MODULE(PermissionManagerModule);
