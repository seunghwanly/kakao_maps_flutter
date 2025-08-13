import 'package:kakao_maps_flutter/src/base/data.dart';

/// Geographic coordinate
/// [EN]
/// - Latitude/longitude pair for map locations
///
/// [KO]
/// - 지도 위치를 나타내는 위도/경도 쌍
class LatLng extends Data {
  /// Create coordinate
  /// [EN]
  /// - [latitude] range -90..90, [longitude] range -180..180
  ///
  /// [KO]
  /// - [latitude] 범위 -90..90, [longitude] 범위 -180..180
  const LatLng({
    required this.latitude,
    required this.longitude,
  });

  /// From JSON map
  factory LatLng.fromJson(Map<String, Object?> json) {
    final latRaw = json['latitude'];
    final lngRaw = json['longitude'];

    if (latRaw is! num || lngRaw is! num) {
      throw ArgumentError('Invalid LatLng json: $json');
    }

    return LatLng(
      latitude: latRaw.toDouble(),
      longitude: lngRaw.toDouble(),
    );
  }

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'latitude': latitude,
        'longitude': longitude,
      };

  /// Latitude in degrees
  final double latitude;

  /// Longitude in degrees
  final double longitude;
}
