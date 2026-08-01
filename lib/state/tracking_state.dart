import '../models/activity_event.dart';
import '../models/geofence.dart';
import '../models/location_fix.dart';

/// Everything the UI needs to react to, held in one immutable snapshot so
/// widgets can `ref.watch(...).select(...)` just the slice they care about
/// instead of rebuilding on every location tick.
class TrackingState {
  final LocationFix? currentFix;
  final TransitMode currentActivity;
  final Set<String> insideGeofenceIds;
  final Geofence? triggeredAlertGeofence;
  final bool isTracking;
  final bool devMode;

  const TrackingState({
    this.currentFix,
    this.currentActivity = TransitMode.unknown,
    this.insideGeofenceIds = const {},
    this.triggeredAlertGeofence,
    this.isTracking = false,
    this.devMode = false,
  });

  bool get hasActiveAlert => triggeredAlertGeofence != null;

  TrackingState copyWith({
    LocationFix? currentFix,
    TransitMode? currentActivity,
    Set<String>? insideGeofenceIds,
    Geofence? triggeredAlertGeofence,
    bool clearAlert = false,
    bool? isTracking,
    bool? devMode,
  }) {
    return TrackingState(
      currentFix: currentFix ?? this.currentFix,
      currentActivity: currentActivity ?? this.currentActivity,
      insideGeofenceIds: insideGeofenceIds ?? this.insideGeofenceIds,
      triggeredAlertGeofence:
          clearAlert ? null : (triggeredAlertGeofence ?? this.triggeredAlertGeofence),
      isTracking: isTracking ?? this.isTracking,
      devMode: devMode ?? this.devMode,
    );
  }
}
