// ignore_for_file: avoid_classes_with_only_static_members

import '../../view/static_kakao_map/static_kakao_map.dart';
import 'interface/kakao_maps_flutter_platform_interface.dart';

/// Kakao Maps SDK bootstrap
/// [EN]
/// - Initializes the Kakao Maps SDK with API keys for Android and iOS
///
/// [KO]
/// - Android, iOS에서 사용할 Kakao Maps SDK 초기화 수행
class KakaoMapsFlutter {
  /// Initialize Kakao Maps SDK
  /// [EN]
  /// - Provide Kakao Developers native app key via [nativeAPIKey]
  /// - Provide JavaScript key via [webAPIKey] when using StaticMap
  /// - Console: `https://developers.kakao.com/console/app`
  ///
  /// [KO]
  /// - [nativeAPIKey]에 Kakao Developers 네이티브 앱 키 입력
  /// - StaticMap 사용 시 [webAPIKey]에 JavaScript 키 입력
  /// - 콘솔: `https://developers.kakao.com/console/app`
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

    return KakaoMapsFlutterPlatform.instance.init(
      nativeAppKey: nativeAPIKey,
      webAppKey: webAPIKey,
    );
  }
}
