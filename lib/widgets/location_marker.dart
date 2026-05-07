import 'package:flutter/material.dart';

class LocationMarker extends StatefulWidget {
  final bool isOnline;
  const LocationMarker({super.key, required this.isOnline});

  @override
  State<LocationMarker> createState() => _LocationMarkerState();
}

class _LocationMarkerState extends State<LocationMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulse = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(LocationMarker old) {
    super.didUpdateWidget(old);
    if (widget.isOnline && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isOnline && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = widget.isOnline ? cs.primary : cs.outline;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.isOnline)
              Container(
                width: 40 * _pulse.value,
                height: 40 * _pulse.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(
                    alpha: 0.3 * (1 - _pulse.value + 0.5),
                  ),
                ),
              ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(color: cs.surface, width: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
