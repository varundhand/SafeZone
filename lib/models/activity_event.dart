/// Transit mode reported by the native ActivityRecognitionClient (Feature 2).
enum TransitMode { still, walking, running, inVehicle, onBicycle, unknown }

TransitMode transitModeFromNative(String value) {
  switch (value) {
    case 'still':
      return TransitMode.still;
    case 'walking':
      return TransitMode.walking;
    case 'running':
      return TransitMode.running;
    case 'in_vehicle':
      return TransitMode.inVehicle;
    case 'on_bicycle':
      return TransitMode.onBicycle;
    default:
      return TransitMode.unknown;
  }
}

class ActivityEvent {
  final TransitMode mode;
  final bool isEnter;

  const ActivityEvent({required this.mode, required this.isEnter});

  factory ActivityEvent.fromMap(Map<dynamic, dynamic> map) {
    return ActivityEvent(
      mode: transitModeFromNative(map['activity'] as String? ?? ''),
      isEnter: map['transition'] == 'enter',
    );
  }
}
