#include <zygisk.hpp>
#include <string>
#include <vector>

using namespace std;
using namespace zygisk;

class ExampleModule : public ModuleBase {
private:
    void onLoad() override {
        // 模块加载时的初始化
    }

    void preAppSpecialize(AppSpecializeArgs *args) override {
        // 应用进程启动前的处理
        if (args != nullptr) {
            // 可以在这里修改应用的参数
        }
    }

    void postAppSpecialize(const AppSpecializeArgs *args) override {
        // 应用进程启动后的处理
        // 这里可以注入代码到应用进程
    }

    void preZygoteSpecialize(ZygoteSpecializeArgs *args) override {
        // Zygote 进程启动前的处理
    }

    void postZygoteSpecialize(const ZygoteSpecializeArgs *args) override {
        // Zygote 进程启动后的处理
    }
};

// 注册模块
REGISTER_ZYGISK_MODULE(ExampleModule);
