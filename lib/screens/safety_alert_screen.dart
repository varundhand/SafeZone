import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/mock_location_service.dart';
import '../state/tracking_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/safezone_bottom_nav.dart';

/// Feature 2 payoff screen: shown the instant the tracking controller detects
/// activity == in_vehicle while still inside a walking-only geofence.
/// Matches for_claude/.../safety_alert/code.html.
class SafetyAlertScreen extends ConsumerWidget {
  const SafetyAlertScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trackingControllerProvider);
    final fix = state.currentFix;
    final zoneName = state.triggeredAlertGeofence?.name ?? 'the safe zone';
    final speedKmh = fix == null ? 0.0 : fix.speed * 3.6;

    return Scaffold(
      backgroundColor: SafeZoneColors.surface,
      appBar: AppBar(
        backgroundColor: SafeZoneColors.surface.withValues(alpha: 0.8),
        title: const Text(
          'Alert: Transit Mode Changed',
          style: TextStyle(color: SafeZoneColors.error, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_outlined, color: SafeZoneColors.onSurfaceVariant),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: fix?.latLng ?? MockLocationService.defaultCenter,
                initialZoom: 16,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.safe_zone',
                ),
                if (state.triggeredAlertGeofence != null)
                  PolygonLayer(
                    polygons: [
                      Polygon(
                        points: state.triggeredAlertGeofence!.vertices,
                        color: SafeZoneColors.error.withValues(alpha: 0.05),
                        borderColor: SafeZoneColors.error.withValues(alpha: 0.4),
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
                if (fix != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: fix.latLng,
                        width: 48,
                        height: 48,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: SafeZoneColors.error,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                              ),
                              child: const Icon(Icons.face, color: Colors.white),
                            ),
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: SafeZoneColors.primaryContainer,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white),
                                ),
                                child: const Icon(Icons.directions_car, size: 12, color: SafeZoneColors.onPrimaryContainer),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _InfoBubble(
                  icon: Icons.battery_3_bar,
                  label: fix == null ? '--% Battery' : '${fix.batteryPercent}% Battery',
                ),
                const SizedBox(height: 8),
                _InfoBubble(icon: Icons.signal_cellular_alt, label: fix == null ? 'GPS' : '${fix.network} GPS'),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 104,
            child: _AlertCard(
              zoneName: zoneName,
              speedKmh: speedKmh,
              onDismiss: () {
                ref.read(trackingControllerProvider.notifier).dismissAlert();
                Navigator.of(context).pop();
              },
              onCall: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Calling Alex…')),
                );
              },
            ),
          ),
          const Positioned(left: 0, right: 0, bottom: 0, child: SafeZoneBottomNav()),
        ],
      ),
    );
  }
}

class _InfoBubble extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoBubble({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: SafeZoneColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: SafeZoneColors.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: SafeZoneColors.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final String zoneName;
  final double speedKmh;
  final VoidCallback onDismiss;
  final VoidCallback onCall;

  const _AlertCard({
    required this.zoneName,
    required this.speedKmh,
    required this.onDismiss,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SafeZoneColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SafeZoneColors.error.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 32, offset: const Offset(0, 8))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: SafeZoneColors.error.withValues(alpha: 0.05),
              border: Border(bottom: BorderSide(color: SafeZoneColors.error.withValues(alpha: 0.1))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning, color: SafeZoneColors.error, size: 20),
                    SizedBox(width: 8),
                    Text('CRITICAL ALERT', style: TextStyle(color: SafeZoneColors.error, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const Text('Just now', style: TextStyle(color: SafeZoneColors.secondary, fontSize: 10)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: SafeZoneColors.onSurface, height: 1.2),
                    children: [
                      const TextSpan(text: 'Child detected moving in vehicle at '),
                      TextSpan(
                        text: '${speedKmh.toStringAsFixed(0)}km/h',
                        style: const TextStyle(color: SafeZoneColors.error, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' outside of \'$zoneName\''),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Unusual transit detected. Alex has left the designated safe area during expected hours via a moving vehicle.',
                  style: const TextStyle(color: SafeZoneColors.secondary, fontSize: 14),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: onCall,
                    icon: const Icon(Icons.call),
                    label: const Text('Call Child', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: SafeZoneColors.outline),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Dismiss Alert', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
