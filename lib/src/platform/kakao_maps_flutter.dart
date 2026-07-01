import 'package:flutter/foundation.dart';
import 'package:kakao_maps_flutter/src/view/static_kakao_map/static_kakao_map.dart'
    show StaticMapController;

import 'interface/kakao_maps_flutter_platform_interface.dart';

/// Kakao Maps SDK bootstrap
/// [EN]
/// - Initializes the Kakao Maps SDK with API keys for Android, iOS, and Web
///
/// [KO]
/// - Android, iOS, Web에서 사용할 Kakao Maps SDK 초기화 수행
class KakaoMapsFlutter {
  const KakaoMapsFlutter._();

  /// Initialize Kakao Maps SDK
  /// [EN]
  /// - Provide Kakao Developers native app key via [nativeAPIKey] on Android/iOS
  /// - Provide JavaScript key via [webAPIKey] on Web and when using StaticMap
  /// - Console: `https://developers.kakao.com/console/app`
  ///
  /// [KO]
  /// - Android/iOS에서는 [nativeAPIKey]에 Kakao Developers 네이티브 앱 키 입력
  /// - Web 및 StaticMap 사용 시 [webAPIKey]에 JavaScript 키 입력
  /// - 콘솔: `https://developers.kakao.com/console/app`
  static Future<void> init(String? nativeAPIKey, {String? webAPIKey}) async {
    if (!kIsWeb && (nativeAPIKey == null || nativeAPIKey.isEmpty)) {
      throw ArgumentError.value(
        nativeAPIKey,
        'nativeAPIKey',
        'A Kakao native app key is required on Android and iOS.',
      );
    }

    if (webAPIKey != null && webAPIKey.isNotEmpty) {
      StaticMapController.init(webAPIKey);
    }

    return KakaoMapsFlutterPlatform.instance.init(
      nativeAppKey: nativeAPIKey,
      webAppKey: webAPIKey,
    );
  }
}
