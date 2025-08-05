import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
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
  /// The [base64EncodedImage] is optional image data encoded in base64.
  const LabelOption({
    required this.id,
    required this.latLng,
    required this.base64EncodedImage,
    this.rank,
    this.text,
    this.textColor,
    this.strokeThickness,
    this.strokeColor,
    this.textSize,
  });

  /// Creates a LabelOption from raw image bytes.
  ///
  /// The [imageBytes] will be automatically encoded to base64.
  /// This is a convenience constructor for creating labels with image data.
  factory LabelOption.fromImageBytes({
    required String id,
    required LatLng latLng,
    required Uint8List imageBytes,
    int? rank,
  }) =>
      LabelOption(
        id: id,
        latLng: latLng,
        base64EncodedImage: base64.encode(imageBytes),
        rank: rank,
      );

  /// The unique identifier for this label.
  final String id;

  /// The geographic position where this label should be displayed.
  final LatLng latLng;

  /// The base64-encoded image data for this label's icon.
  ///
  /// If null, a default marker icon will be used.
  final String? base64EncodedImage;

  /// 지도 렌더링 순위
  ///
  /// [rank] 값이 높을수록 높은 우선순위를 가집니다.
  /// - Android: LabelOption 렌더링 순위
  /// - iOS: PoiOption 렌더링 순위
  final int? rank;

  /// 텍스트
  final String? text;

  /// 텍스트 색상
  final Color? textColor;

  /// 텍스트 테두리 두께
  final int? strokeThickness;

  /// 텍스트 테두리 색상
  final Color? strokeColor;

  /// 텍스트 크기
  final int? textSize;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'latLng': latLng.toJson(),
        'base64EncodedImage': base64EncodedImage,
        'rank': rank,
        'text': text,
        'textColor': textColor?.toARGB32(),
        'strokeThickness': strokeThickness,
        'strokeColor': strokeColor?.toARGB32(),
        'textSize': textSize,
      };
}
