package com.example.magiskmanager

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.jaredrummler.android.shell.Shell
import java.io.File
import java.io.FileOutputStream

class ModulePackagerActivity : AppCompatActivity() {

    private lateinit var moduleIdEditText: EditText
    private lateinit var moduleNameEditText: EditText
    private lateinit var moduleVersionEditText: EditText
    private lateinit var moduleAuthorEditText: EditText
    private lateinit var moduleDescriptionEditText: EditText
    private lateinit var createModuleButton: Button
    private lateinit var statusTextView: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_module_packager)

        moduleIdEditText = findViewById(R.id.module_id)
        moduleNameEditText = findViewById(R.id.module_name)
        moduleVersionEditText = findViewById(R.id.module_version)
        moduleAuthorEditText = findViewById(R.id.module_author)
        moduleDescriptionEditText = findViewById(R.id.module_description)
        createModuleButton = findViewById(R.id.create_module)
        statusTextView = findViewById(R.id.status)

        createModuleButton.setOnClickListener {
            createModule()
        }
    }

    private fun createModule() {
        val moduleId = moduleIdEditText.text.toString().trim()
        val moduleName = moduleNameEditText.text.toString().trim()
        val moduleVersion = moduleVersionEditText.text.toString().trim()
        val moduleAuthor = moduleAuthorEditText.text.toString().trim()
        val moduleDescription = moduleDescriptionEditText.text.toString().trim()

        if (moduleId.isEmpty() || moduleName.isEmpty()) {
            Toast.makeText(this, "Module ID and Name are required", Toast.LENGTH_SHORT).show()
            return
        }

        statusTextView.text = "Creating module..."

        // 创建模块目录结构
        val moduleDir = File(filesDir, moduleId)
        if (moduleDir.exists()) {
            moduleDir.deleteRecursively()
        }
        moduleDir.mkdirs()

        // 创建必要的子目录
        val systemDir = File(moduleDir, "system")
        systemDir.mkdirs()

        val commonDir = File(moduleDir, "common")
        commonDir.mkdirs()

        // 创建 module.prop 文件
        val moduleProp = File(moduleDir, "module.prop")
        moduleProp.writeText("""
            id=$moduleId
            name=$moduleName
            version=$moduleVersion
            versionCode=1
            author=$moduleAuthor
            description=$moduleDescription
        """.trimIndent())

        // 创建 post-fs-data.sh 文件
        val postFsData = File(moduleDir, "post-fs-data.sh")
        postFsData.writeText("""
            #!/system/bin/sh
            # This script will be executed in post-fs-data mode
            
            # Set permissions
            set_perm_recursive \$MODPATH/system 0 0 0755 0644
        """.trimIndent())
        postFsData.setExecutable(true)

        // 创建 service.sh 文件
        val serviceSh = File(moduleDir, "service.sh")
        serviceSh.writeText("""
            #!/system/bin/sh
            # This script will be executed in late_start service mode
        """.trimIndent())
        serviceSh.setExecutable(true)

        // 创建 uninstall.sh 文件
        val uninstallSh = File(moduleDir, "uninstall.sh")
        uninstallSh.writeText("""
            #!/system/bin/sh
            # This script will be executed when the module is uninstalled
            
            # Remove module files
            rm -rf \$MODPATH
        """.trimIndent())
        uninstallSh.setExecutable(true)

        // 打包为 zip 文件
        val zipFile = File(filesDir, "$moduleId.zip")
        if (zipFile.exists()) {
            zipFile.delete()
        }

        // 使用 zip 命令打包
        val result = Shell.su("cd ${moduleDir.parent} && zip -r ${zipFile.name} ${moduleDir.name}")
        if (result.isSuccess) {
            statusTextView.text = "Module created successfully!"
            Toast.makeText(this, "Module created: ${zipFile.absolutePath}", Toast.LENGTH_SHORT).show()
            
            // 分享模块
            shareModule(zipFile)
        } else {
            statusTextView.text = "Failed to create module: ${result.stderr}"
            Toast.makeText(this, "Failed to create module", Toast.LENGTH_SHORT).show()
        }
    }

    private fun shareModule(zipFile: File) {
        val intent = Intent(Intent.ACTION_SEND)
        intent.type = "application/zip"
        intent.putExtra(Intent.EXTRA_STREAM, Uri.fromFile(zipFile))
        intent.putExtra(Intent.EXTRA_SUBJECT, "Magisk Module: ${zipFile.name}")
        intent.putExtra(Intent.EXTRA_TEXT, "Created with Magisk Module Packager")
        startActivity(Intent.createChooser(intent, "Share module"))
    }
}