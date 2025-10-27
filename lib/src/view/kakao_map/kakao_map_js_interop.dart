/// JS Interop bindings for Kakao Maps JavaScript API
/// Web API Documentation: https://apis.map.kakao.com/web/documentation/
///
/// This file contains only the external JS bindings and basic constructors.
/// All helper methods are in WebKakaoMapController.
library;

import 'dart:js_interop';

/// Global kakao object
@JS('kakao')
external JSObject? get kakao;

/// Extension for JSObject to add property access
extension JSObjectExtension on JSObject {
  /// Get property by name
  external JSAny? operator [](String property);

  /// Set property by name
  external void operator []=(String property, JSAny? value);
}

/// Helper to check if Kakao Maps SDK is loaded
bool isKakaoMapsLoaded() {
  final k = kakao;
  if (k == null) return false;
  final maps = k['maps'] as JSObject?;
  return maps != null;
}
