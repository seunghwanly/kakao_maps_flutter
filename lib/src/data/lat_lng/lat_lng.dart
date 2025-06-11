import 'package:kakao_maps_flutter/src/base/data.dart';

/// A geographic coordinate with latitude and longitude.
///
/// Used to specify locations on the map.
class LatLng extends Data {
  /// Creates a new LatLng instance with the specified coordinates.
  ///
  /// The [latitude] should be between -90 and 90 degrees.
  /// The [longitude] should be between -180 and 180 degrees.
  const LatLng({
    required this.latitude,
    required this.longitude,
  });

  /// Creates a LatLng instance from a JSON map.
  factory LatLng.fromJson(Map<String, Object?> json) => LatLng(
        latitude: json['latitude']! as double,
        longitude: json['longitude']! as double,
      );

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'latitude': latitude,
        'longitude': longitude,
      };

  /// The latitude coordinate in degrees.
  ///
  /// Valid range is -90 to 90 degrees.
  final double latitude;

  /// The longitude coordinate in degrees.
  ///
  /// Valid range is -180 to 180 degrees.
  final double longitude;
}
