import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import '../models/route_state.dart';
import '../services/geocoding_service.dart';
import '../services/routing_service.dart';

final geocodingServiceProvider =
    Provider<GeocodingService>((_) => GeocodingService());

final routingServiceProvider =
    Provider<RoutingService>((_) => RoutingService());

final routeProvider =
    StateNotifierProvider<RouteNotifier, RouteState>(RouteNotifier.new);

class RouteNotifier extends StateNotifier<RouteState> {
  final Ref _ref;

  RouteNotifier(this._ref) : super(const RouteState());

  /// Sets origin directly from a known LatLng (e.g. current GPS position).
  Future<void> setOriginLatLng(latlong2.LatLng ll, String label) async {
    state = state.copyWith(originLatLng: ll, originAddress: label);
    if (state.destinationLatLng != null) await _fetchRoute();
  }

  Future<void> setOrigin(String address) async {
    final geo = _ref.read(geocodingServiceProvider);
    final ll = await geo.addressToLatLng(address);
    if (ll == null) {
      state = state.copyWith(
        status: RouteStatus.error,
        errorMessage: 'Could not find origin: $address',
      );
      return;
    }
    state = state.copyWith(originLatLng: ll, originAddress: address);
    if (state.destinationLatLng != null) await _fetchRoute();
  }

  Future<void> setDestination(String address) async {
    final geo = _ref.read(geocodingServiceProvider);
    final ll = await geo.addressToLatLng(address);
    if (ll == null) {
      state = state.copyWith(
        status: RouteStatus.error,
        errorMessage: 'Could not find destination: $address',
      );
      return;
    }
    state = state.copyWith(destinationLatLng: ll, destinationAddress: address);
    if (state.originLatLng != null) await _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    state = state.copyWith(status: RouteStatus.loading);
    final routing = _ref.read(routingServiceProvider);
    final result = await routing.fetchRoute(
      state.originLatLng!,
      state.destinationLatLng!,
    );
    if (result == null) {
      state = state.copyWith(
        status: RouteStatus.error,
        errorMessage: 'No route found. Check your connection.',
      );
    } else {
      state = state.copyWith(
        polylinePoints: result.points,
        distanceMeters: result.distanceMeters,
        durationSeconds: result.durationSeconds,
        status: RouteStatus.success,
      );
    }
  }

  void clearRoute() => state = state.cleared;
}
