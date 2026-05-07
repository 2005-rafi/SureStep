import 'package:latlong2/latlong.dart';

class LocationState {
  final LatLng? latLng;
  final bool isOnline;
  final DateTime timestamp;
  final double? accuracy;

  const LocationState({
    this.latLng,
    required this.isOnline,
    required this.timestamp,
    this.accuracy,
  });

  LocationState copyWith({LatLng? latLng, bool? isOnline, double? accuracy}) =>
      LocationState(
        latLng: latLng ?? this.latLng,
        isOnline: isOnline ?? this.isOnline,
        timestamp: DateTime.now(),
        accuracy: accuracy ?? this.accuracy,
      );
}
