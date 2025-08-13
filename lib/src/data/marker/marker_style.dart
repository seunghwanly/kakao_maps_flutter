import 'package:flutter/foundation.dart';
import 'package:kakao_maps_flutter/src/base/data.dart';

/// Marker text style
/// [EN]
/// - [fontSize]: px, [fontColorArgb]: ARGB32, [strokeThickness]: px, [strokeColorArgb]: ARGB32
///
/// [KO]
/// - [fontSize]: px, [fontColorArgb]: ARGB32, [strokeThickness]: px, [strokeColorArgb]: ARGB32
class MarkerTextStyle extends Data {
  /// Create text style
  const MarkerTextStyle({
    required this.fontSize,
    required this.fontColorArgb,
    this.strokeThickness,
    this.strokeColorArgb,
  });

  /// Font size (px)
  final int fontSize;

  /// Font color (ARGB32)
  final int fontColorArgb;

  /// Stroke thickness (px)
  final int? strokeThickness;

  /// Stroke color (ARGB32)
  final int? strokeColorArgb;

  /// Serialize for platform channel
  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'fontSize': fontSize,
        'fontColor': fontColorArgb,
        'strokeThickness': strokeThickness,
        'strokeColor': strokeColorArgb,
      };
}

/// Per-level marker style
/// [EN]
/// - Icon/text styles per zoom level (iOS: PerLevelPoiStyle)
///
/// [KO]
/// - 줌 레벨별 아이콘/텍스트 스타일(iOS: PerLevelPoiStyle), Android는 첫 항목 우선
class MarkerPerLevelStyle extends Data {
  /// Create per-level style
  const MarkerPerLevelStyle({
    required this.bytes,
    this.textStyle,
    this.level,
  });

  /// From raw bytes
  factory MarkerPerLevelStyle.fromBytes({
    required Uint8List bytes,
    MarkerTextStyle? textStyle,
    int? level,
  }) =>
      MarkerPerLevelStyle(
        bytes: bytes,
        textStyle: textStyle,
        level: level,
      );

  /// Icon bytes (Base64 supported)
  final Uint8List bytes;

  /// Text style (optional)
  final MarkerTextStyle? textStyle;

  /// Target level (iOS only)
  final int? level; // iOS에서만 사용됨

  /// Serialize representation
  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'icon': bytes,
        'textStyle': textStyle?.toJson(),
        'level': level,
      };
}

/// Marker style bundle
/// [EN]
/// - Bundle multiple per-level styles under a single [styleId]
///
/// [KO]
/// - 하나의 [styleId] 아래 여러 레벨별 스타일 묶음
class MarkerStyle extends Data {
  /// Create style bundle
  const MarkerStyle({
    required this.styleId,
    required this.perLevels,
  });

  /// Unique style id (cross-platform)
  final String styleId;

  /// Per-level styles
  final List<MarkerPerLevelStyle> perLevels;

  /// Serialize representation
  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'styleId': styleId,
        'perLevels': perLevels.map((e) => e.toJson()).toList(),
      };
}
