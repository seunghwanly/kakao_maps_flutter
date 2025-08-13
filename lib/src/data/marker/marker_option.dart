import 'package:kakao_maps_flutter/src/base/data.dart';

import '../lat_lng/lat_lng.dart';

/// Marker option
/// [EN]
/// - Identifier, position and optional style/text for markers
///
/// [KO]
/// - 마커의 식별자, 위치와 선택적 스타일/텍스트 옵션
class MarkerOption extends Data {
  /// Create marker option
  /// [EN]
  /// - [id]: unique identifier, [latLng]: position
  ///
  /// [KO]
  /// - [id]: 고유 식별자, [latLng]: 위치
  const MarkerOption({
    required this.id,
    required this.latLng,
    this.styleId,
    this.rank,
    this.text,
  });

  /// Unique identifier
  final String id;

  /// Geographic position
  final LatLng latLng;

  /// Pre-registered style id
  /// [EN]
  /// - References registered styles (iOS `PoiStyle`, Android `LabelStyles`)
  ///
  /// [KO]
  /// - 사전 등록된 스타일 참조(iOS `PoiStyle`, Android `LabelStyles`)
  final String? styleId;

  /// Rendering order
  /// [EN]
  /// - Higher value renders above
  ///
  /// [KO]
  /// - 값이 클수록 우선 렌더링
  final int? rank;

  /// Text content
  final String? text;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'latLng': latLng.toJson(),
        'styleId': styleId,
        'rank': rank,
        'text': text,
      };
}
