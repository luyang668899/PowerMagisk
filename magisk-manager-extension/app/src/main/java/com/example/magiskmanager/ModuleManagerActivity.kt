package com.example.magiskmanager

import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.floatingactionbutton.FloatingActionButton
import java.io.File

class ModuleManagerActivity : AppCompatActivity() {

    private lateinit var recyclerView: RecyclerView
    private lateinit var adapter: ModuleAdapter
    private lateinit var modules: List<Module>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_module_manager)

        recyclerView = findViewById(R.id.module_recycler_view)
        recyclerView.layoutManager = LinearLayoutManager(this)

        loadModules()

        val fab: FloatingActionButton = findViewById(R.id.fab)
        fab.setOnClickListener {
            // 打开模块安装界面
            Toast.makeText(this, "Install module", Toast.LENGTH_SHORT).show()
        }
    }

    private fun loadModules() {
        // 从 /data/adb/modules 目录加载模块
        val modulesDir = File("/data/adb/modules")
        if (modulesDir.exists() && modulesDir.isDirectory) {
            modules = modulesDir.listFiles()?.filter { it.isDirectory }?.map { moduleDir ->
                val module = Module()
                module.id = moduleDir.name
                module.name = readModuleProp(moduleDir, "name", module.id)
                module.version = readModuleProp(moduleDir, "version", "Unknown")
                module.author = readModuleProp(moduleDir, "author", "Unknown")
                module.description = readModuleProp(moduleDir, "description", "No description")
                module.enabled = File(moduleDir, "disable").exists().not()
                module
            } ?: emptyList()
        } else {
            modules = emptyList()
        }

        adapter = ModuleAdapter(modules) {
            // 处理模块点击事件
            Toast.makeText(this, "Module clicked: ${it.name}", Toast.LENGTH_SHORT).show()
        }
        recyclerView.adapter = adapter
    }

    private fun readModuleProp(moduleDir: File, key: String, defaultValue: String): String {
        val moduleProp = File(moduleDir, "module.prop")
        if (moduleProp.exists()) {
            moduleProp.forEachLine { line ->
                if (line.startsWith("$key=")) {
                    return line.substringAfter("$key=").trim()
                }
            }
        }
        return defaultValue
    }

    data class Module(
        var id: String = "",
        var name: String = "",
        var version: String = "",
        var author: String = "",
        var description: String = "",
        var enabled: Boolean = true
    )

    class ModuleAdapter(
        private val modules: List<Module>,
        private val onModuleClick: (Module) -> Unit
    ) : RecyclerView.Adapter<ModuleAdapter.ModuleViewHolder>() {

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ModuleViewHolder {
            val view = View.inflate(parent.context, R.layout.item_module, null)
            return ModuleViewHolder(view)
        }

        override fun onBindViewHolder(holder: ModuleViewHolder, position: Int) {
            val module = modules[position]
            holder.bind(module)
            holder.itemView.setOnClickListener {
                onModuleClick(module)
            }
        }

        override fun getItemCount(): Int = modules.size

        class ModuleViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
            fun bind(module: Module) {
                // 绑定模块数据到视图
            }
        }
    }
}