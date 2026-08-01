import 'dart:async';

import 'package:latlong2/latlong.dart';

import '../models/location_fix.dart';

/// Feature 4: "Developer Mode" mock tracking. When the hidden toggle is
/// enabled, this replaces the native GPS/EventChannel feed with a scripted
/// walk so the app can be demoed live without needing to physically move.
///
/// The route is centered on New Westminster, BC, starting near the Douglas
/// College campus (49.2057, -122.9110) and looping through a short walking
/// circuit around it.
class MockLocationService {
  MockLocationService._();
  static final MockLocationService instance = MockLocationService._();

  static const LatLng defaultCenter = LatLng(49.2057, -122.9110);

  static const List<LatLng> _route = [
    LatLng(49.2038, -122.9111), // Douglas College, New Westminster campus
    LatLng(49.2042, -122.9104),
    LatLng(49.2049, -122.9098),
    LatLng(49.2057, -122.9110), // Default map center
    LatLng(49.2063, -122.9119),
    LatLng(49.2070, -122.9125),
    LatLng(49.2065, -122.9135),
    LatLng(49.2057, -122.9110),
  ];

  static const _stepInterval = Duration(seconds: 2);
  static const _stepsPerSegment = 8;

  StreamController<LocationFix>? _controller;
  Timer? _timer;
  int _segmentIndex = 0;
  int _stepIndex = 0;
  int _batteryPercent = 92;

  bool get isRunning => _timer != null;

  Stream<LocationFix> start() {
    stop();
    _segmentIndex = 0;
    _stepIndex = 0;
    _batteryPercent = 92;

    final controller = StreamController<LocationFix>();
    _controller = controller;
    _timer = Timer.periodic(_stepInterval, (_) => _emitNext());
    _emitNext();
    return controller.stream;
  }

  void _emitNext() {
    final controller = _controller;
    if (controller == null || controller.isClosed) return;

    final from = _route[_segmentIndex % _route.length];
    final to = _route[(_segmentIndex + 1) % _route.length];
    final t = _stepIndex / _stepsPerSegment;

    final lat = from.latitude + (to.latitude - from.latitude) * t;
    final lng = from.longitude + (to.longitude - from.longitude) * t;

    if (_batteryPercent > 15) _batteryPercent--;

    controller.add(LocationFix(
      lat: lat,
      lng: lng,
      accuracy: 5.0,
      speed: 1.4, // average walking pace, m/s
      timestampMs: DateTime.now().millisecondsSinceEpoch,
      batteryPercent: _batteryPercent,
      network: 'wifi',
    ));

    _stepIndex++;
    if (_stepIndex > _stepsPerSegment) {
      _stepIndex = 0;
      _segmentIndex = (_segmentIndex + 1) % _route.length;
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _controller?.close();
    _controller = null;
  }
}
