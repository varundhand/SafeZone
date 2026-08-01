import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../models/geofence.dart';
import '../services/mock_location_service.dart';
import '../state/geofence_provider.dart';
import '../state/tracking_controller.dart';
import '../theme/app_theme.dart';

const _uuid = Uuid();

/// Feature 1: lets a parent tap the map to drop vertices and trace an
/// arbitrary polygon (e.g. a school campus outline) rather than a simple
/// circle. Matches for_claude/.../add_geofence/code.html.
class AddGeofenceScreen extends ConsumerStatefulWidget {
  const AddGeofenceScreen({super.key});

  @override
  ConsumerState<AddGeofenceScreen> createState() => _AddGeofenceScreenState();
}

class _AddGeofenceScreenState extends ConsumerState<AddGeofenceScreen> {
  final _mapController = MapController();
  final List<LatLng> _points = [];

  void _addPoint(LatLng point) {
    setState(() => _points.add(point));
  }

  void _undo() {
    if (_points.isEmpty) return;
    setState(() => _points.removeLast());
  }

  void _recenter() {
    final fix = ref.read(trackingControllerProvider).currentFix;
    _mapController.move(fix?.latLng ?? MockLocationService.defaultCenter, 17);
  }

  Future<void> _save() async {
    if (_points.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Drop at least 3 points to trace a boundary.')),
      );
      return;
    }

    final result = await showDialog<({String name, GeofenceType type})>(
      context: context,
      builder: (context) => _SaveGeofenceDialog(),
    );
    if (result == null || !mounted) return;

    ref.read(geofenceListProvider.notifier).add(
          Geofence(
            id: _uuid.v4(),
            name: result.name,
            vertices: List.of(_points),
            type: result.type,
          ),
        );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final fix = ref.watch(trackingControllerProvider.select((s) => s.currentFix));
    final center = fix?.latLng ?? MockLocationService.defaultCenter;

    return Scaffold(
      backgroundColor: SafeZoneColors.surface,
      appBar: AppBar(
        backgroundColor: SafeZoneColors.surface.withValues(alpha: 0.8),
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: SafeZoneColors.secondary)),
        ),
        leadingWidth: 80,
        title: const Text('Add Geofence', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _save,
              style: TextButton.styleFrom(
                backgroundColor: SafeZoneColors.primaryContainer,
                foregroundColor: SafeZoneColors.onPrimaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Boundary', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 17,
                onTap: (tapPosition, point) => _addPoint(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.safe_zone',
                ),
                if (_points.length >= 3)
                  PolygonLayer(
                    polygons: [
                      Polygon(
                        points: _points,
                        color: SafeZoneColors.primaryContainer.withValues(alpha: 0.1),
                        borderColor: SafeZoneColors.primary,
                        borderStrokeWidth: 1.5,
                      ),
                    ],
                  ),
                if (_points.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(points: _points, color: SafeZoneColors.primary, strokeWidth: 1.5),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    for (final p in _points)
                      Marker(
                        point: p,
                        width: 14,
                        height: 14,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: SafeZoneColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: SafeZoneColors.onSurface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.gesture, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Tap the map to drop boundary points', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 200,
            child: Column(
              children: [
                _RoundIconButton(icon: Icons.my_location, onPressed: _recenter),
                const SizedBox(height: 16),
                _RoundIconButton(icon: Icons.undo, onPressed: _undo),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _RoundIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SafeZoneColors.surface,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: SafeZoneColors.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _SaveGeofenceDialog extends StatefulWidget {
  @override
  State<_SaveGeofenceDialog> createState() => _SaveGeofenceDialogState();
}

class _SaveGeofenceDialogState extends State<_SaveGeofenceDialog> {
  final _nameController = TextEditingController();
  GeofenceType _type = GeofenceType.general;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Name this zone'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'e.g. School Campus'),
          ),
          const SizedBox(height: 16),
          const Text('Movement policy', style: TextStyle(fontSize: 12, color: SafeZoneColors.secondary)),
          const SizedBox(height: 8),
          SegmentedButton<GeofenceType>(
            segments: const [
              ButtonSegment(value: GeofenceType.general, label: Text('General')),
              ButtonSegment(value: GeofenceType.walkingOnly, label: Text('Walking-only')),
            ],
            selected: {_type},
            onSelectionChanged: (selection) => setState(() => _type = selection.first),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();
            Navigator.of(context).pop((
              name: name.isEmpty ? 'Unnamed Zone' : name,
              type: _type,
            ));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
