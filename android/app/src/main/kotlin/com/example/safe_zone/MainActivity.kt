package com.example.safe_zone

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val methodChannelName = "com.csis4280/geofence"
    private val eventChannelName = "com.csis4280/geofence/events"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startService" -> {
                        startLocationService()
                        result.success(null)
                    }
                    "stopService" -> {
                        stopLocationService()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, eventChannelName)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    LocationService.locationUpdateListener = { telemetry ->
                        runOnUiThread { events?.success(telemetry) }
                    }
                    LocationService.activityUpdateListener = { activityType, transitionType ->
                        runOnUiThread {
                            events?.success(
                                mapOf(
                                    "type" to "activity",
                                    "activity" to activityType,
                                    "transition" to transitionType
                                )
                            )
                        }
                    }
                }

                override fun onCancel(arguments: Any?) {
                    LocationService.locationUpdateListener = null
                    LocationService.activityUpdateListener = null
                }
            })
    }

    private fun startLocationService() {
        val intent = Intent(this, LocationService::class.java).apply {
            action = LocationService.ACTION_START
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun stopLocationService() {
        val intent = Intent(this, LocationService::class.java).apply {
            action = LocationService.ACTION_STOP
        }
        startService(intent)
    }
}
