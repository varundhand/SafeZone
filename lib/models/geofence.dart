import 'package:latlong2/latlong.dart';

/// A geofence's movement policy. [walkingOnly] zones (e.g. a school campus)
/// trigger a transit-mode alert if the child is detected in a vehicle while
/// still inside the boundary.
enum GeofenceType { general, walkingOnly }

class Geofence {
  final String id;
  final String name;
  final List<LatLng> vertices;
  final GeofenceType type;

  const Geofence({
    required this.id,
    required this.name,
    required this.vertices,
    this.type = GeofenceType.general,
  });

  Geofence copyWith({
    String? name,
    List<LatLng>? vertices,
    GeofenceType? type,
  }) {
    return Geofence(
      id: id,
      name: name ?? this.name,
      vertices: vertices ?? this.vertices,
      type: type ?? this.type,
    );
  }
}
