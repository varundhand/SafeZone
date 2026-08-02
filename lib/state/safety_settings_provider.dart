import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether Feature 2 (transit-mode alerts) should fire. Toggled from the
/// Safety screen; read by [TrackingController] before raising an alert.
final transitAlertsEnabledProvider = StateProvider<bool>((ref) => true);
