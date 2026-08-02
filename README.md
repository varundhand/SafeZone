# SafeZone

CSIS 4280 course project — Phase 1 of a smart geofencing & commuter alert app.
Flutter UI + Riverpod state management, talking to a native Kotlin
`LocationService` (foreground service, Android 14 compliant) over a
`MethodChannel`/`EventChannel` pair, with custom polygon geofencing,
transit-mode (walking → in-vehicle) alerting, and a Firebase Realtime
Database telemetry sink.

## What's implemented

- **Feature 1 — Custom polygon geofencing**: tap-to-drop-vertex drawing UI
  (`lib/screens/add_geofence_screen.dart`) plus a ray-casting point-in-polygon
  test (`lib/services/geofence_math.dart`).
- **Feature 2 — Transit-mode activity recognition**: native
  `ActivityRecognitionClient` (`LocationService.kt` /
  `ActivityTransitionReceiver.kt`) pushes walking → `in_vehicle` transitions
  straight to Dart over the EventChannel, which triggers an immediate
  full-screen alert if it happens inside a "walking-only" zone.
- **Feature 3 — Real-time telemetry**: every location fix carries battery %
  and network type (read natively in Kotlin) and is pushed to Firebase
  Realtime Database once the child has moved >10m
  (`lib/services/firebase_telemetry_service.dart`).
- **Feature 4 — Developer Mode mock tracking**: long-press the "SafeZone"
  wordmark on the dashboard to toggle a scripted walk around Douglas College,
  New Westminster (49.2057, -122.9110) — no real device movement or GPS
  needed for a live demo.

The three screens (`dashboard_screen.dart`, `add_geofence_screen.dart`,
`safety_alert_screen.dart`) follow the color/typography/elevation tokens in
`for_claude/stitch_safezone_family_safety_app/safezone/DESIGN.md`.

## Prerequisites

- Flutter SDK (this project's `pubspec.lock` was resolved against Flutter
  ≥3.38; a current stable install is expected to work).
- Android Studio's command-line tools / an Android SDK (already present on
  this machine at `~/Library/Android/sdk`).
- **A physical Android device is the recommended way to test this**, since
  the app needs real GPS/sensors for full behavior and no emulator is set up:
  1. On the phone: Settings → About phone → tap "Build number" 7 times to
     unlock Developer Options.
  2. Settings → Developer options → enable **USB debugging**.
  3. Plug the phone into this machine via USB and accept the "Allow USB
     debugging?" prompt on the phone.
  4. Confirm it's visible: `flutter devices`.

  If you'd rather use an emulator later, any Android 14 (API 34) image with
  Google Play services works, since geofencing/activity recognition needs
  Play Services.

## First-time setup

```bash
flutter pub get
```

Firebase is **optional for Phase 1 demoing**: `lib/firebase_options.dart`
ships with placeholder keys, and `FirebaseTelemetryService` fails soft — the
map, polygon geofencing, alerts, and mock tracking all work with no Firebase
project configured; telemetry pushes just silently no-op. To wire up real
syncing later, create a Firebase project and run:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

which overwrites `firebase_options.dart` with real project credentials.

## Running

```bash
flutter run
```

On first launch the app immediately requests location ("while using app"
then "always"), activity recognition, and notification permissions, then
starts the native foreground service (you'll see a persistent "SafeZone is
tracking location" notification). Grant "Allow all the time" on the
background-location prompt if you want tracking to keep working with the app
backgrounded.

### Demoing without walking anywhere

Long-press the **"SafeZone"** title text at the top of the dashboard. This
flips on Developer Mode, which stops the real GPS feed and starts a scripted
route looping around the Douglas College campus area — enough to walk the
avatar in and out of any geofence you've drawn. Long-press again to switch
back to live GPS.

To see the Feature 2 alert screen in the demo: draw a **walking-only**
geofence around the mock route (Add Geofence → trace a boundary → choose
"Walking-only" as the movement policy), enable Developer Mode, and trigger a
transit-mode change from a real device's Play Services test tools, or note
that the mock feed always reports a fixed walking speed — the alert path
itself is exercised by the real `ActivityTransitionReceiver` on a physical
device carried in a car with the walking-only zone drawn around where you
actually are.

## Verifying without running the app

No emulator was available while building this, so nothing here has been
run — treat first boot as the real test. Before that:

```bash
flutter analyze   # static analysis across lib/
flutter test      # widget_test.dart smoke-tests the dashboard renders,
                   # with the geofence + permission_handler MethodChannels mocked out
```

If `flutter analyze` or `flutter test` surface anything, fix those first —
they'll catch far more than a first `flutter run` will tell you.

## Project layout

```
lib/
  models/          Geofence, LocationFix, ActivityEvent — plain data classes
  services/        geofence_math (ray casting + haversine), the location
                   MethodChannel/EventChannel wrapper, mock tracking,
                   Firebase telemetry push
  state/           Riverpod providers: TrackingController owns the live
                   (real or mocked) stream subscription and derived alert
                   state; GeofenceListNotifier owns saved zones
  screens/         dashboard, add-geofence (drawing), safety-alert
  widgets/         pulsing live-location marker, bottom nav
  theme/           color tokens lifted from for_claude/.../DESIGN.md

android/app/src/main/kotlin/com/example/safe_zone/
  LocationService.kt            foreground service: FusedLocationProvider +
                                 ActivityRecognitionClient, both streamed
                                 back to Dart
  ActivityTransitionReceiver.kt receives activity-transition broadcasts
  MainActivity.kt               wires the MethodChannel/EventChannel
                                 ('com.csis4280/geofence') to LocationService
```
