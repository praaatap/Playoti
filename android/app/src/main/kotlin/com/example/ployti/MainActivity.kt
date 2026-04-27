package com.example.ployti

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.ployti/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "updateWidget" -> {
                        val data = call.argument<String>("data") ?: "[]"
                        writeWidgetData(data)
                        refreshAllWidgets()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun writeWidgetData(json: String) {
        try {
            val file = File(filesDir, "ployti_widget_data.json")
            file.writeText(json)
        } catch (e: Exception) {
            // ignore
        }
    }

    private fun refreshAllWidgets() {
        val manager = AppWidgetManager.getInstance(this)
        val ids = manager.getAppWidgetIds(
            ComponentName(this, PloytiWidgetProvider::class.java)
        )
        for (id in ids) {
            PloytiWidgetProvider.updateWidget(this, manager, id)
        }
    }
}
