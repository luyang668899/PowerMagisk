package com.example.magisktheme

import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.squareup.picasso.Picasso
import com.jaredrummler.android.shell.Shell
import java.io.File
import java.io.FileOutputStream
import java.net.URL

class ThemeStoreActivity : AppCompatActivity() {

    private lateinit var recyclerView: RecyclerView
    private lateinit var adapter: ThemeAdapter
    private lateinit var themes: List<Theme>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_theme_store)

        recyclerView = findViewById(R.id.theme_recycler_view)
        recyclerView.layoutManager = LinearLayoutManager(this)

        loadThemes()
    }

    private fun loadThemes() {
        // 模拟主题列表
        themes = listOf(
            Theme(1, "Material Blue", "A clean blue material theme", "https://example.com/themes/material_blue.png", "https://example.com/themes/material_blue.zip"),
            Theme(2, "Material Green", "A fresh green material theme", "https://example.com/themes/material_green.png", "https://example.com/themes/material_green.zip"),
            Theme(3, "Material Red", "A vibrant red material theme", "https://example.com/themes/material_red.png", "https://example.com/themes/material_red.zip"),
            Theme(4, "AMOLED Dark", "A pure black AMOLED theme", "https://example.com/themes/amoled_dark.png", "https://example.com/themes/amoled_dark.zip"),
            Theme(5, "Pastel Pink", "A soft pastel pink theme", "https://example.com/themes/pastel_pink.png", "https://example.com/themes/pastel_pink.zip")
        )

        adapter = ThemeAdapter(themes) {
            downloadTheme(it)
        }
        recyclerView.adapter = adapter
    }

    private fun downloadTheme(theme: Theme) {
        Toast.makeText(this, "Downloading theme: ${theme.name}", Toast.LENGTH_SHORT).show()

        // 在实际应用中，这里应该使用后台线程下载
        Thread {
            try {
                val url = URL(theme.downloadUrl)
                val connection = url.openConnection()
                connection.connect()

                val inputStream = connection.inputStream
                val outputFile = File(filesDir, "${theme.id}.zip")
                val outputStream = FileOutputStream(outputFile)

                val buffer = ByteArray(1024)
                var bytesRead: Int
                while (inputStream.read(buffer).also { bytesRead = it } != -1) {
                    outputStream.write(buffer, 0, bytesRead)
                }

                outputStream.close()
                inputStream.close()

                // 安装主题
                runOnUiThread {
                    installTheme(outputFile, theme)
                }
            } catch (e: Exception) {
                runOnUiThread {
                    Toast.makeText(this, "Failed to download theme", Toast.LENGTH_SHORT).show()
                }
            }
        }.start()
    }

    private fun installTheme(zipFile: File, theme: Theme) {
        // 创建主题模块目录
        val themeModuleDir = File("/data/adb/modules/magisk-theme")
        if (!themeModuleDir.exists()) {
            themeModuleDir.mkdirs()
        }

        // 解压主题文件
        val result = Shell.su("unzip ${zipFile.absolutePath} -d ${themeModuleDir.absolutePath}")
        if (result.isSuccess) {
            Toast.makeText(this, "Theme installed successfully: ${theme.name}", Toast.LENGTH_SHORT).show()
        } else {
            Toast.makeText(this, "Failed to install theme", Toast.LENGTH_SHORT).show()
        }
    }

    data class Theme(
        val id: Int,
        val name: String,
        val description: String,
        val previewUrl: String,
        val downloadUrl: String
    )

    class ThemeAdapter(
        private val themes: List<Theme>,
        private val onThemeClick: (Theme) -> Unit
    ) : RecyclerView.Adapter<ThemeAdapter.ThemeViewHolder>() {

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ThemeViewHolder {
            val view = View.inflate(parent.context, R.layout.item_theme, null)
            return ThemeViewHolder(view)
        }

        override fun onBindViewHolder(holder: ThemeViewHolder, position: Int) {
            val theme = themes[position]
            holder.bind(theme)
            holder.itemView.setOnClickListener {
                onThemeClick(theme)
            }
        }

        override fun getItemCount(): Int = themes.size

        class ThemeViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
            private val nameTextView: TextView = itemView.findViewById(R.id.theme_name)
            private val descriptionTextView: TextView = itemView.findViewById(R.id.theme_description)
            private val previewImageView: ImageView = itemView.findViewById(R.id.theme_preview)
            private val downloadButton: Button = itemView.findViewById(R.id.download_button)

            fun bind(theme: Theme) {
                nameTextView.text = theme.name
                descriptionTextView.text = theme.description
                Picasso.get().load(theme.previewUrl).into(previewImageView)
                downloadButton.setOnClickListener {
                    // 触发下载
                }
            }
        }
    }
}