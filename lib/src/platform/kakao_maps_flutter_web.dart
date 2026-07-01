import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:kakao_maps_flutter/src/platform/interface/kakao_maps_flutter_platform_interface.dart';
import 'package:web/web.dart' as web;

/// A web implementation of the KakaoMapsFlutterPlatform of the KakaoMapsFlutter plugin.
class KakaoMapsFlutterPlugin extends KakaoMapsFlutterPlatform {
  /// Registers this class as the default instance of [KakaoMapsFlutterPlatform].
  static void registerWith(Registrar registrar) {
    KakaoMapsFlutterPlatform.instance = KakaoMapsFlutterPlugin();
  }

  @override
  Future<void> init({String? nativeAppKey, String? webAppKey}) async {
    if (webAppKey == null || webAppKey.isEmpty) {
      throw ArgumentError.value(
        webAppKey,
        'webAppKey',
        'A Kakao JavaScript key is required on Web.',
      );
    }

    // Check if Kakao Maps SDK is already loaded (from HTML script tag)
    final kakaoObj = globalContext['kakao'] as JSObject?;

    if (kakaoObj != null) {
      // SDK script is loaded, now call kakao.maps.load()
      final mapsObj = kakaoObj['maps'] as JSObject?;
      if (mapsObj != null) {
        final loadFn = mapsObj['load'] as JSFunction?;
        if (loadFn != null) {
          final completer = Completer<void>();

          // Call kakao.maps.load(callback)
          loadFn.callAsFunction(
            mapsObj,
            (() {
              web.console.log('Kakao Maps SDK loaded successfully'.toJS);
              completer.complete();
            }).toJS,
          );

          return completer.future;
        }
      }
    }

    // Fallback: Dynamically load the SDK if not present in HTML
    web.console.log('Dynamically loading Kakao Maps SDK for web'.toJS);

    final completer = Completer<void>();

    final script =
        (web.document.createElement('script') as web.HTMLScriptElement)
          ..src =
              'https://dapi.kakao.com/v2/maps/sdk.js?appkey=$webAppKey&libraries=services,clusterer,drawing&autoload=false'
          ..async = true
          ..onLoad.listen((_) {
            // After script loads, call kakao.maps.load()
            final kakaoObj = globalContext['kakao'] as JSObject?;
            if (kakaoObj != null) {
              final mapsObj = kakaoObj['maps'] as JSObject?;
              if (mapsObj != null) {
                final loadFn = mapsObj['load'] as JSFunction?;
                if (loadFn != null) {
                  loadFn.callAsFunction(
                    mapsObj,
                    (() {
                      web.console.log(
                        'Kakao Maps SDK loaded successfully (dynamic)'.toJS,
                      );
                      completer.complete();
                    }).toJS,
                  );
                  return;
                }
              }
            }
            completer.completeError(
              'Failed to initialize Kakao Maps after loading script',
            );
          })
          ..onError.listen((event) {
            completer.completeError('Failed to load Kakao Maps SDK for web.');
          });

    web.document.head?.append(script);

    return completer.future;
  }
}
