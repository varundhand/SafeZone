// Smoke test: pumps the SafeZone dashboard and verifies it renders without
// throwing, with the native geofence/permission MethodChannels mocked out
// (there's no real Android host in a widget test).

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:safe_zone/main.dart';

void main() {
  const geofenceChannel = MethodChannel('com.csis4280/geofence');
  const permissionChannel = MethodChannel('flutter.baseflow.com/permissions/methods');
  const grantedStatus = 1;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(geofenceChannel, (call) async => null);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (call) async {
      switch (call.method) {
        case 'requestPermissions':
          final permissions = (call.arguments as List).cast<int>();
          return {for (final p in permissions) p: grantedStatus};
        case 'checkPermissionStatus':
          return grantedStatus;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(geofenceChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
  });

  testWidgets('SafeZone dashboard renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SafeZoneApp()));
    await tester.pump();

    expect(find.text('SafeZone'), findsOneWidget);
  });
}
