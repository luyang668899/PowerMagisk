package com.example.magisktheme

import android.content.Intent
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore
import android.view.View
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.Button
import android.widget.ImageView
import android.widget.Spinner
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.jaredrummler.android.shell.Shell
import java.io.File
import java.io.FileOutputStream

class IconCustomizerActivity : AppCompatActivity() {

    private lateinit var appSpinner: Spinner
    private lateinit var iconPackSpinner: Spinner
    private lateinit var currentIconImageView: ImageView
    private lateinit var selectIconButton: Button
    private lateinit var applyIconButton: Button
    private lateinit var statusTextView: TextView

    private val apps = listOf(
        "com.android.settings",
        "com.android.phone",
        "com.android.mms",
        "com.android.chrome",
        "com.google.android.youtube",
        "com.facebook.katana",
        "com.instagram.android"
    )

    private val iconPacks = listOf(
        "Default",
        "Pixel Icon Pack",
        "Material Icon Pack",
        "iOS Icon Pack",
        "Custom Icons"
    )

    private val REQUEST_PICK_ICON = 1
    private var selectedIconUri: Uri? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_icon_customizer)

        appSpinner = findViewById(R.id.app_spinner)
        iconPackSpinner = findViewById(R.id.icon_pack_spinner)
        currentIconImageView = findViewById(R.id.current_icon)
        selectIconButton = findViewById(R.id.select_icon_button)
        applyIconButton = findViewById(R.id.apply_icon_button)
        statusTextView = findViewById(R.id.status)

        setupSpinners()
        setupButtons()
    }

    private fun setupSpinners() {
        // 应用选择 spinner
        val appAdapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, apps)
        appAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        appSpinner.adapter = appAdapter

        appSpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>, view: View?, position: Int, id: Long) {
                val selectedApp = apps[position]
                loadCurrentIcon(selectedApp)
            }

            override fun onNothingSelected(parent: AdapterView<*>) {
            }
        }

        // 图标包选择 spinner
        val iconPackAdapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, iconPacks)
        iconPackAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        iconPackSpinner.adapter = iconPackAdapter

        iconPackSpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>, view: View?, position: Int, id: Long) {
                val selectedIconPack = iconPacks[position]
                if (selectedIconPack != "Custom Icons") {
                    applyIconPack(selectedIconPack)
                }
            }

            override fun onNothingSelected(parent: AdapterView<*>) {
            }
        }
    }

    private fun setupButtons() {
        selectIconButton.setOnClickListener {
            val intent = Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI)
            startActivityForResult(intent, REQUEST_PICK_ICON)
        }

        applyIconButton.setOnClickListener {
            val selectedApp = apps[appSpinner.selectedItemPosition]
            applyCustomIcon(selectedApp)
        }
    }

    private fun loadCurrentIcon(appPackage: String) {
        try {
            val packageManager = packageManager
            val applicationInfo = packageManager.getApplicationInfo(appPackage, 0)
            val icon = packageManager.getApplicationIcon(applicationInfo)
            currentIconImageView.setImageDrawable(icon)
        } catch (e: Exception) {
            currentIconImageView.setImageResource(R.mipmap.ic_launcher)
        }
    }

    private fun applyIconPack(iconPackName: String) {
        statusTextView.text = "Applying icon pack: $iconPackName"

        // 创建图标包目录
        val iconPackDir = File("/data/adb/modules/magisk-theme/system/priv-app")
        if (!iconPackDir.exists()) {
            iconPackDir.mkdirs()
        }

        // 这里应该根据选择的图标包复制相应的图标文件
        // 简化实现，仅做示例
        val result = Shell.su("touch ${iconPackDir.absolutePath}/.icon_pack_$iconPackName")
        if (result.isSuccess) {
            statusTextView.text = "Icon pack applied successfully!"
            Toast.makeText(this, "Icon pack applied: $iconPackName", Toast.LENGTH_SHORT).show()
        } else {
            statusTextView.text = "Failed to apply icon pack"
            Toast.makeText(this, "Failed to apply icon pack", Toast.LENGTH_SHORT).show()
        }
    }

    private fun applyCustomIcon(appPackage: String) {
        if (selectedIconUri == null) {
            Toast.makeText(this, "Please select an icon first", Toast.LENGTH_SHORT).show()
            return
        }

        statusTextView.text = "Applying custom icon for: $appPackage"

        try {
            // 获取选中的图标
            val bitmap = MediaStore.Images.Media.getBitmap(contentResolver, selectedIconUri)

            // 创建应用图标目录
            val appIconDir = File("/data/adb/modules/magisk-theme/system/priv-app/$appPackage")
            if (!appIconDir.exists()) {
                appIconDir.mkdirs()
            }

            // 保存图标文件
            val iconFile = File(appIconDir, "icon.png")
            val outputStream = FileOutputStream(iconFile)
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
            outputStream.close()

            // 设置权限
            val result = Shell.su("chmod 644 ${iconFile.absolutePath}")
            if (result.isSuccess) {
                statusTextView.text = "Custom icon applied successfully!"
                Toast.makeText(this, "Custom icon applied for: $appPackage", Toast.LENGTH_SHORT).show()
                // 更新当前显示的图标
                currentIconImageView.setImageBitmap(bitmap)
            } else {
                statusTextView.text = "Failed to apply custom icon"
                Toast.makeText(this, "Failed to apply custom icon", Toast.LENGTH_SHORT).show()
            }
        } catch (e: Exception) {
            statusTextView.text = "Error applying custom icon"
            Toast.makeText(this, "Error applying custom icon", Toast.LENGTH_SHORT).show()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_PICK_ICON && resultCode == RESULT_OK && data != null) {
            selectedIconUri = data.data
            if (selectedIconUri != null) {
                currentIconImageView.setImageURI(selectedIconUri)
                Toast.makeText(this, "Icon selected", Toast.LENGTH_SHORT).show()
            }
        }
    }
}