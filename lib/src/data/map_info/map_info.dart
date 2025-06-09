import 'package:kakao_maps_flutter/src/base/data.dart';

class MapInfo extends Data {
  const MapInfo({
    required this.zoomLevel,
    required this.rotation,
    required this.tilt,
  });

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

  final int zoomLevel;

  final double rotation;

  final double tilt;
}
