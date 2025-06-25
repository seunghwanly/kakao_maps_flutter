/// Event fired when the camera movement ends on the map.
class CameraMoveEndEvent {
  /// Creates a CameraMoveEndEvent from a JSON map.
  factory CameraMoveEndEvent.fromJson(Map<String, dynamic> json) {
    return CameraMoveEndEvent(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      zoomLevel: (json['zoomLevel'] as num).toDouble(),
      tilt: (json['tilt'] as num).toDouble(),
      rotation: (json['rotation'] as num).toDouble(),
    );
  }

  /// Creates a new CameraMoveEndEvent.
  const CameraMoveEndEvent({
    required this.latitude,
    required this.longitude,
    required this.zoomLevel,
    required this.tilt,
    required this.rotation,
  });

  /// Latitude of the camera center.
  final double latitude;

  /// Longitude of the camera center.
  final double longitude;

  /// Zoom level of the camera.
  final double zoomLevel;

  /// Tilt angle of the camera (degrees).
  final double tilt;

  /// Rotation angle of the camera (degrees).
  final double rotation;

  /// Converts this event to a JSON map.
  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'zoomLevel': zoomLevel,
        'tilt': tilt,
        'rotation': rotation,
      };
}
