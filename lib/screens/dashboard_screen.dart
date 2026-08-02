import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/mock_location_service.dart';
import '../state/geofence_provider.dart';
import '../state/tracking_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/pulsing_marker.dart';
import '../widgets/safezone_bottom_nav.dart';
import 'add_geofence_screen.dart';
import 'safety_alert_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _startRequested = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _beginTracking());
  }

  Future<void> _beginTracking() async {
    if (_startRequested) return;
    _startRequested = true;
    final granted = await ref.read(trackingControllerProvider.notifier).startTracking();
    if (!granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission is required to track Alex.'),
        ),
      );
    }
  }

  Future<void> _toggleDevMode() async {
    final current = ref.read(trackingControllerProvider).devMode;
    final wasTracking = ref.read(trackingControllerProvider).isTracking;
    await ref.read(trackingControllerProvider.notifier).setDevMode(!current);
    _startRequested = false;
    if (!wasTracking || ref.read(trackingControllerProvider).isTracking) {
      await _beginTracking();
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !current
                ? 'Developer mode enabled: simulating a walk near Douglas College'
                : 'Developer mode disabled: using live GPS',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(
      trackingControllerProvider.select((s) => s.hasActiveAlert),
      (previous, hasAlert) {
        if (hasAlert && mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SafetyAlertScreen()),
          );
        }
      },
    );

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _DashboardMap()),
          _TopBar(onTitleLongPress: _toggleDevMode),
          const Positioned(left: 0, right: 0, bottom: 84, child: _StatusSheet()),
          Positioned(
            right: 20,
            bottom: 110,
            child: FloatingActionButton.extended(
              backgroundColor: SafeZoneColors.primaryContainer,
              foregroundColor: SafeZoneColors.onPrimaryContainer,
              elevation: 4,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddGeofenceScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                'ADD GEOFENCE',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, fontSize: 12),
              ),
            ),
          ),
          const Positioned(left: 0, right: 0, bottom: 0, child: SafeZoneBottomNav()),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onTitleLongPress;

  const _TopBar({required this.onTitleLongPress});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 44 + MediaQuery.of(context).padding.top,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: 20,
          right: 20,
        ),
        color: SafeZoneColors.surface.withValues(alpha: 0.85),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: SafeZoneColors.primaryContainer, width: 2),
                color: SafeZoneColors.secondaryContainer,
              ),
              child: const Icon(Icons.person, size: 18, color: SafeZoneColors.onSurfaceVariant),
            ),
            // Long-pressing the wordmark is the hidden Developer Mode toggle
            // (Feature 4) — kept off the visible chrome for a live demo.
            GestureDetector(
              onLongPress: onTitleLongPress,
              child: const Text(
                'SafeZone',
                style: TextStyle(
                  color: SafeZoneColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const Icon(Icons.notifications_outlined, color: SafeZoneColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _DashboardMap extends ConsumerStatefulWidget {
  const _DashboardMap();

  @override
  ConsumerState<_DashboardMap> createState() => _DashboardMapState();
}

class _DashboardMapState extends ConsumerState<_DashboardMap> {
  final _mapController = MapController();
  bool _hasCenteredOnFix = false;

  @override
  Widget build(BuildContext context) {
    final fix = ref.watch(trackingControllerProvider.select((s) => s.currentFix));
    final geofences = ref.watch(geofenceListProvider);

    // The map is created before the first GPS/mock fix arrives, so it starts
    // on the default New Westminster center; once a real fix lands, jump the
    // camera to it once so the live marker is actually visible.
    if (fix != null && !_hasCenteredOnFix) {
      _hasCenteredOnFix = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(fix.latLng, 16);
      });
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: fix?.latLng ?? MockLocationService.defaultCenter,
        initialZoom: 16,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.safe_zone',
        ),
        PolygonLayer(
          polygons: [
            for (final g in geofences)
              Polygon(
                points: g.vertices,
                color: SafeZoneColors.primaryContainer.withValues(alpha: 0.12),
                borderColor: SafeZoneColors.primary,
                borderStrokeWidth: 1.5,
              ),
          ],
        ),
        if (fix != null)
          MarkerLayer(
            markers: [
              Marker(
                point: fix.latLng,
                width: 80,
                height: 112,
                alignment: Alignment.topCenter,
                child: const _UserMarker(),
              ),
            ],
          ),
        const RichAttributionWidget(
          attributions: [
            TextSourceAttribution('OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }
}

class _UserMarker extends StatelessWidget {
  const _UserMarker();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PulsingMarker(
          pulseColor: SafeZoneColors.primaryContainer,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  color: SafeZoneColors.secondaryContainer,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20),
                  ],
                ),
                child: const Icon(Icons.face, color: SafeZoneColors.onSurfaceVariant),
              ),
              Positioned(
                bottom: -1,
                right: -1,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: SafeZoneColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: SafeZoneColors.cardBorder),
          ),
          child: const Text(
            'Alex',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _StatusSheet extends ConsumerWidget {
  const _StatusSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fix = ref.watch(trackingControllerProvider.select((s) => s.currentFix));
    final devMode = ref.watch(trackingControllerProvider.select((s) => s.devMode));

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: SafeZoneColors.surface,
          border: Border.all(color: SafeZoneColors.cardBorder),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: SafeZoneColors.neutralAccent.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Alex',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: SafeZoneColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: SafeZoneColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  devMode ? 'Simulated' : 'Safe',
                                  style: const TextStyle(
                                    color: SafeZoneColors.success,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.more_horiz, color: SafeZoneColors.secondary),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          icon: Icons.battery_charging_full,
                          label: 'Battery',
                          value: fix == null ? '--' : '${fix.batteryPercent}%',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(
                          icon: Icons.signal_cellular_alt,
                          label: 'Network',
                          value: fix == null ? '--' : fix.network,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: SafeZoneColors.primaryContainer.withValues(alpha: 0.1),
                      border: Border.all(color: SafeZoneColors.primaryContainer.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: SafeZoneColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            fix == null
                                ? 'Waiting for a GPS fix…'
                                : '${fix.lat.toStringAsFixed(5)}, ${fix.lng.toStringAsFixed(5)}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: SafeZoneColors.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SafeZoneColors.surfaceContainerLow,
        border: Border.all(color: SafeZoneColors.cardBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: SafeZoneColors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: SafeZoneColors.secondary)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
