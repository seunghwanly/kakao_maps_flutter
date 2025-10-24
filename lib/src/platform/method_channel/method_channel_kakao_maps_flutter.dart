import 'package:flutter/services.dart';

import '../interface/kakao_maps_flutter_platform_interface.dart';

/// An implementation of [KakaoMapsFlutterPlatform] that uses method channels.
class MethodChannelKakaoMapsFlutter extends KakaoMapsFlutterPlatform {
  static const MethodChannel _methodChannel = MethodChannel(
    'kakao_maps_flutter',
  );

  @override
  Future<void> init({String? nativeAppKey, String? webAppKey}) async {
    if (nativeAppKey == null) {
      return;
    }
    return _methodChannel.invokeMethod(
      'init',
      {'appKey': nativeAppKey},
    );
  }
}
