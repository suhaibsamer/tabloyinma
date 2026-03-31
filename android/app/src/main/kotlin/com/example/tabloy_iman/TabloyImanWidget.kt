package com.example.tabloy_iman

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONObject
import org.json.JSONArray
import android.app.PendingIntent
import android.content.Intent
import java.text.SimpleDateFormat
import java.util.*

class TabloyImanWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.tabloy_iman_widget)

            // 1. Get Data from HomeWidget
            val prefs = try {
                HomeWidgetPlugin.getData(context)
            } catch (e: Exception) {
                null
            }
            
            // 2. Prayer Times
            val prayerTimesJson = prefs?.getString("prayer_times", null)
            if (!prayerTimesJson.isNullOrBlank()) {
                try {
                    val prayerMap = JSONObject(prayerTimesJson)
                    if (prayerMap.has("Fajr")) views.setTextViewText(R.id.time_fajr, "${prayerMap.optString("Fajr")}\nبەیانی")
                    if (prayerMap.has("Dhuhr")) views.setTextViewText(R.id.time_dhuhr, "${prayerMap.optString("Dhuhr")}\nنیوەڕۆ")
                    if (prayerMap.has("Asr")) views.setTextViewText(R.id.time_asr, "${prayerMap.optString("Asr")}\nعەسر")
                    if (prayerMap.has("Maghrib")) views.setTextViewText(R.id.time_maghrib, "${prayerMap.optString("Maghrib")}\nشێوان")
                    if (prayerMap.has("Isha")) views.setTextViewText(R.id.time_isha, "${prayerMap.optString("Isha")}\nخەوتنان")
                    
                    // Logic for next prayer countdown
                    updateNextPrayer(prayerMap, views)
                } catch (e: Exception) {
                    e.printStackTrace()
                    views.setTextViewText(R.id.next_prayer_countdown, "Error Parsing Data")
                }
            } else {
                views.setTextViewText(R.id.next_prayer_countdown, "Open app to sync")
                views.setTextViewText(R.id.next_prayer_name, "---")
            }

            // 3. Dua of the Hour (Rotation)
            val duaBatchJson = prefs?.getString("dua_batch", null)
            if (!duaBatchJson.isNullOrBlank()) {
                try {
                    val duaArray = JSONArray(duaBatchJson)
                    if (duaArray.length() > 0) {
                        // Pick one based on current hour to rotate
                        val hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
                        val index = hour % duaArray.length()
                        views.setTextViewText(R.id.dua_text, duaArray.optString(index, "دوعای کاتژمێر..."))
                    } else {
                        views.setTextViewText(R.id.dua_text, "No duas found")
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }

            // 4. Deep Link / Launch App
            try {
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                views.setOnClickPendingIntent(R.id.dua_section, pendingIntent)
                views.setOnClickPendingIntent(R.id.header, pendingIntent)
                views.setOnClickPendingIntent(R.id.countdown_section, pendingIntent)
            } catch (e: Exception) {
                e.printStackTrace()
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun updateNextPrayer(prayerMap: JSONObject, views: RemoteViews) {
        try {
            val now = Calendar.getInstance()
            val prayerNames = arrayOf("Fajr", "Dhuhr", "Asr", "Maghrib", "Isha")
            val kurdishNames = arrayOf("بەیانی", "نیوەڕۆ", "عەسر", "شێوان", "خەوتنان")
            
            var nextPrayerName = ""
            var nextPrayerTime: Calendar? = null

            for (i in prayerNames.indices) {
                if (!prayerMap.has(prayerNames[i])) continue
                
                val pTimeStr = prayerMap.optString(prayerNames[i])
                if (pTimeStr.isBlank()) continue
                
                val pTime = Calendar.getInstance()
                val timeParts = pTimeStr.split(":")
                if (timeParts.size < 2) continue
                
                try {
                    pTime.set(Calendar.HOUR_OF_DAY, timeParts[0].trim().toInt())
                    pTime.set(Calendar.MINUTE, timeParts[1].trim().toInt())
                    pTime.set(Calendar.SECOND, 0)
                    pTime.set(Calendar.MILLISECOND, 0)

                    if (pTime.after(now)) {
                        nextPrayerName = kurdishNames[i]
                        nextPrayerTime = pTime
                        break
                    }
                } catch (e: Exception) {
                    continue
                }
            }

            // If no more prayers today, next is Fajr tomorrow
            if (nextPrayerTime == null && prayerMap.has("Fajr")) {
                nextPrayerName = "بەیانی (بەیانی)"
                val pTimeStr = prayerMap.optString("Fajr")
                if (pTimeStr.isNotBlank()) {
                    val pTime = Calendar.getInstance()
                    val timeParts = pTimeStr.split(":")
                    if (timeParts.size >= 2) {
                        try {
                            pTime.add(Calendar.DAY_OF_YEAR, 1)
                            pTime.set(Calendar.HOUR_OF_DAY, timeParts[0].trim().toInt())
                            pTime.set(Calendar.MINUTE, timeParts[1].trim().toInt())
                            pTime.set(Calendar.SECOND, 0)
                            pTime.set(Calendar.MILLISECOND, 0)
                            nextPrayerTime = pTime
                        } catch (e: Exception) {}
                    }
                }
            }

            if (nextPrayerTime != null) {
                views.setTextViewText(R.id.next_prayer_name, nextPrayerName)
                
                val diff = nextPrayerTime.timeInMillis - now.timeInMillis
                val h = diff / (1000 * 60 * 60)
                val m = (diff / (1000 * 60)) % 60
                val s = (diff / 1000) % 60
                views.setTextViewText(R.id.next_prayer_countdown, String.format("%02d:%02d:%02d", h, m, s))
            } else {
                views.setTextViewText(R.id.next_prayer_name, "---")
                views.setTextViewText(R.id.next_prayer_countdown, "--:--:--")
            }
        } catch (e: Exception) {
            e.printStackTrace()
            views.setTextViewText(R.id.next_prayer_name, "Error")
        }
    }
}

