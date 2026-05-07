import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/map_provider.dart';
import '../providers/location_provider.dart';

class FabCluster extends ConsumerWidget {
  const FabCluster({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return FloatingActionButton(
      heroTag: 'fab_location',
      onPressed: () => _centerOnLocation(ref),
      backgroundColor: cs.primaryContainer,
      foregroundColor: cs.onPrimaryContainer,
      tooltip: 'My location',
      elevation: 4,
      child: const Icon(Icons.my_location),
    );
  }

  void _centerOnLocation(WidgetRef ref) {
    final ll = ref.read(locationProvider).valueOrNull?.latLng;
    if (ll == null) return;
    ref.read(mapControllerProvider).move(ll, 15.0);
  }
}
