import 'package:kakao_maps_flutter/src/base/data.dart';

/// Map info snapshot
/// [EN]
/// - Current zoom level, rotation and tilt angles
///
/// [KO]
/// - 현재 줌 레벨, 회전 각도, 틸트 각도 정보
class MapInfo extends Data {
  /// Create info
  /// [EN]
  /// - [zoomLevel], [rotation] in degrees, [tilt] in degrees
  ///
  /// [KO]
  /// - [zoomLevel], [rotation] 각도 단위, [tilt] 각도 단위
  const MapInfo({
    required this.zoomLevel,
    required this.rotation,
    required this.tilt,
  });

  /// From JSON map
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

  /// Current zoom level
  final int zoomLevel;

  /// Rotation angle (deg)
  final double rotation;

  /// Tilt angle (deg)
  final double tilt;
}
