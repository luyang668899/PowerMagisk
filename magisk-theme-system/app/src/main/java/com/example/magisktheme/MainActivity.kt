package com.example.magisktheme

import android.content.Intent
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import androidx.appcompat.app.AppCompatActivity
import com.google.android.material.bottomnavigation.BottomNavigationView

class MainActivity : AppCompatActivity() {

    private lateinit var bottomNavigationView: BottomNavigationView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        bottomNavigationView = findViewById(R.id.bottom_navigation)
        bottomNavigationView.setOnNavigationItemSelectedListener {
            when (it.itemId) {
                R.id.nav_theme_engine -> {
                    startActivity(Intent(this, ThemeEngineActivity::class.java))
                    true
                }
                R.id.nav_theme_store -> {
                    startActivity(Intent(this, ThemeStoreActivity::class.java))
                    true
                }
                R.id.nav_icon_customizer -> {
                    startActivity(Intent(this, IconCustomizerActivity::class.java))
                    true
                }
                else -> false
            }
        }
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.main_menu, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        when (item.itemId) {
            R.id.action_settings -> {
                // 打开设置页面
                true
            }
            R.id.action_about -> {
                // 打开关于页面
                true
            }
            else -> return super.onOptionsItemSelected(item)
        }
        return true
    }
}