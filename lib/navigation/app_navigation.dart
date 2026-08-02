import 'package:flutter/material.dart';

import '../screens/dashboard_screen.dart';
import '../screens/history_screen.dart';
import '../screens/safety_screen.dart';
import '../screens/zones_screen.dart';

/// Swaps to the tab at [index] with no transition animation, matching how a
/// persistent bottom tab bar feels. Each tab screen owns its own
/// [SafeZoneBottomNav] instance (see dashboard_screen.dart's map-overlay
/// layout for why there's no single shared Scaffold shell), so switching
/// tabs is a same-level route replacement rather than a push.
void navigateToTab(BuildContext context, int index) {
  final current = ModalRoute.of(context)?.settings.name;
  final target = tabRouteName(index);
  if (current == target) return;

  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      settings: RouteSettings(name: target),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (_, _, _) => _tabScreen(index),
    ),
  );
}

String tabRouteName(int index) => '/tab-$index';

Widget _tabScreen(int index) {
  switch (index) {
    case 0:
      return const DashboardScreen();
    case 1:
      return const ZonesScreen();
    case 2:
      return const HistoryScreen();
    case 3:
      return const SafetyScreen();
    default:
      throw ArgumentError('Unknown tab index: $index');
  }
}
