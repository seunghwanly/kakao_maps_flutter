import 'package:kakao_maps_flutter/src/base/data.dart';

import '../lat_lng/lat_lng.dart';

class CameraUpdate extends Data {
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

  final LatLng? position;

  final int zoomLevel;

  final double tiltAngle;

  final double rotationAngle;

  final double height;

  final List<LatLng>? fitPoints;

  final int padding;

  final int type;
}
