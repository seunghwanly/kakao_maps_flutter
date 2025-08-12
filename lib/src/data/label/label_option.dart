import 'package:kakao_maps_flutter/src/base/data.dart';

import '../lat_lng/lat_lng.dart';

/// Configuration for a label (marker) to be displayed on the map.
///
/// Contains the label's identifier, position, and optional image data.
class LabelOption extends Data {
  /// Creates a new LabelOption with the specified parameters.
  ///
  /// The [id] is a unique identifier for this label.
  /// The [latLng] specifies the geographic position of the label.
  const LabelOption({
    required this.id,
    required this.latLng,
    this.styleId,
    this.rank,
    this.text,
  });

  /// The unique identifier for this label.
  final String id;

  /// The geographic position where this label should be displayed.
  final LatLng latLng;

  /// 스타일 사전 등록 방식 사용 시 참조할 스타일 ID
  ///
  /// iOS의 `PoiStyle`, Android의 `LabelStyles`에 해당하며, 사전에 등록된 스타일을 참조합니다.
  /// 제공되면 플랫폼 단에서 이 `styleId`를 우선 사용합니다.
  final String? styleId;

  /// 지도 렌더링 순위
  ///
  /// [rank] 값이 높을수록 높은 우선순위를 가집니다.
  /// - Android: LabelOption 렌더링 순위
  /// - iOS: PoiOption 렌더링 순위
  final int? rank;

  /// 텍스트
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
