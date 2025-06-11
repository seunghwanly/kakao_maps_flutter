import 'package:kakao_maps_flutter/src/base/data.dart';

import 'lat_lng.dart';

/// A rectangular geographic area defined by southwest and northeast corners.
///
/// Used to specify regions or bounds on the map.
class LatLngBounds extends Data {
  /// Creates a new LatLngBounds with the specified corner coordinates.
  ///
  /// The [southwest] corner defines the lower-left boundary.
  /// The [northeast] corner defines the upper-right boundary.
  const LatLngBounds({
    required this.southwest,
    required this.northeast,
  });

  /// Creates a LatLngBounds instance from a JSON map.
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
