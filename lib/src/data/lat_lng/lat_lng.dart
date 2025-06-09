import 'package:kakao_maps_flutter/src/base/data.dart';

class LatLng extends Data {
  const LatLng({
    required this.latitude,
    required this.longitude,
  });

  factory LatLng.fromJson(Map<String, Object?> json) => LatLng(
        latitude: json['latitude']! as double,
        longitude: json['longitude']! as double,
      );

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'latitude': latitude,
        'longitude': longitude,
      };

  final double latitude;

  final double longitude;
}
