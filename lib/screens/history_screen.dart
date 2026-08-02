import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/location_fix.dart';
import '../navigation/app_navigation.dart';
import '../state/tracking_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/safezone_bottom_nav.dart';
import '../widgets/safezone_top_bar.dart';

/// Feature 3 companion screen: a rolling log of the telemetry fixes
/// TrackingController has collected (coordinates, speed, battery, network),
/// newest first. In-memory only for Phase 1 — see TrackingState.history.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(trackingControllerProvider.select((s) => s.history));
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: SafeZoneColors.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: history.isEmpty
                ? _EmptyState(topPadding: 44 + topInset)
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(20, 44 + topInset + 16, 20, 84 + 20),
                    itemCount: history.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _HistoryCard(fix: history[index]),
                  ),
          ),
          const SafeZoneTopBar(title: 'History'),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeZoneBottomNav(
              currentIndex: 2,
              onTap: (index) => navigateToTab(context, index),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final LocationFix fix;

  const _HistoryCard({required this.fix});

  @override
  Widget build(BuildContext context) {
    final time = DateTime.fromMillisecondsSinceEpoch(fix.timestampMs);
    final timeLabel =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
    final speedKmh = (fix.speed * 3.6).toStringAsFixed(0);

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
              color: SafeZoneColors.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.location_on_outlined,
                color: SafeZoneColors.onSurfaceVariant, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(timeLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('$speedKmh km/h',
                        style: const TextStyle(fontSize: 12, color: SafeZoneColors.secondary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${fix.lat.toStringAsFixed(5)}, ${fix.lng.toStringAsFixed(5)}',
                  style: const TextStyle(fontSize: 12, color: SafeZoneColors.secondary),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.battery_charging_full, size: 12, color: SafeZoneColors.secondary),
                    const SizedBox(width: 4),
                    Text('${fix.batteryPercent}%',
                        style: const TextStyle(fontSize: 11, color: SafeZoneColors.secondary)),
                    const SizedBox(width: 12),
                    const Icon(Icons.signal_cellular_alt, size: 12, color: SafeZoneColors.secondary),
                    const SizedBox(width: 4),
                    Text(fix.network,
                        style: const TextStyle(fontSize: 11, color: SafeZoneColors.secondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
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
            const Icon(Icons.history, size: 48, color: SafeZoneColors.neutralAccent),
            const SizedBox(height: 16),
            const Text(
              'No activity yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Once tracking starts, location updates will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: SafeZoneColors.secondary),
            ),
          ],
        ),
      ),
    );
  }
}
