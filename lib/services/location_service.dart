import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_state.dart';

class LocationService {
  static const _latKey = 'last_lat';
  static const _lngKey = 'last_lng';

  Future<bool> requestPermission() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.whileInUse ||
        perm == LocationPermission.always;
  }

  Future<bool> get isPermanentlyDenied async {
    final perm = await Geolocator.checkPermission();
    return perm == LocationPermission.deniedForever;
  }

  Future<LatLng?> getLastKnownPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_latKey);
    final lng = prefs.getDouble(_lngKey);
    if (lat != null && lng != null) return LatLng(lat, lng);
    return null;
  }

  Future<void> cachePosition(LatLng pos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latKey, pos.latitude);
    await prefs.setDouble(_lngKey, pos.longitude);
  }

  Stream<LocationState> get positionStream async* {
    final granted = await requestPermission();
    if (!granted) {
      final cached = await getLastKnownPosition();
      yield LocationState(
        latLng: cached,
        isOnline: false,
        timestamp: DateTime.now(),
      );
      return;
    }

    // Emit initial position quickly
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      final ll = LatLng(pos.latitude, pos.longitude);
      await cachePosition(ll);
      yield LocationState(
        latLng: ll,
        isOnline: true,
        timestamp: DateTime.now(),
        accuracy: pos.accuracy,
      );
    } catch (_) {
      final cached = await getLastKnownPosition();
      yield LocationState(
        latLng: cached,
        isOnline: false,
        timestamp: DateTime.now(),
      );
    }

    // Continuous stream
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).asyncMap((pos) async {
      final ll = LatLng(pos.latitude, pos.longitude);
      await cachePosition(ll);
      return LocationState(
        latLng: ll,
        isOnline: true,
        timestamp: DateTime.now(),
        accuracy: pos.accuracy,
      );
    }).handleError((_) async {
      final cached = await getLastKnownPosition();
      return LocationState(
        latLng: cached,
        isOnline: false,
        timestamp: DateTime.now(),
      );
    });
  }
}
