import 'package:latlong2/latlong.dart';

enum RouteStatus { idle, loading, success, error }

class RouteState {
  final LatLng? originLatLng;
  final LatLng? destinationLatLng;
  final String originAddress;
  final String destinationAddress;
  final List<LatLng> polylinePoints;
  final double? distanceMeters;
  final double? durationSeconds;
  final RouteStatus status;
  final String? errorMessage;

  const RouteState({
    this.originLatLng,
    this.destinationLatLng,
    this.originAddress = '',
    this.destinationAddress = '',
    this.polylinePoints = const [],
    this.distanceMeters,
    this.durationSeconds,
    this.status = RouteStatus.idle,
    this.errorMessage,
  });

  RouteState copyWith({
    LatLng? originLatLng,
    LatLng? destinationLatLng,
    String? originAddress,
    String? destinationAddress,
    List<LatLng>? polylinePoints,
    double? distanceMeters,
    double? durationSeconds,
    RouteStatus? status,
    String? errorMessage,
  }) =>
      RouteState(
        originLatLng: originLatLng ?? this.originLatLng,
        destinationLatLng: destinationLatLng ?? this.destinationLatLng,
        originAddress: originAddress ?? this.originAddress,
        destinationAddress: destinationAddress ?? this.destinationAddress,
        polylinePoints: polylinePoints ?? this.polylinePoints,
        distanceMeters: distanceMeters ?? this.distanceMeters,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  RouteState get cleared => const RouteState();
}
