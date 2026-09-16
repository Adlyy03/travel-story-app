package com.example.travel_story

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.util.Log
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class LiveTripWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            try {
                val views = RemoteViews(context.packageName, R.layout.live_trip_widget).apply {
                    val isTracking = widgetData.getBoolean("is_tracking", false)
                    val duration = widgetData.getString("duration", "--:--") ?: "--:--"
                    val distance = widgetData.getString("distance", "0.0 km") ?: "0.0 km"
                    val location = widgetData.getString("location", "Lokasi: Tidak aktif") ?: "Lokasi: Tidak aktif"
                    val statusText = widgetData.getString(
                        "status_text",
                        if (isTracking) "PERJALANAN AKTIF" else "TIDAK AKTIF"
                    ) ?: "TIDAK AKTIF"

                    setTextViewText(R.id.widget_status, statusText)
                    setTextViewText(R.id.widget_duration, duration)
                    setTextViewText(R.id.widget_distance, distance)
                    setTextViewText(R.id.widget_location, location)

                    if (statusText == "ISTIRAHAT") {
                        setTextColor(R.id.widget_status, Color.parseColor("#F59E0B"))
                    } else if (isTracking) {
                        setTextColor(R.id.widget_status, Color.parseColor("#10B981"))
                    } else {
                        setTextColor(R.id.widget_status, Color.parseColor("#64748B"))
                    }

                    // Tap widget -> open MainActivity
                    val intent = Intent(context, MainActivity::class.java).apply {
                        action = Intent.ACTION_VIEW
                        data = Uri.parse("travelstory://livetrip")
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                        putExtra("open_live_trip", true)
                    }
                    val pendingIntent = PendingIntent.getActivity(
                        context,
                        0,
                        intent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    setOnClickPendingIntent(R.id.widget_container, pendingIntent)
                }
                appWidgetManager.updateAppWidget(widgetId, views)
            } catch (e: Exception) {
                Log.e("LiveTripWidgetProvider", "Error updating widget: ${e.message}", e)
            }
        }
    }
}
