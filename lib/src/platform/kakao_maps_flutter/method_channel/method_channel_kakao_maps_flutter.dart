part of '../kakao_maps_flutter.dart';

/// An implementation of [KakaoMapsFlutterPlatform] that uses method channels.
class MethodChannelKakaoMapsFlutter extends KakaoMapsFlutterPlatform {
  static const MethodChannel _methodChannel = MethodChannel(
    'kakao_maps_flutter',
  );

  @override
  Future<void> init(String token) async => _methodChannel.invokeMethod(
        'init',
        {'appKey': token},
      );
}
