import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shared header for every top-level tab: avatar, bold title, notification
/// bell. The Map tab passes [onTitleLongPress] to wire the hidden Developer
/// Mode toggle (Feature 4); other tabs just show their section name.
class SafeZoneTopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onTitleLongPress;

  const SafeZoneTopBar({super.key, this.title = 'SafeZone', this.onTitleLongPress});

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
            GestureDetector(
              onLongPress: onTitleLongPress,
              child: Text(
                title,
                style: const TextStyle(
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
