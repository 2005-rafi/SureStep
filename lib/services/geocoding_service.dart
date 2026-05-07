import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class GeocodingService {
  Future<LatLng?> addressToLatLng(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isEmpty) return null;
      return LatLng(locations.first.latitude, locations.first.longitude);
    } catch (_) {
      return null;
    }
  }

  Future<String?> latLngToAddress(LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      return [p.street, p.locality, p.country]
          .where((s) => s != null && s.isNotEmpty)
          .join(', ');
    } catch (_) {
      return null;
    }
  }
}
