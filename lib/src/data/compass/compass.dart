import 'dart:ui';

import 'package:kakao_maps_flutter/src/base/data.dart';

/// Compass alignment options
/// [EN]
/// - Predefined positions for placing compass on map
///
/// [KO]
/// - 지도 내 나침반 배치용 사전 정의 위치
enum CompassAlignment {
  /// Top-left corner
  topLeft,

  /// Top-right corner
  topRight,

  /// Bottom-left corner
  bottomLeft,

  /// Bottom-right corner
  bottomRight,

  /// Center
  center,

  /// Top center
  topCenter,

  /// Bottom center
  bottomCenter,

  /// Left center
  leftCenter,

  /// Right center
  rightCenter,
}

/// Compass configuration
/// [EN]
/// - Shows heading and provides back-to-north interaction
///
/// [KO]
/// - 현재 방위를 표시하고 북쪽으로 되돌리기 기능 제공
class Compass extends Data {
  /// Create configuration
  /// [EN]
  /// - [isBackToNorthOnClick]: reset heading, [alignment]: position, [offset]: extra offset
  ///
  /// [KO]
  /// - [isBackToNorthOnClick]: 북쪽으로 복귀, [alignment]: 위치, [offset]: 추가 오프셋
  const Compass({
    this.isBackToNorthOnClick = true,
    this.alignment = CompassAlignment.topRight,
    this.offset = const Offset(0, 0),
  });

  /// From JSON map
  factory Compass.fromJson(Map<String, Object?> json) => Compass(
        isBackToNorthOnClick: json['isBackToNorthOnClick'] as bool? ?? true,
        alignment: _alignmentFromString(json['alignment'] as String?),
        offset: _offsetFromJson(json['offset'] as Map<String, Object?>?),
      );

  @override
  Map<String, Object?> toJson() => {
        'isBackToNorthOnClick': isBackToNorthOnClick,
        'alignment': _alignmentToString(alignment),
        'offset': _offsetToJson(offset),
      };

  /// Back-to-north on click
  final bool isBackToNorthOnClick;

  /// Alignment position
  final CompassAlignment alignment;

  /// Pixel offset
  final Offset offset;

  static CompassAlignment _alignmentFromString(String? value) {
    switch (value) {
      case 'topLeft':
        return CompassAlignment.topLeft;
      case 'topRight':
        return CompassAlignment.topRight;
      case 'bottomLeft':
        return CompassAlignment.bottomLeft;
      case 'bottomRight':
        return CompassAlignment.bottomRight;
      case 'center':
        return CompassAlignment.center;
      case 'topCenter':
        return CompassAlignment.topCenter;
      case 'bottomCenter':
        return CompassAlignment.bottomCenter;
      case 'leftCenter':
        return CompassAlignment.leftCenter;
      case 'rightCenter':
        return CompassAlignment.rightCenter;
      default:
        return CompassAlignment.topRight;
    }
  }

  static String _alignmentToString(CompassAlignment alignment) {
    switch (alignment) {
      case CompassAlignment.topLeft:
        return 'topLeft';
      case CompassAlignment.topRight:
        return 'topRight';
      case CompassAlignment.bottomLeft:
        return 'bottomLeft';
      case CompassAlignment.bottomRight:
        return 'bottomRight';
      case CompassAlignment.center:
        return 'center';
      case CompassAlignment.topCenter:
        return 'topCenter';
      case CompassAlignment.bottomCenter:
        return 'bottomCenter';
      case CompassAlignment.leftCenter:
        return 'leftCenter';
      case CompassAlignment.rightCenter:
        return 'rightCenter';
    }
  }

  static Offset _offsetFromJson(Map<String, Object?>? json) {
    if (json == null) return const Offset(0, 0);
    return Offset(
      (json['dx'] as num?)?.toDouble() ?? 0,
      (json['dy'] as num?)?.toDouble() ?? 0,
    );
  }

  static Map<String, Object?> _offsetToJson(Offset offset) => {
        'dx': offset.dx,
        'dy': offset.dy,
      };
}
