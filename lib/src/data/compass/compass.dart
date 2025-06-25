import 'dart:ui';

import 'package:kakao_maps_flutter/src/base/data.dart';

/// Alignment options for positioning the compass on the map.
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

/// Configuration for the compass widget on the map.
///
/// The compass shows the current direction and allows users to return to north.
class Compass extends Data {
  /// Creates a new Compass configuration.
  ///
  /// The [isBackToNorthOnClick] determines whether clicking the compass returns
  /// the map to north orientation.
  /// The [alignment] determines the position of the compass on the map.
  /// The [offset] provides additional positioning offset from the alignment point.
  const Compass({
    this.isBackToNorthOnClick = true,
    this.alignment = CompassAlignment.topRight,
    this.offset = const Offset(0, 0),
  });

  /// Creates a Compass instance from a JSON map.
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

  /// Whether clicking the compass returns the map to north orientation.
  final bool isBackToNorthOnClick;

  /// The alignment position of the compass on the map.
  final CompassAlignment alignment;

  /// The offset from the alignment position in pixels.
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
