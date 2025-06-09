import 'package:kakao_maps_flutter/src/base/data.dart';

class CameraAnimation extends Data {
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

  final int duration;

  final bool autoElevation;

  final bool isConsecutive;
}
