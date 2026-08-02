import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../navigation/app_navigation.dart';
import '../state/safety_settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/safezone_bottom_nav.dart';
import '../widgets/safezone_top_bar.dart';

/// Emergency contact + alert preferences. The "Transit-mode Alerts" switch
/// is wired to [transitAlertsEnabledProvider], which TrackingController
/// checks before raising a Feature 2 alert — turning it off here genuinely
/// suppresses the alert, it isn't just cosmetic.
class SafetyScreen extends ConsumerWidget {
  const SafetyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transitAlertsEnabled = ref.watch(transitAlertsEnabledProvider);
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: SafeZoneColors.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20, 44 + topInset + 16, 20, 84 + 20),
              children: [
                const _SectionLabel('Emergency Contact'),
                const SizedBox(height: 8),
                const _EmergencyContactCard(),
                const SizedBox(height: 24),
                const _SectionLabel('Alert Preferences'),
                const SizedBox(height: 8),
                _PreferenceCard(
                  icon: Icons.directions_car_filled_outlined,
                  title: 'Transit-mode Alerts',
                  subtitle:
                      "Notify me if Alex is moving in a vehicle inside a walking-only zone",
                  value: transitAlertsEnabled,
                  onChanged: (value) =>
                      ref.read(transitAlertsEnabledProvider.notifier).state = value,
                ),
              ],
            ),
          ),
          const SafeZoneTopBar(title: 'Safety'),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeZoneBottomNav(
              currentIndex: 3,
              onTap: (index) => navigateToTab(context, index),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SafeZoneColors.secondary),
    );
  }
}

class _EmergencyContactCard extends StatelessWidget {
  const _EmergencyContactCard();

  @override
  Widget build(BuildContext context) {
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
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: SafeZoneColors.secondaryContainer,
            ),
            child: const Icon(Icons.person, color: SafeZoneColors.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mom', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 2),
                Text('(604) 555-0139', style: TextStyle(fontSize: 12, color: SafeZoneColors.secondary)),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calling Mom…')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: SafeZoneColors.primaryContainer,
              foregroundColor: SafeZoneColors.onPrimaryContainer,
            ),
            icon: const Icon(Icons.call, size: 16),
            label: const Text('Call'),
          ),
        ],
      ),
    );
  }
}

class _PreferenceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PreferenceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SafeZoneColors.surfaceContainerLowest,
        border: Border.all(color: SafeZoneColors.cardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: SafeZoneColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: SafeZoneColors.secondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: SafeZoneColors.primaryContainer,
          ),
        ],
      ),
    );
  }
}
