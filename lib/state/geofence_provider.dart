import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/geofence.dart';

class GeofenceListNotifier extends StateNotifier<List<Geofence>> {
  GeofenceListNotifier() : super(const []);

  void add(Geofence geofence) => state = [...state, geofence];

  void remove(String id) => state = state.where((g) => g.id != id).toList();
}

final geofenceListProvider =
    StateNotifierProvider<GeofenceListNotifier, List<Geofence>>(
  (ref) => GeofenceListNotifier(),
);
