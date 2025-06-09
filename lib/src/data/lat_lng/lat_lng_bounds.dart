import 'package:kakao_maps_flutter/src/base/data.dart';

import 'lat_lng.dart';

class LatLngBounds extends Data {
  const LatLngBounds({
    required this.southwest,
    required this.northeast,
  });

  factory LatLngBounds.fromJson(Map<String, Object?> json) {
    return LatLngBounds(
      southwest: LatLng.fromJson(json['southwest']! as Map<String, Object?>),
      northeast: LatLng.fromJson(json['northeast']! as Map<String, Object?>),
    );
  }

  @override
  Map<String, Object?> toJson() => {
        'southwest': southwest.toJson(),
        'northeast': northeast.toJson(),
      };

  final LatLng southwest;

  final LatLng northeast;
}
