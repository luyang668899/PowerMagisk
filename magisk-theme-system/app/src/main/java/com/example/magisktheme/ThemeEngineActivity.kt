package com.example.magisktheme

import android.os.Bundle
import android.view.View
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.Spinner
import android.widget.Switch
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.jaredrummler.android.shell.Shell
import java.io.File

class ThemeEngineActivity : AppCompatActivity() {

    private lateinit var themeSpinner: Spinner
    private lateinit var darkModeSwitch: Switch
    private lateinit var autoThemeSwitch: Switch
    private lateinit var statusTextView: TextView

    private val themes = listOf(
        "Default",
        "Dark",
        "Light",
        "AMOLED",
        "Material Blue",
        "Material Green",
        "Material Red"
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_theme_engine)

        themeSpinner = findViewById(R.id.theme_spinner)
        darkModeSwitch = findViewById(R.id.dark_mode_switch)
        autoThemeSwitch = findViewById(R.id.auto_theme_switch)
        statusTextView = findViewById(R.id.status)

        setupThemeSpinner()
        setupSwitches()
        loadCurrentTheme()
    }

    private fun setupThemeSpinner() {
        val adapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, themes)
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        themeSpinner.adapter = adapter

        themeSpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>, view: View?, position: Int, id: Long) {
                val selectedTheme = themes[position]
                applyTheme(selectedTheme)
            }

            override fun onNothingSelected(parent: AdapterView<*>) {
            }
        }
    }

    private fun setupSwitches() {
        darkModeSwitch.setOnCheckedChangeListener {
            _, isChecked ->
            if (isChecked) {
                applyTheme("Dark")
            } else {
                applyTheme("Light")
            }
        }

        autoThemeSwitch.setOnCheckedChangeListener {
            _, isChecked ->
            if (isChecked) {
                enableAutoTheme()
            } else {
                disableAutoTheme()
            }
        }
    }

    private fun loadCurrentTheme() {
        // 从配置文件加载当前主题
        val themeConfig = File("/data/adb/modules/magisk-theme/system/etc/magisk/theme.xml")
        if (themeConfig.exists()) {
            themeConfig.forEachLine { line ->
                if (line.contains("<theme>") && line.contains("</theme>")) {
                    val themeName = line.substringAfter("<theme>").substringBefore("</theme>")
                    val position = themes.indexOf(themeName)
                    if (position != -1) {
                        themeSpinner.setSelection(position)
                    }
                }
            }
        }
    }

    private fun applyTheme(themeName: String) {
        statusTextView.text = "Applying theme: $themeName"

        // 创建主题配置文件
        val themeDir = File("/data/adb/modules/magisk-theme/system/etc/magisk")
        if (!themeDir.exists()) {
            themeDir.mkdirs()
        }

        val themeConfig = File(themeDir, "theme.xml")
        themeConfig.writeText("""
            <?xml version="1.0" encoding="utf-8"?>
            <theme_config>
                <theme>$themeName</theme>
                <dark_mode>${darkModeSwitch.isChecked}</dark_mode>
                <auto_theme>${autoThemeSwitch.isChecked}</auto_theme>
            </theme_config>
        """.trimIndent())

        // 应用主题
        val result = Shell.su("chmod 644 ${themeConfig.absolutePath}")
        if (result.isSuccess) {
            statusTextView.text = "Theme applied successfully!"
            Toast.makeText(this, "Theme applied: $themeName", Toast.LENGTH_SHORT).show()
        } else {
            statusTextView.text = "Failed to apply theme"
            Toast.makeText(this, "Failed to apply theme", Toast.LENGTH_SHORT).show()
        }
    }

    private fun enableAutoTheme() {
        statusTextView.text = "Enabling auto theme"

        // 创建自动主题脚本
        val autoThemeScript = File("/data/adb/modules/magisk-theme/service.sh")
        autoThemeScript.writeText("""
            #!/system/bin/sh
            # Auto theme switcher
            
            while true; do
                # Get current hour
                hour=$(date +%H)
                
                # Switch theme based on time
                if [ $hour -ge 18 ] || [ $hour -lt 6 ]; then
                    # Night mode
                    echo '<theme>Dark</theme>' > /data/adb/modules/magisk-theme/system/etc/magisk/theme.xml
                else
                    # Day mode
                    echo '<theme>Light</theme>' > /data/adb/modules/magisk-theme/system/etc/magisk/theme.xml
                fi
                
                # Sleep for 1 hour
                sleep 3600
            done
        """.trimIndent())
        autoThemeScript.setExecutable(true)

        statusTextView.text = "Auto theme enabled"
        Toast.makeText(this, "Auto theme enabled", Toast.LENGTH_SHORT).show()
    }

    private fun disableAutoTheme() {
        statusTextView.text = "Disabling auto theme"

        // 移除自动主题脚本
        val autoThemeScript = File("/data/adb/modules/magisk-theme/service.sh")
        if (autoThemeScript.exists()) {
            autoThemeScript.delete()
        }

        statusTextView.text = "Auto theme disabled"
        Toast.makeText(this, "Auto theme disabled", Toast.LENGTH_SHORT).show()
    }
}