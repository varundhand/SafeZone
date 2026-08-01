import 'package:latlong2/latlong.dart';

/// A single GPS reading plus the device telemetry that travels with it
/// (Feature 3: battery percentage and network state alongside coordinates).
class LocationFix {
  final double lat;
  final double lng;
  final double accuracy;
  final double speed;
  final int timestampMs;
  final int batteryPercent;
  final String network;

  const LocationFix({
    required this.lat,
    required this.lng,
    required this.accuracy,
    required this.speed,
    required this.timestampMs,
    required this.batteryPercent,
    required this.network,
  });

  LatLng get latLng => LatLng(lat, lng);

  factory LocationFix.fromMap(Map<dynamic, dynamic> map) {
    return LocationFix(
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0,
      speed: (map['speed'] as num?)?.toDouble() ?? 0,
      timestampMs:
          (map['timestamp'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      batteryPercent: (map['battery'] as num?)?.toInt() ?? -1,
      network: map['network'] as String? ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'accuracy': accuracy,
        'speed': speed,
        'timestamp': timestampMs,
        'battery': batteryPercent,
        'network': network,
      };
}
