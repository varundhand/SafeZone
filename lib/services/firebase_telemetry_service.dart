import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart';

import '../models/location_fix.dart';
import 'geofence_math.dart';

/// Pushes telemetry (coordinates + battery + network) to Firebase Realtime
/// Database whenever the child's position moves more than 10 meters
/// (Step 3). Fails soft: if Firebase hasn't been configured with real project
/// credentials, [initialize] simply leaves the service unavailable and every
/// push becomes a no-op instead of crashing the app.
class FirebaseTelemetryService {
  FirebaseTelemetryService._();
  static final FirebaseTelemetryService instance = FirebaseTelemetryService._();

  static const _minDisplacementMeters = 10.0;

  DatabaseReference? _telemetryRef;
  LatLng? _lastPushedLocation;

  bool get isAvailable => _telemetryRef != null;

  void initialize({required String deviceId}) {
    try {
      _telemetryRef = FirebaseDatabase.instance.ref('telemetry/$deviceId');
    } catch (_) {
      _telemetryRef = null;
    }
  }

  Future<void> pushIfMoved(LocationFix fix) async {
    final ref = _telemetryRef;
    if (ref == null) return;

    final current = fix.latLng;
    final last = _lastPushedLocation;
    if (last != null && haversineMeters(last, current) < _minDisplacementMeters) {
      return;
    }

    try {
      await ref.push().set(fix.toJson());
      _lastPushedLocation = current;
    } catch (_) {
      // Best-effort telemetry: network hiccups or an unconfigured project
      // shouldn't interrupt the rest of the app.
    }
  }
}
