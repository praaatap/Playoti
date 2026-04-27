package com.example.ployti

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.text.format.DateFormat
import android.view.View
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.text.SimpleDateFormat
import java.util.*

class PloytiWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (id in appWidgetIds) {
            updateWidget(context, appWidgetManager, id)
        }
    }

    companion object {
        fun updateWidget(context: Context, appWidgetManager: AppWidgetManager, widgetId: Int) {
            val views = RemoteViews(context.packageName, R.layout.ployti_widget_layout)

            // Open app on tap
            val launchIntent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context, 0, launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            // Today's date label
            val today = Calendar.getInstance()
            val dateStr = DateFormat.format("EEE, MMM d", today).toString()
            views.setTextViewText(R.id.widget_date, dateStr)

            // Load today's tasks from Hive storage
            val todayTasks = loadTodayTasks(context)

            val taskIds = listOf(R.id.widget_task1, R.id.widget_task2, R.id.widget_task3)
            val activeCount = todayTasks.count { !it.optBoolean("isCompleted", false) }

            if (todayTasks.isEmpty()) {
                views.setViewVisibility(R.id.widget_empty, View.VISIBLE)
                views.setViewVisibility(R.id.widget_count, View.GONE)
                taskIds.forEach { views.setViewVisibility(it, View.GONE) }
                views.setViewVisibility(R.id.widget_more, View.GONE)
            } else {
                views.setViewVisibility(R.id.widget_empty, View.GONE)
                val countText = "$activeCount remaining"
                views.setTextViewText(R.id.widget_count, countText)
                views.setViewVisibility(R.id.widget_count, View.VISIBLE)

                val shown = todayTasks.take(3)
                shown.forEachIndexed { i, task ->
                    val completed = task.optBoolean("isCompleted", false)
                    val title = task.optString("title", "")
                    val prefix = if (completed) "✓  " else "·  "
                    views.setTextViewText(taskIds[i], "$prefix$title")
                    views.setViewVisibility(taskIds[i], View.VISIBLE)
                    views.setTextColor(
                        taskIds[i],
                        if (completed) 0xFFB2BEC3.toInt() else 0xFF1C1917.toInt()
                    )
                }
                // Hide unused rows
                for (i in shown.size until 3) {
                    views.setViewVisibility(taskIds[i], View.GONE)
                }
                if (todayTasks.size > 3) {
                    views.setTextViewText(R.id.widget_more, "+${todayTasks.size - 3} more")
                    views.setViewVisibility(R.id.widget_more, View.VISIBLE)
                } else {
                    views.setViewVisibility(R.id.widget_more, View.GONE)
                }
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }

        private fun loadTodayTasks(context: Context): List<JSONObject> {
            return try {
                // Hive stores box data in app's documents/hive directory
                val hiveDir = File(context.filesDir, "hive")
                val boxFile = File(hiveDir, "tasks.hive")
                if (!boxFile.exists()) return emptyList()

                // Read Flutter shared_preferences export if available (fallback)
                val widgetDataFile = File(context.filesDir, "ployti_widget_data.json")
                if (!widgetDataFile.exists()) return emptyList()

                val json = JSONArray(widgetDataFile.readText())
                val todayStr = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
                    .format(Date())

                val result = mutableListOf<JSONObject>()
                for (i in 0 until json.length()) {
                    val task = json.getJSONObject(i)
                    val dateStr = task.optString("date", "")
                    if (dateStr.startsWith(todayStr)) {
                        result.add(task)
                    }
                }
                result.sortBy { it.optInt("sortOrder", 0) }
                result
            } catch (e: Exception) {
                emptyList()
            }
        }
    }
}
