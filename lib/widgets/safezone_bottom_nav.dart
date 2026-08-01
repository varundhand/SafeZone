import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Bottom tab bar matching the SafeZone mockups. Only the Map tab is wired
/// up in Phase 1 — Zones/History/Safety are visual placeholders for now.
class SafeZoneBottomNav extends StatelessWidget {
  final int currentIndex;

  const SafeZoneBottomNav({super.key, this.currentIndex = 0});

  static const _items = [
    (icon: Icons.map, label: 'Map'),
    (icon: Icons.polyline, label: 'Zones'),
    (icon: Icons.history, label: 'History'),
    (icon: Icons.security, label: 'Safety'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: SafeZoneColors.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < _items.length; i++)
            _NavItem(
              icon: _items[i].icon,
              label: _items[i].label,
              selected: i == currentIndex,
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _NavItem({required this.icon, required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    final color = selected ? SafeZoneColors.primary : SafeZoneColors.secondary;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
