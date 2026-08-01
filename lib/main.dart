import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'screens/dashboard_screen.dart';
import 'services/firebase_telemetry_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseTelemetryService.instance.initialize(deviceId: 'demo-child-device');
  } catch (_) {
    // No real Firebase project configured yet (see lib/firebase_options.dart).
    // The rest of the app — map, geofencing, mock tracking — still works;
    // telemetry pushes just become no-ops until a project is wired up.
  }

  runApp(const ProviderScope(child: SafeZoneApp()));
}

class SafeZoneApp extends StatelessWidget {
  const SafeZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeZone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const DashboardScreen(),
    );
  }
}
