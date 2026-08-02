import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/geofence.dart';
import '../navigation/app_navigation.dart';
import '../state/geofence_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/safezone_bottom_nav.dart';
import '../widgets/safezone_top_bar.dart';

/// Feature 1 companion screen: lists every geofence drawn from the Add
/// Geofence screen so a parent can review or remove one without having to
/// find it on the map.
class ZonesScreen extends ConsumerWidget {
  const ZonesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final geofences = ref.watch(geofenceListProvider);
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: SafeZoneColors.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: geofences.isEmpty
                ? _EmptyState(topPadding: 44 + topInset)
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(20, 44 + topInset + 16, 20, 84 + 20),
                    itemCount: geofences.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final geofence = geofences[index];
                      return _ZoneCard(
                        geofence: geofence,
                        onDelete: () =>
                            ref.read(geofenceListProvider.notifier).remove(geofence.id),
                      );
                    },
                  ),
          ),
          const SafeZoneTopBar(title: 'Zones'),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeZoneBottomNav(
              currentIndex: 1,
              onTap: (index) => navigateToTab(context, index),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final Geofence geofence;
  final VoidCallback onDelete;

  const _ZoneCard({required this.geofence, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isWalkingOnly = geofence.type == GeofenceType.walkingOnly;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SafeZoneColors.surfaceContainerLowest,
        border: Border.all(color: SafeZoneColors.cardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: SafeZoneColors.primaryContainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.polyline, color: SafeZoneColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  geofence.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _TypeChip(isWalkingOnly: isWalkingOnly),
                    const SizedBox(width: 8),
                    Text(
                      '${geofence.vertices.length} boundary points',
                      style: const TextStyle(fontSize: 12, color: SafeZoneColors.secondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: SafeZoneColors.error),
            tooltip: 'Delete zone',
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final bool isWalkingOnly;

  const _TypeChip({required this.isWalkingOnly});

  @override
  Widget build(BuildContext context) {
    final color = isWalkingOnly ? SafeZoneColors.primary : SafeZoneColors.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isWalkingOnly ? 'Walking-only' : 'General',
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final double topPadding;

  const _EmptyState({required this.topPadding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(40, topPadding, 40, 84),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.polyline_outlined, size: 48, color: SafeZoneColors.neutralAccent),
            const SizedBox(height: 16),
            const Text(
              'No zones yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Draw a boundary from the Map tab to create your first safe zone.',
              textAlign: TextAlign.center,
              style: TextStyle(color: SafeZoneColors.secondary),
            ),
          ],
        ),
      ),
    );
  }
}
