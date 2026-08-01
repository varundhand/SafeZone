import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Thin wrapper around the native `com.csis4280/geofence` channels.
///
/// The MethodChannel starts/stops the Kotlin foreground service; the
/// EventChannel streams both location fixes (type: "location") and
/// transit-mode transitions (type: "activity") back from LocationService.
class LocationChannelService {
  LocationChannelService._();
  static final LocationChannelService instance = LocationChannelService._();

  static const _methodChannel = MethodChannel('com.csis4280/geofence');
  static const _eventChannel = EventChannel('com.csis4280/geofence/events');

  Stream<Map<dynamic, dynamic>>? _events;

  Stream<Map<dynamic, dynamic>> get events {
    _events ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => event as Map<dynamic, dynamic>);
    return _events!;
  }

  /// Requests every runtime permission the native side needs before the
  /// foreground service is started: precise location, background location,
  /// activity recognition (transit-mode detection) and notifications
  /// (required to show the persistent tracking notification on Android 13+).
  Future<bool> requestPermissions() async {
    final whenInUse = await Permission.locationWhenInUse.request();
    if (!whenInUse.isGranted) return false;

    await Permission.locationAlways.request();
    await Permission.activityRecognition.request();
    await Permission.notification.request();

    return true;
  }

  Future<void> startService() => _methodChannel.invokeMethod('startService');

  Future<void> stopService() => _methodChannel.invokeMethod('stopService');
}
