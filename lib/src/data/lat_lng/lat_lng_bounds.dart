import 'package:kakao_maps_flutter/src/base/data.dart';

import 'lat_lng.dart';

/// Geographic bounds rectangle
/// [EN]
/// - Southwest and northeast corners defining a rectangular region
///
/// [KO]
/// - 남서/북동 꼭짓점으로 정의되는 직사각형 영역
class LatLngBounds extends Data {
  /// Create bounds
  /// [EN]
  /// - [southwest]: lower-left corner, [northeast]: upper-right corner
  ///
  /// [KO]
  /// - [southwest]: 좌하단 좌표, [northeast]: 우상단 좌표
  const LatLngBounds({
    required this.southwest,
    required this.northeast,
  });

  /// From JSON map
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

  /// The southwest corner coordinate of this bounds.
  final LatLng southwest;

  /// The northeast corner coordinate of this bounds.
  final LatLng northeast;
}
