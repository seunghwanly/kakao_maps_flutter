import 'package:kakao_maps_flutter/src/base/data.dart';

import '../lat_lng/lat_lng.dart';

/// Label click event
/// [EN]
/// - Identifier, position and optional layer id of clicked label
///
/// [KO]
/// - 클릭된 라벨의 식별자, 위치, 선택적 레이어 id
class LabelClickEvent extends Data {
  /// Create event
  /// [EN]
  /// - [labelId]: clicked label id, [latLng]: click position, [layerId]: optional
  ///
  /// [KO]
  /// - [labelId]: 클릭된 라벨 id, [latLng]: 클릭 위치, [layerId]: 선택 값
  const LabelClickEvent({
    required this.labelId,
    required this.latLng,
    this.layerId,
  });

  /// From JSON map
  factory LabelClickEvent.fromJson(Map<String, Object?> json) =>
      LabelClickEvent(
        labelId: json['labelId']! as String,
        latLng: LatLng.fromJson(json['latLng']! as Map<String, Object?>),
        layerId: json['layerId'] as String?,
      );

  /// Clicked label id
  final String labelId;

  /// Click position
  final LatLng latLng;

  /// Layer id (optional)
  final String? layerId;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'labelId': labelId,
        'latLng': latLng.toJson(),
        'layerId': layerId,
      };
}
