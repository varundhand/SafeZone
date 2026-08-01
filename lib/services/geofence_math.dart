import 'dart:math';

import 'package:latlong2/latlong.dart';

/// Ray-casting point-in-polygon test (Feature 1). Draws an imaginary ray from
/// [point] and counts how many polygon edges it crosses; an odd count means
/// the point is inside. Works for the arbitrary, non-convex shapes parents
/// draw by tapping the map (e.g. an irregular school campus outline).
bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
  if (polygon.length < 3) return false;

  var inside = false;
  for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    final xi = polygon[i].longitude, yi = polygon[i].latitude;
    final xj = polygon[j].longitude, yj = polygon[j].latitude;

    final intersects = ((yi > point.latitude) != (yj > point.latitude)) &&
        (point.longitude < (xj - xi) * (point.latitude - yi) / (yj - yi) + xi);

    if (intersects) inside = !inside;
  }
  return inside;
}

/// Great-circle distance between two coordinates, in meters.
double haversineMeters(LatLng a, LatLng b) {
  const earthRadiusMeters = 6371000.0;
  final dLat = _degToRad(b.latitude - a.latitude);
  final dLon = _degToRad(b.longitude - a.longitude);
  final lat1 = _degToRad(a.latitude);
  final lat2 = _degToRad(b.latitude);

  final h = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(h), sqrt(1 - h));
  return earthRadiusMeters * c;
}

double _degToRad(double deg) => deg * (pi / 180);
