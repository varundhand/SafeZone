package com.example.safe_zone

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.google.android.gms.location.ActivityTransition
import com.google.android.gms.location.ActivityTransitionResult
import com.google.android.gms.location.DetectedActivity

/**
 * Receives transit-mode transition events from ActivityRecognitionClient and
 * forwards them to whichever listener LocationService currently has registered
 * (wired to the Flutter EventChannel by MainActivity).
 */
class ActivityTransitionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (!ActivityTransitionResult.hasResult(intent)) return
        val result = ActivityTransitionResult.extractResult(intent) ?: return

        for (event in result.transitionEvents) {
            val activityName = activityTypeToString(event.activityType)
            val transitionName = if (event.transitionType == ActivityTransition.ACTIVITY_TRANSITION_ENTER) {
                "enter"
            } else {
                "exit"
            }
            LocationService.activityUpdateListener?.invoke(activityName, transitionName)
        }
    }

    companion object {
        fun activityTypeToString(type: Int): String = when (type) {
            DetectedActivity.IN_VEHICLE -> "in_vehicle"
            DetectedActivity.ON_BICYCLE -> "on_bicycle"
            DetectedActivity.RUNNING -> "running"
            DetectedActivity.WALKING -> "walking"
            DetectedActivity.STILL -> "still"
            else -> "unknown"
        }
    }
}
