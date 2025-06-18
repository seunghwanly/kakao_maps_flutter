// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../view/static_kakao_map/static_kakao_map.dart';

part 'interface/kakao_maps_flutter_platform_interface.dart';
part 'method_channel/method_channel_kakao_maps_flutter.dart';

/// Kakao Maps API 인증을 위한 클래스
class KakaoMapsFlutter {
  /// [nativeAPIKey]에 Kakao Developers에서 발급받은 API키(네이티브 앱 키)를 입력합니다.
  ///
  /// StaticMap을 사용하는 경우에는
  /// [webAPIKey]에 Kakao Developers에서 발급받은 API키(JavaScript 키)를 입력합니다.
  ///
  /// https://developers.kakao.com/console/app
  static Future<void> init(
    String nativeAPIKey, {
    String? webAPIKey,
  }) async {
    assert(
      nativeAPIKey.isNotEmpty,
      '🚧 Initialization Failed: token should not be empty',
    );

    if (webAPIKey != null && webAPIKey.isNotEmpty) {
      StaticMapController.init(webAPIKey);
    }

    return KakaoMapsFlutterPlatform.instance.init(nativeAPIKey);
  }
}
