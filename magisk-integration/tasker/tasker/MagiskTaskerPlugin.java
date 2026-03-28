package com.example.magisktasker;

import android.content.Context;
import android.os.Bundle;
import android.util.Log;

import net.dinglisch.android.tasker.PluginResult;
import net.dinglisch.android.tasker.TaskerPlugin;

public class MagiskTaskerPlugin {

    private static final String TAG = "MagiskTaskerPlugin";

    // 执行 Magisk 相关操作
    public static PluginResult executeMagiskAction(Context context, Bundle inputBundle) {
        String action = inputBundle.getString("action");
        Log.d(TAG, "Executing action: " + action);

        switch (action) {
            case "enable_module":
                return enableModule(inputBundle);
            case "disable_module":
                return disableModule(inputBundle);
            case "restart_magisk":
                return restartMagisk();
            case "get_module_status":
                return getModuleStatus(inputBundle);
            case "install_module":
                return installModule(inputBundle);
            default:
                return new PluginResult(PluginResult.STATUS_ERROR, "Unknown action");
        }
    }

    // 启用模块
    private static PluginResult enableModule(Bundle inputBundle) {
        String moduleId = inputBundle.getString("module_id");
        if (moduleId == null) {
            return new PluginResult(PluginResult.STATUS_ERROR, "Module ID is required");
        }

        try {
            // 执行启用模块的命令
            Process process = Runtime.getRuntime().exec("su -c rm /data/adb/modules/" + moduleId + "/disable");
            process.waitFor();
            int exitCode = process.exitValue();

            if (exitCode == 0) {
                return new PluginResult(PluginResult.STATUS_OK, "Module enabled: " + moduleId);
            } else {
                return new PluginResult(PluginResult.STATUS_ERROR, "Failed to enable module");
            }
        } catch (Exception e) {
            Log.e(TAG, "Error enabling module", e);
            return new PluginResult(PluginResult.STATUS_ERROR, "Error: " + e.getMessage());
        }
    }

    // 禁用模块
    private static PluginResult disableModule(Bundle inputBundle) {
        String moduleId = inputBundle.getString("module_id");
        if (moduleId == null) {
            return new PluginResult(PluginResult.STATUS_ERROR, "Module ID is required");
        }

        try {
            // 执行禁用模块的命令
            Process process = Runtime.getRuntime().exec("su -c touch /data/adb/modules/" + moduleId + "/disable");
            process.waitFor();
            int exitCode = process.exitValue();

            if (exitCode == 0) {
                return new PluginResult(PluginResult.STATUS_OK, "Module disabled: " + moduleId);
            } else {
                return new PluginResult(PluginResult.STATUS_ERROR, "Failed to disable module");
            }
        } catch (Exception e) {
            Log.e(TAG, "Error disabling module", e);
            return new PluginResult(PluginResult.STATUS_ERROR, "Error: " + e.getMessage());
        }
    }

    // 重启 Magisk
    private static PluginResult restartMagisk() {
        try {
            // 执行重启 Magisk 的命令
            Process process = Runtime.getRuntime().exec("su -c magisk --restart");
            process.waitFor();
            int exitCode = process.exitValue();

            if (exitCode == 0) {
                return new PluginResult(PluginResult.STATUS_OK, "Magisk restarted");
            } else {
                return new PluginResult(PluginResult.STATUS_ERROR, "Failed to restart Magisk");
            }
        } catch (Exception e) {
            Log.e(TAG, "Error restarting Magisk", e);
            return new PluginResult(PluginResult.STATUS_ERROR, "Error: " + e.getMessage());
        }
    }

    // 获取模块状态
    private static PluginResult getModuleStatus(Bundle inputBundle) {
        String moduleId = inputBundle.getString("module_id");
        if (moduleId == null) {
            return new PluginResult(PluginResult.STATUS_ERROR, "Module ID is required");
        }

        try {
            // 检查模块是否被禁用
            Process process = Runtime.getRuntime().exec("su -c ls /data/adb/modules/" + moduleId + "/disable");
            process.waitFor();
            int exitCode = process.exitValue();

            String status = exitCode == 0 ? "disabled" : "enabled";
            return new PluginResult(PluginResult.STATUS_OK, "Module status: " + status);
        } catch (Exception e) {
            Log.e(TAG, "Error getting module status", e);
            return new PluginResult(PluginResult.STATUS_ERROR, "Error: " + e.getMessage());
        }
    }

    // 安装模块
    private static PluginResult installModule(Bundle inputBundle) {
        String modulePath = inputBundle.getString("module_path");
        if (modulePath == null) {
            return new PluginResult(PluginResult.STATUS_ERROR, "Module path is required");
        }

        try {
            // 执行安装模块的命令
            Process process = Runtime.getRuntime().exec("su -c magisk --install-module " + modulePath);
            process.waitFor();
            int exitCode = process.exitValue();

            if (exitCode == 0) {
                return new PluginResult(PluginResult.STATUS_OK, "Module installed: " + modulePath);
            } else {
                return new PluginResult(PluginResult.STATUS_ERROR, "Failed to install module");
            }
        } catch (Exception e) {
            Log.e(TAG, "Error installing module", e);
            return new PluginResult(PluginResult.STATUS_ERROR, "Error: " + e.getMessage());
        }
    }
}
