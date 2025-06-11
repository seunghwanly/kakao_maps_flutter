import 'package:kakao_maps_flutter/src/base/data.dart';

/// Animation configuration for camera movements.
///
/// Defines how the camera should animate when moving to a new position.
class CameraAnimation extends Data {
  /// Creates a new CameraAnimation with the specified parameters.
  ///
  /// The [duration] specifies how long the animation should take in milliseconds.
  /// The [autoElevation] determines if elevation should be automatically adjusted.
  /// The [isConsecutive] indicates if this animation is part of a sequence.
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
