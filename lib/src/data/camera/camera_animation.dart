import 'package:kakao_maps_flutter/src/base/data.dart';

/// Camera animation configuration
/// [EN]
/// - Defines animation behavior for camera movements
///
/// [KO]
/// - 카메라 이동 시 애니메이션 동작 정의
class CameraAnimation extends Data {
  /// Create animation
  /// [EN]
  /// - [duration]: milliseconds, [autoElevation]: auto adjust elevation, [isConsecutive]: sequence flag
  ///
  /// [KO]
  /// - [duration]: 밀리초, [autoElevation]: 고도 자동 조정, [isConsecutive]: 연속 실행 플래그
  const CameraAnimation({
    required this.duration,
    required this.autoElevation,
    required this.isConsecutive,
  });

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'duration': duration,
        'autoElevation': autoElevation,
        'isConsecutive': isConsecutive,
      };

  /// The duration of the animation in milliseconds.
  final int duration;

  /// Whether to automatically adjust elevation during animation.
  final bool autoElevation;

  /// Whether this animation is part of a consecutive sequence.
  final bool isConsecutive;
}
