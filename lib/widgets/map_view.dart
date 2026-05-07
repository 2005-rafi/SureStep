import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../providers/location_provider.dart';
import '../providers/map_provider.dart';
import '../providers/route_provider.dart';
import '../providers/map_style_provider.dart';
import '../providers/route_overlay_provider.dart';
import '../models/route_state.dart';
import 'location_marker.dart';
import 'route_overlay.dart';
import 'route_info_card.dart';
import 'fab_cluster.dart';
import 'floating_app_bar.dart';
import 'route_search_overlay.dart';

class MapView extends ConsumerStatefulWidget {
  const MapView({super.key});

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  bool _centeredOnce = false;
  MapStyle? _prevStyle;

  static const _defaultCenter = LatLng(20.5937, 78.9629);

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(locationProvider);
    final mapController = ref.watch(mapControllerProvider);
    final overlayVisible = ref.watch(routeOverlayVisibleProvider);

    // Center map on first location fix
    locationAsync.whenData((loc) {
      if (!_centeredOnce && loc.latLng != null) {
        _centeredOnce = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          mapController.move(loc.latLng!, 15.0);
        });
      }
    });

    // Fit route bounds when route succeeds
    ref.listen(routeProvider, (prev, next) {
      if (next.status == RouteStatus.success &&
          next.polylinePoints.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final bounds = LatLngBounds.fromPoints(next.polylinePoints);
          mapController.fitCamera(
            CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.all(60),
            ),
          );
        });
      }
    });

    final locationState = locationAsync.valueOrNull;
    final isOnline = locationState?.isOnline ?? false;

    return Scaffold(
      body: Stack(
        children: [
          // ── Layer 0: Map canvas ──────────────────────────────────────────
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 5,
              onLongPress: (tapPos, latLng) => _onLongPress(latLng),
              onTap: overlayVisible
                  ? (tapPos, latLng) => _dismissOverlay()
                  : null,
            ),
            children: [
              // Animated tile layer — only this Consumer rebuilds on style change
              Consumer(
                builder: (context, ref, _) {
                  final style = ref.watch(mapStyleProvider);
                  final styleChanged = _prevStyle != null && _prevStyle != style;
                  _prevStyle = style;

                  return AnimatedOpacity(
                    opacity: 1.0,
                    duration: Duration(
                        milliseconds: styleChanged ? 400 : 0),
                    child: TileLayer(
                      key: ValueKey(style),
                      urlTemplate: style.tileUrl(),
                      userAgentPackageName: 'com.example.surestep',
                      retinaMode: false,
                    ),
                  );
                },
              ),

              // Location marker
              if (locationState?.latLng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: locationState!.latLng!,
                      width: 40,
                      height: 40,
                      child: LocationMarker(isOnline: isOnline),
                    ),
                  ],
                ),

              // Route polyline + pins
              const RouteOverlay(),
            ],
          ),

          // ── Layer 1: Route summary card (bottom) ─────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: const RouteInfoCard(),
            ),
          ),

          // ── Layer 2: Floating utility app bar (top) ──────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: FloatingAppBar(),
                ),

                // ── Layer 3: Route search overlay (transient) ─────────────
                if (overlayVisible) const RouteSearchOverlay(),
              ],
            ),
          ),

          // ── Layer 2: FAB cluster (bottom-right) ──────────────────────────
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 96,
            child: const FabCluster(),
          ),
        ],
      ),
    );
  }

  void _dismissOverlay() {
    ref.read(routeOverlayVisibleProvider.notifier).state = false;
  }

  void _onLongPress(LatLng latLng) async {
    final geo = ref.read(geocodingServiceProvider);
    final address = await geo.latLngToAddress(latLng);
    final label = address ?? '${latLng.latitude.toStringAsFixed(4)}, '
        '${latLng.longitude.toStringAsFixed(4)}';
    final route = ref.read(routeProvider);

    if (route.originLatLng == null) {
      await ref
          .read(routeProvider.notifier)
          .setOriginLatLng(latLng, label);
    } else {
      await ref.read(routeProvider.notifier).setDestination(label);
    }
  }
}
