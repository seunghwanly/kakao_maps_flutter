import 'package:kakao_maps_flutter/src/base/data.dart';

import '../lat_lng/lat_lng.dart';

/// Camera configuration for updating the map's view.
///
/// Defines camera position, zoom level, tilt, rotation, and other view settings.
class CameraUpdate extends Data {
  /// Creates a new CameraUpdate with the specified parameters.
  ///
  /// All parameters are optional and have default values indicating no change.
  /// The [type] parameter is used internally to determine the update type.
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

  /// Creates a CameraUpdate that moves to the specified position.
  ///
  /// Sets the camera to focus on the given [position] with a default zoom level of 17.
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
