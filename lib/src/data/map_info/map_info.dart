import 'package:kakao_maps_flutter/src/base/data.dart';

/// Information about the current state of the map.
///
/// Contains details about zoom level, rotation, and tilt angles.
class MapInfo extends Data {
  /// Creates a new MapInfo with the specified parameters.
  ///
  /// The [zoomLevel] indicates the current zoom level of the map.
  /// The [rotation] is the rotation angle in degrees.
  /// The [tilt] is the tilt angle in degrees.
  const MapInfo({
    required this.zoomLevel,
    required this.rotation,
    required this.tilt,
  });

  /// Creates a MapInfo instance from a JSON map.
  factory MapInfo.fromJson(Map<String, Object?> json) => MapInfo(
        zoomLevel: json['zoomLevel']! as int,
        rotation: (json['rotation']! as num).toDouble(),
        tilt: (json['tilt']! as num).toDouble(),
      );

  @override
  Map<String, Object?> toJson() => {
        'zoomLevel': zoomLevel,
        'rotation': rotation,
        'tilt': tilt,
      };

  /// The current zoom level of the map.
  final int zoomLevel;

  /// The current rotation angle of the map in degrees.
  final double rotation;

  /// The current tilt angle of the map in degrees.
  final double tilt;
}
