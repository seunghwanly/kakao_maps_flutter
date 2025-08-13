import 'dart:ui';

import 'package:kakao_maps_flutter/src/base/data.dart';

/// Logo alignment options
/// [EN]
/// - Predefined positions for placing logo on map
///
/// [KO]
/// - 지도 내 로고 배치를 위한 사전 정의 위치
enum LogoAlignment {
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

/// Logo configuration
/// [EN]
/// - Kakao Maps branding placement on the map
///
/// [KO]
/// - 지도 위 로고 배치 설정
class Logo extends Data {
  /// Create configuration
  /// [EN]
  /// - [alignment]: position, [offset]: pixel offset
  ///
  /// [KO]
  /// - [alignment]: 위치, [offset]: 픽셀 오프셋
  const Logo({
    this.alignment = LogoAlignment.bottomLeft,
    this.offset = const Offset(0, 0),
  });

  /// From JSON map
  factory Logo.fromJson(Map<String, Object?> json) => Logo(
        alignment: _alignmentFromString(json['alignment'] as String?),
        offset: _offsetFromJson(json['offset'] as Map<String, Object?>?),
      );

  @override
  Map<String, Object?> toJson() => {
        'alignment': _alignmentToString(alignment),
        'offset': _offsetToJson(offset),
      };

  /// Alignment position
  final LogoAlignment alignment;

  /// Pixel offset
  final Offset offset;

  static LogoAlignment _alignmentFromString(String? value) {
    switch (value) {
      case 'topLeft':
        return LogoAlignment.topLeft;
      case 'topRight':
        return LogoAlignment.topRight;
      case 'bottomLeft':
        return LogoAlignment.bottomLeft;
      case 'bottomRight':
        return LogoAlignment.bottomRight;
      case 'center':
        return LogoAlignment.center;
      case 'topCenter':
        return LogoAlignment.topCenter;
      case 'bottomCenter':
        return LogoAlignment.bottomCenter;
      case 'leftCenter':
        return LogoAlignment.leftCenter;
      case 'rightCenter':
        return LogoAlignment.rightCenter;
      default:
        return LogoAlignment.bottomLeft;
    }
  }

  static String _alignmentToString(LogoAlignment alignment) {
    switch (alignment) {
      case LogoAlignment.topLeft:
        return 'topLeft';
      case LogoAlignment.topRight:
        return 'topRight';
      case LogoAlignment.bottomLeft:
        return 'bottomLeft';
      case LogoAlignment.bottomRight:
        return 'bottomRight';
      case LogoAlignment.center:
        return 'center';
      case LogoAlignment.topCenter:
        return 'topCenter';
      case LogoAlignment.bottomCenter:
        return 'bottomCenter';
      case LogoAlignment.leftCenter:
        return 'leftCenter';
      case LogoAlignment.rightCenter:
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
