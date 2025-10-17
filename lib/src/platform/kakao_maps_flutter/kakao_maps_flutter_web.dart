import 'dart:async';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:kakao_maps_flutter/src/platform/kakao_maps_flutter/interface/kakao_maps_flutter_platform_interface.dart';
import 'package:web/web.dart' as web;

/// A web implementation of the KakaoMapsFlutterPlatform of the KakaoMapsFlutter plugin.
class KakaoMapsFlutterPlugin extends KakaoMapsFlutterPlatform {
  /// Registers this class as the default instance of [KakaoMapsFlutterPlatform].
  static void registerWith(Registrar registrar) {
    KakaoMapsFlutterPlatform.instance = KakaoMapsFlutterPlugin();
  }

  @override
  Future<void> init({String? nativeAppKey, String? webAppKey}) async {
    if (webAppKey == null) {
      return;
    }

    final completer = Completer<void>();

    final script =
        (web.document.createElement('script') as web.HTMLScriptElement)
          ..src =
              '//dapi.kakao.com/v2/maps/sdk.js?appkey=$webAppKey&libraries=services,clusterer,drawing'
          ..async = true
          ..onLoad.listen((_) {
            completer.complete();
          })
          ..onError.listen((_) {
            completer.completeError(
              'Failed to load Kakao Maps SDK for web.',
            );
          });

    web.document.head?.append(script);

    return completer.future;
  }
}
