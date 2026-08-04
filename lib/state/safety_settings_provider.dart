import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether leaving any drawn safe zone should raise an immediate alert —
/// the app's primary safety feature. Toggled from the Safety screen; read
/// by [TrackingController] before raising an alert.
final zoneExitAlertsEnabledProvider = StateProvider<bool>((ref) => true);

/// Whether Feature 2 (transit-mode alerts) should fire. Secondary to the
/// zone-exit alert above. Toggled from the Safety screen; read by
/// [TrackingController] before raising an alert.
final transitAlertsEnabledProvider = StateProvider<bool>((ref) => true);
