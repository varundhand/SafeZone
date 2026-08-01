import 'package:flutter/material.dart';

/// Mirrors the mockup's `.marker-pulse` CSS keyframe: a ring that scales up
/// and fades out on a loop behind the avatar/dot it surrounds.
class PulsingMarker extends StatefulWidget {
  final Widget child;
  final Color pulseColor;
  final double size;

  const PulsingMarker({
    super.key,
    required this.child,
    required this.pulseColor,
    this.size = 48,
  });

  @override
  State<PulsingMarker> createState() => _PulsingMarkerState();
}

class _PulsingMarkerState extends State<PulsingMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 1.6,
      height: widget.size * 1.6,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              final scale = 0.7 + (0.6 * t);
              final opacity = (1 - t).clamp(0.0, 1.0) * 0.5;
              return Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: widget.pulseColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
          widget.child,
        ],
      ),
    );
  }
}
