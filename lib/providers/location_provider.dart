import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/location_state.dart';
import '../services/location_service.dart';

final locationServiceProvider = Provider<LocationService>((_) => LocationService());

final locationProvider = StreamProvider<LocationState>((ref) {
  final service = ref.watch(locationServiceProvider);
  return service.positionStream;
});
