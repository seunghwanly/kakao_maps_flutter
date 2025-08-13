import 'package:kakao_maps_flutter/src/base/data.dart';

import '../lat_lng/lat_lng.dart';

/// Camera update configuration
/// [EN]
/// - Position, zoom, tilt, rotation and fit options for view updates
///
/// [KO]
/// - 뷰 갱신을 위한 위치, 확대, 틸트, 회전 및 맞춤 옵션
class CameraUpdate extends Data {
  /// Create update
  /// [EN]
  /// - Optional parameters default to no-op; [type] is internal hint
  ///
  /// [KO]
  /// - 미지정 시 변경 없음; [type]은 내부용 힌트
  const CameraUpdate({
    this.position,
    this.zoomLevel = -1,
    this.tiltAngle = -1.0,
    this.rotationAngle = -1.0,
    this.height = -1.0,
    this.fitPoints,
    this.padding = -1,
    this.type = -1,
  });

  /// Move to position
  /// [EN]
  /// - Focus on [position] with default zoom 17
  ///
  /// [KO]
  /// - [position]으로 이동하며 기본 줌 17 적용
  factory CameraUpdate.fromLatLng(LatLng position) => CameraUpdate(
        position: position,
        type: 0,
        zoomLevel: 17,
      );

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'position': position?.toJson(),
        'zoomLevel': zoomLevel,
        'tiltAngle': tiltAngle,
        'rotationAngle': rotationAngle,
        'height': height,
        'fitPoints': fitPoints?.map((e) => e.toJson()).toList(),
        'padding': padding,
        'type': type,
      };

  /// The target geographic position for the camera.
  final LatLng? position;

  /// The target zoom level for the camera.
  ///
  /// A value of -1 indicates no change.
  final int zoomLevel;

  /// The target tilt angle for the camera in degrees.
  ///
  /// A value of -1.0 indicates no change.
  final double tiltAngle;

  /// The target rotation angle for the camera in degrees.
  ///
  /// A value of -1.0 indicates no change.
  final double rotationAngle;

  /// The target height for the camera.
  ///
  /// A value of -1.0 indicates no change.
  final double height;

  /// List of points to fit within the camera view.
  ///
  /// When provided, the camera will adjust to show all these points.
  final List<LatLng>? fitPoints;

  /// The padding to apply when fitting points.
  ///
  /// A value of -1 indicates no padding.
  final int padding;

  /// The internal type identifier for this camera update.
  final int type;
}
