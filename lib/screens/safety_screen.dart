import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../navigation/app_navigation.dart';
import '../state/safety_settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/safezone_bottom_nav.dart';
import '../widgets/safezone_top_bar.dart';

// TODO(demo): replace with a real number before presenting.
const _emergencyContactNumber = '+16045550139';

Future<void> callNumber(BuildContext context, String number) async {
  final launched = await launchUrl(
    Uri(scheme: 'tel', path: number),
    mode: LaunchMode.externalApplication,
  );
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open the dialer for $number')),
    );
  }
}

/// Emergency contact + alert preferences. Both switches are wired to their
/// providers, which TrackingController checks before raising the matching
/// alert — turning either off here genuinely suppresses it, it isn't just
/// cosmetic. "Zone Exit Alerts" is the app's primary safety feature;
/// "Transit-mode Alerts" (Feature 2) is a secondary add-on.
class SafetyScreen extends ConsumerWidget {
  const SafetyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zoneExitAlertsEnabled = ref.watch(zoneExitAlertsEnabledProvider);
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
                  icon: Icons.fence_outlined,
                  title: 'Zone Exit Alerts',
                  subtitle: 'Notify me the moment Alex leaves any safe zone',
                  value: zoneExitAlertsEnabled,
                  onChanged: (value) =>
                      ref.read(zoneExitAlertsEnabledProvider.notifier).state = value,
                ),
                const SizedBox(height: 12),
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
                Text(_emergencyContactNumber, style: TextStyle(fontSize: 12, color: SafeZoneColors.secondary)),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () => callNumber(context, _emergencyContactNumber),
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
