package com.example.magiskmanager

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.jaredrummler.android.shell.Shell
import java.io.File

class SystemMonitorActivity : AppCompatActivity() {

    private lateinit var cpuUsageTextView: TextView
    private lateinit var memoryUsageTextView: TextView
    private lateinit var storageUsageTextView: TextView
    private lateinit var batteryLevelTextView: TextView
    private lateinit var temperatureTextView: TextView
    private lateinit var networkSpeedTextView: TextView

    private val handler = Handler(Looper.getMainLooper())
    private val updateInterval = 1000L // 1秒更新一次

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_system_monitor)

        cpuUsageTextView = findViewById(R.id.cpu_usage)
        memoryUsageTextView = findViewById(R.id.memory_usage)
        storageUsageTextView = findViewById(R.id.storage_usage)
        batteryLevelTextView = findViewById(R.id.battery_level)
        temperatureTextView = findViewById(R.id.temperature)
        networkSpeedTextView = findViewById(R.id.network_speed)

        startMonitoring()
    }

    private fun startMonitoring() {
        handler.post(object : Runnable {
            override fun run() {
                updateSystemStatus()
                handler.postDelayed(this, updateInterval)
            }
        })
    }

    private fun updateSystemStatus() {
        updateCpuUsage()
        updateMemoryUsage()
        updateStorageUsage()
        updateBatteryLevel()
        updateTemperature()
        updateNetworkSpeed()
    }

    private fun updateCpuUsage() {
        try {
            val result = Shell.su("top -n 1 | grep 'CPU'")
            if (result.isSuccess) {
                val output = result.output
                if (output.isNotEmpty()) {
                    cpuUsageTextView.text = "CPU: ${output[0]}"
                }
            }
        } catch (e: Exception) {
            cpuUsageTextView.text = "CPU: Error"
        }
    }

    private fun updateMemoryUsage() {
        try {
            val result = Shell.su("free -h")
            if (result.isSuccess) {
                val output = result.output
                if (output.size > 1) {
                    memoryUsageTextView.text = "Memory: ${output[1]}"
                }
            }
        } catch (e: Exception) {
            memoryUsageTextView.text = "Memory: Error"
        }
    }

    private fun updateStorageUsage() {
        try {
            val result = Shell.su("df -h")
            if (result.isSuccess) {
                val output = result.output
                if (output.isNotEmpty()) {
                    storageUsageTextView.text = "Storage: ${output[0]}"
                }
            }
        } catch (e: Exception) {
            storageUsageTextView.text = "Storage: Error"
        }
    }

    private fun updateBatteryLevel() {
        try {
            val result = Shell.su("cat /sys/class/power_supply/battery/capacity")
            if (result.isSuccess) {
                val output = result.output
                if (output.isNotEmpty()) {
                    batteryLevelTextView.text = "Battery: ${output[0]}%"
                }
            }
        } catch (e: Exception) {
            batteryLevelTextView.text = "Battery: Error"
        }
    }

    private fun updateTemperature() {
        try {
            val result = Shell.su("cat /sys/class/thermal/thermal_zone*/temp")
            if (result.isSuccess) {
                val output = result.output
                if (output.isNotEmpty()) {
                    val temp = output[0].toInt() / 1000.0
                    temperatureTextView.text = "Temperature: ${temp}°C"
                }
            }
        } catch (e: Exception) {
            temperatureTextView.text = "Temperature: Error"
        }
    }

    private fun updateNetworkSpeed() {
        try {
            val result = Shell.su("ifconfig wlan0 | grep 'RX bytes' | cut -d ' ' -f 2 | cut -d ':' -f 2")
            if (result.isSuccess) {
                val output = result.output
                if (output.isNotEmpty()) {
                    networkSpeedTextView.text = "Network: ${output[0]} bytes"
                }
            }
        } catch (e: Exception) {
            networkSpeedTextView.text = "Network: Error"
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacksAndMessages(null)
    }
}