import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Generated-style Firebase options, in the same shape `flutterfire configure`
/// produces.
///
/// TODO(course-project): the values below are PLACEHOLDERS. Once you have a
/// real Firebase project, run `flutterfire configure` with your project id,
/// which overwrites this file with your project's real keys. Until then,
/// FirebaseTelemetryService fails soft — the rest of the app (map, geofences,
/// mock tracking) works normally, and telemetry pushes are silently skipped.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FIREBASE_API_KEY',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'safe-zone-csis4280',
    databaseURL: 'https://safe-zone-csis4280-default-rtdb.firebaseio.com',
    storageBucket: 'safe-zone-csis4280.appspot.com',
  );

  static const FirebaseOptions ios = android;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FIREBASE_API_KEY',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'safe-zone-csis4280',
    databaseURL: 'https://safe-zone-csis4280-default-rtdb.firebaseio.com',
    storageBucket: 'safe-zone-csis4280.appspot.com',
  );
}
