import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../models/route_state.dart';
import '../providers/route_provider.dart';

class RouteOverlay extends ConsumerWidget {
  const RouteOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(routeProvider);
    final cs = Theme.of(context).colorScheme;

    if (route.status != RouteStatus.success) return const SizedBox.shrink();

    final markers = <Marker>[];
    if (route.originLatLng != null) {
      markers.add(_pin(route.originLatLng!, cs.secondary, Icons.trip_origin));
    }
    if (route.destinationLatLng != null) {
      markers.add(_pin(route.destinationLatLng!, cs.tertiary, Icons.location_on));
    }

    return Stack(
      children: [
        PolylineLayer(
          polylines: [
            Polyline(
              points: route.polylinePoints,
              strokeWidth: 5,
              color: cs.primary,
            ),
          ],
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }

  Marker _pin(LatLng point, Color color, IconData icon) => Marker(
        point: point,
        width: 36,
        height: 36,
        child: Icon(icon, color: color, size: 36),
      );
}
