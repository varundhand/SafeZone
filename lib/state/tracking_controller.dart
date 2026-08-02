import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/activity_event.dart';
import '../models/geofence.dart';
import '../models/location_fix.dart';
import '../services/firebase_telemetry_service.dart';
import '../services/geofence_math.dart';
import '../services/location_channel_service.dart';
import '../services/mock_location_service.dart';
import 'geofence_provider.dart';
import 'safety_settings_provider.dart';
import 'tracking_state.dart';

/// Single source of truth for live tracking. Owns the (real or mocked)
/// location/activity stream subscription, evaluates geofence containment
/// with the ray-casting algorithm, derives the walking-only + in-vehicle
/// alert condition (Feature 2), and forwards telemetry to Firebase.
class TrackingController extends StateNotifier<TrackingState> {
  TrackingController(this._ref) : super(const TrackingState());

  final Ref _ref;
  StreamSubscription<dynamic>? _subscription;

  Future<void> setDevMode(bool enabled) async {
    if (state.devMode == enabled) return;
    final wasTracking = state.isTracking;
    if (wasTracking) await _stopCurrentSource();

    state = state.copyWith(devMode: enabled);

    if (wasTracking) await _startCurrentSource();
  }

  Future<bool> startTracking() async {
    if (state.isTracking) return true;

    if (!state.devMode) {
      final granted = await LocationChannelService.instance.requestPermissions();
      if (!granted) return false;
    }

    await _startCurrentSource();
    state = state.copyWith(isTracking: true);
    return true;
  }

  Future<void> stopTracking() async {
    if (!state.isTracking) return;
    await _stopCurrentSource();
    state = state.copyWith(isTracking: false);
  }

  Future<void> _startCurrentSource() async {
    if (state.devMode) {
      _subscription = MockLocationService.instance.start().listen(_handleFix);
    } else {
      await LocationChannelService.instance.startService();
      _subscription = LocationChannelService.instance.events.listen(_handleEvent);
    }
  }

  Future<void> _stopCurrentSource() async {
    await _subscription?.cancel();
    _subscription = null;
    if (state.devMode) {
      MockLocationService.instance.stop();
    } else {
      await LocationChannelService.instance.stopService();
    }
  }

  void _handleEvent(Map<dynamic, dynamic> event) {
    switch (event['type']) {
      case 'location':
        _handleFix(LocationFix.fromMap(event));
        break;
      case 'activity':
        _handleActivity(ActivityEvent.fromMap(event));
        break;
    }
  }

  void _handleFix(LocationFix fix) {
    final geofences = _ref.read(geofenceListProvider);
    final insideIds = <String>{
      for (final g in geofences)
        if (isPointInPolygon(fix.latLng, g.vertices)) g.id,
    };

    final alertGeofence = state.currentActivity == TransitMode.inVehicle
        ? _firstWalkingOnlyMatch(geofences, insideIds)
        : null;

    final history = [fix, ...state.history];
    if (history.length > TrackingState.maxHistoryLength) {
      history.removeRange(TrackingState.maxHistoryLength, history.length);
    }

    state = state.copyWith(
      currentFix: fix,
      insideGeofenceIds: insideIds,
      triggeredAlertGeofence: alertGeofence,
      clearAlert: alertGeofence == null,
      history: history,
    );

    FirebaseTelemetryService.instance.pushIfMoved(fix);
  }

  void _handleActivity(ActivityEvent event) {
    if (!event.isEnter) return;

    final geofences = _ref.read(geofenceListProvider);
    final alertGeofence = event.mode == TransitMode.inVehicle
        ? _firstWalkingOnlyMatch(geofences, state.insideGeofenceIds)
        : null;

    state = state.copyWith(
      currentActivity: event.mode,
      triggeredAlertGeofence: alertGeofence,
      clearAlert: alertGeofence == null,
    );
  }

  Geofence? _firstWalkingOnlyMatch(List<Geofence> geofences, Set<String> insideIds) {
    if (!_ref.read(transitAlertsEnabledProvider)) return null;
    for (final g in geofences) {
      if (g.type == GeofenceType.walkingOnly && insideIds.contains(g.id)) {
        return g;
      }
    }
    return null;
  }

  void dismissAlert() {
    state = state.copyWith(clearAlert: true);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final trackingControllerProvider =
    StateNotifierProvider<TrackingController, TrackingState>(
  (ref) => TrackingController(ref),
);
