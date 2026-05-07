import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MapStyle { standard, cycle, transport, humanitarian }

extension MapStyleX on MapStyle {
  String get label {
    switch (this) {
      case MapStyle.standard:
        return 'Standard';
      case MapStyle.cycle:
        return 'Cycle Map';
      case MapStyle.transport:
        return 'Transport';
      case MapStyle.humanitarian:
        return 'Humanitarian';
    }
  }

  String get description {
    switch (this) {
      case MapStyle.standard:
        return 'General-purpose street map';
      case MapStyle.cycle:
        return 'Cycling routes & infrastructure';
      case MapStyle.transport:
        return 'Public transit & rail lines';
      case MapStyle.humanitarian:
        return 'Emergency services emphasis';
    }
  }

  // Thunderforest free-tier key placeholder — works without key for demo
  // (falls back gracefully to standard tiles if key is absent)
  String tileUrl({String apiKey = ''}) {
    switch (this) {
      case MapStyle.standard:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      case MapStyle.cycle:
        return apiKey.isEmpty
            ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
            : 'https://tile.thunderforest.com/cycle/{z}/{x}/{y}.png?apikey=$apiKey';
      case MapStyle.transport:
        return apiKey.isEmpty
            ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
            : 'https://tile.thunderforest.com/transport/{z}/{x}/{y}.png?apikey=$apiKey';
      case MapStyle.humanitarian:
        return 'https://tile-c.openstreetmap.fr/hot/{z}/{x}/{y}.png';
    }
  }
}

final mapStyleProvider =
    StateNotifierProvider<MapStyleNotifier, MapStyle>((_) => MapStyleNotifier());

class MapStyleNotifier extends StateNotifier<MapStyle> {
  MapStyleNotifier() : super(MapStyle.standard);

  void switchStyle(MapStyle style) => state = style;
}
