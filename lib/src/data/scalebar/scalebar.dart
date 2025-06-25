import 'package:kakao_maps_flutter/src/base/data.dart';

/// Configuration for the scale bar widget on the map.
///
/// The scale bar shows the current map scale and can auto-hide based on configuration.
class ScaleBar extends Data {
  /// Creates a new ScaleBar configuration.
  ///
  /// The [isAutoHide] determines whether the scale bar automatically hides.
  /// The [fadeInTime], [fadeOutTime], and [retentionTime] control the auto-hide behavior.
  const ScaleBar({
    this.isAutoHide = false,
    this.fadeInTime = 300,
    this.fadeOutTime = 300,
    this.retentionTime = 3000,
  });

  /// Creates a ScaleBar instance from a JSON map.
  factory ScaleBar.fromJson(Map<String, Object?> json) => ScaleBar(
        isAutoHide: json['isAutoHide'] as bool? ?? false,
        fadeInTime: json['fadeInTime'] as int? ?? 300,
        fadeOutTime: json['fadeOutTime'] as int? ?? 300,
        retentionTime: json['retentionTime'] as int? ?? 3000,
      );

  @override
  Map<String, Object?> toJson() => {
        'isAutoHide': isAutoHide,
        'fadeInTime': fadeInTime,
        'fadeOutTime': fadeOutTime,
        'retentionTime': retentionTime,
      };

  /// Whether the scale bar automatically hides.
  final bool isAutoHide;

  /// Fade in time in milliseconds.
  final int fadeInTime;

  /// Fade out time in milliseconds.
  final int fadeOutTime;

  /// Retention time in milliseconds before auto-hiding.
  final int retentionTime;
}
