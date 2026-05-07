import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/route_state.dart';
import '../providers/route_provider.dart';

class RouteInfoCard extends ConsumerWidget {
  const RouteInfoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(routeProvider);
    final visible = route.status == RouteStatus.success;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 1.2),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Driving icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.directions_car,
                      color: cs.onPrimaryContainer, size: 20),
                ),
                const SizedBox(width: 12),

                // Route details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            _formatDistance(route.distanceMeters),
                            style: tt.titleMedium?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: cs.onSurfaceVariant,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDuration(route.durationSeconds),
                            style: tt.titleMedium?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (route.originAddress.isNotEmpty ||
                          route.destinationAddress.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '${route.originAddress} → ${route.destinationAddress}',
                            style: tt.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),

                // Clear button
                IconButton(
                  onPressed: () =>
                      ref.read(routeProvider.notifier).clearRoute(),
                  icon: Icon(Icons.close,
                      color: cs.onSurfaceVariant, size: 20),
                  tooltip: 'Clear route',
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                      minWidth: 40, minHeight: 40),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDistance(double? meters) {
    if (meters == null) return '';
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.toStringAsFixed(0)} m';
  }

  String _formatDuration(double? seconds) {
    if (seconds == null) return '';
    final mins = (seconds / 60).round();
    if (mins < 60) return '$mins min';
    final h = mins ~/ 60;
    final m = mins % 60;
    return '${h}h ${m}min';
  }
}
