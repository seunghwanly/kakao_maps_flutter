import 'package:kakao_maps_flutter/src/base/data.dart';

import '../lat_lng/lat_lng.dart';

class LabelClickEvent extends Data {
  const LabelClickEvent({
    required this.labelId,
    required this.latLng,
    this.layerId,
  });

  factory LabelClickEvent.fromJson(Map<String, Object?> json) =>
      LabelClickEvent(
        labelId: json['labelId']! as String,
        latLng: LatLng.fromJson(json['latLng']! as Map<String, Object?>),
        layerId: json['layerId'] as String?,
      );

  final String labelId;

  final LatLng latLng;

  final String? layerId;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'labelId': labelId,
        'latLng': latLng.toJson(),
        'layerId': layerId,
      };
}
