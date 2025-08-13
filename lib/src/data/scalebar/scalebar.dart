import 'package:kakao_maps_flutter/src/base/data.dart';

/// Scale bar configuration
/// [EN]
/// - Displays current map scale with optional auto-hide behavior
///
/// [KO]
/// - 현재 지도 축척을 표시하며 자동 숨김 동작을 지원
class ScaleBar extends Data {
  /// Create configuration
  /// [EN]
  /// - [isAutoHide]: auto hide, [fadeInTime]/[fadeOutTime]/[retentionTime]: timings in ms
  ///
  /// [KO]
  /// - [isAutoHide]: 자동 숨김, [fadeInTime]/[fadeOutTime]/[retentionTime]: 밀리초 단위 시간
  const ScaleBar({
    this.isAutoHide = false,
    this.fadeInTime = 300,
    this.fadeOutTime = 300,
    this.retentionTime = 3000,
  });

  /// From JSON map
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

  /// Auto-hide enabled
  final bool isAutoHide;

  /// Fade-in time (ms)
  final int fadeInTime;

  /// Fade-out time (ms)
  final int fadeOutTime;

  /// Retention time before auto-hide (ms)
  final int retentionTime;
}
